# Apply the DNS and zone fixes for techaddict.ro through the Cloudflare API.
$ErrorActionPreference = 'Stop'
$token = (& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Get CF_API_TOKEN).Trim()
$h = @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' }
$zone = (Invoke-RestMethod -Uri 'https://api.cloudflare.com/client/v4/zones?name=techaddict.ro' -Headers $h).result[0].id

function Get-Records { (Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$zone/dns_records?per_page=100" -Headers $h).result }
function Upsert-Record($type, $name, $content, $extra = @{}) {
	$existing = Get-Records | Where-Object { $_.type -eq $type -and $_.name -eq $name -and $_.content -eq $content }
	if ($existing) { return "exists $type $name $content" }
	$body = @{ type = $type; name = $name; content = $content; ttl = 1 } + $extra | ConvertTo-Json
	$r = Invoke-RestMethod -Method Post -Uri "https://api.cloudflare.com/client/v4/zones/$zone/dns_records" -Headers $h -Body $body
	if (-not $r.success) { throw "failed $type $name : $($r.errors | ConvertTo-Json -Compress)" }
	return "added $type $name $content"
}

# www through Cloudflare instead of straight to the origin
$www = Get-Records | Where-Object { $_.type -eq 'CNAME' -and $_.name -eq 'www.techaddict.ro' }
if ($www) {
	$body = @{ proxied = $true } | ConvertTo-Json
	$r = Invoke-RestMethod -Method Patch -Uri "https://api.cloudflare.com/client/v4/zones/$zone/dns_records/$($www.id)" -Headers $h -Body $body
	"www proxied: $($r.result.proxied)"
}

Upsert-Record 'TXT' 'techaddict.ro' 'v=spf1 include:zoho.com ~all'
Upsert-Record 'TXT' '_dmarc.techaddict.ro' 'v=DMARC1; p=none; rua=mailto:admin@techaddict.ro; adkim=r; aspf=r'
Upsert-Record 'MX' 'techaddict.ro' 'mx2.zoho.com' @{ priority = 20 }
Upsert-Record 'MX' 'techaddict.ro' 'mx3.zoho.com' @{ priority = 50 }
Upsert-Record 'CAA' 'techaddict.ro' 'letsencrypt.org' @{ data = @{ flags = 0; tag = 'issue'; value = 'letsencrypt.org' } }
Upsert-Record 'CAA' 'techaddict.ro' 'pki.goog' @{ data = @{ flags = 0; tag = 'issue'; value = 'pki.goog' } }
Upsert-Record 'CAA' 'techaddict.ro' 'digicert.com' @{ data = @{ flags = 0; tag = 'issue'; value = 'digicert.com' } }
Upsert-Record 'CAA' 'techaddict.ro' 'sectigo.com' @{ data = @{ flags = 0; tag = 'issue'; value = 'sectigo.com' } }

foreach ($s in @(
	@{ id = 'min_tls_version'; value = '1.2' },
	@{ id = 'security_level'; value = 'medium' },
	@{ id = 'cache_level'; value = 'standard' }
)) {
	try {
		$r = Invoke-RestMethod -Method Patch -Uri "https://api.cloudflare.com/client/v4/zones/$zone/settings/$($s.id)" -Headers $h -Body (@{ value = $s.value } | ConvertTo-Json)
		"setting $($s.id) = $($r.result.value)"
	} catch {
		"setting $($s.id) failed: $($_.Exception.Message)"
	}
}

Invoke-RestMethod -Method Post -Uri "https://api.cloudflare.com/client/v4/zones/$zone/purge_cache" -Headers $h -Body (@{ purge_everything = $true } | ConvertTo-Json) | Out-Null
"cache purged"
Get-Records | Select-Object type, name, content, proxied, priority | Format-Table -AutoSize
