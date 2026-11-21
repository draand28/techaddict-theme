$ErrorActionPreference = 'Stop'
$token = (& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Get CF_API_TOKEN).Trim()
$key = (& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Get BREVO_API_KEY).Trim()
$h = @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' }
$bh = @{ 'api-key' = $key; Accept = 'application/json' }
$zid = (Invoke-RestMethod -Uri 'https://api.cloudflare.com/client/v4/zones?name=techaddict.ro' -Headers $h).result[0].id
function Records { (Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$zid/dns_records?per_page=100" -Headers $h).result }
function Upsert($type, $name, $content, $extra = @{}) {
	$found = Records | Where-Object { $_.type -eq $type -and $_.name -eq $name -and $_.content -eq $content }
	if ($found) { return "exists $type $name" }
	$body = @{ type = $type; name = $name; content = $content; ttl = 1; proxied = $false } + $extra | ConvertTo-Json
	$r = Invoke-RestMethod -Method Post -Uri "https://api.cloudflare.com/client/v4/zones/$zid/dns_records" -Headers $h -Body $body
	"added $type $name -> $content"
}

Upsert 'CNAME' 'brevo1._domainkey.techaddict.ro' 'b1.techaddict-ro.dkim.brevo.com'
Upsert 'CNAME' 'brevo2._domainkey.techaddict.ro' 'b2.techaddict-ro.dkim.brevo.com'
Upsert 'TXT' 'techaddict.ro' 'brevo-code:37808f28bf37fd38b5915a048b24c540'

# Replace the placeholder SPF with a Brevo-authorized one
$spf = Records | Where-Object { $_.type -eq 'TXT' -and $_.name -eq 'techaddict.ro' -and $_.content -like 'v=spf1*' }
if ($spf) {
	$body = @{ content = 'v=spf1 include:spf.brevo.com ~all' } | ConvertTo-Json
	Invoke-RestMethod -Method Patch -Uri "https://api.cloudflare.com/client/v4/zones/$zid/dns_records/$($spf.id)" -Headers $h -Body $body | Out-Null
	"spf updated"
}

Start-Sleep -Seconds 5
try {
	$r = Invoke-RestMethod -Method Put -Uri 'https://api.brevo.com/v3/senders/domains/techaddict.ro/authenticate' -Headers $bh
	"authenticate request accepted"
} catch {
	$resp=$_.Exception.Response
	"authenticate failed status=$([int]$resp.StatusCode)"
	$sr=New-Object IO.StreamReader($resp.GetResponseStream()); $sr.ReadToEnd()
}

$d = Invoke-RestMethod -Uri 'https://api.brevo.com/v3/senders/domains' -Headers $bh
$d.domains | Where-Object { $_.domain_name -eq 'techaddict.ro' } | Select-Object domain_name,authenticated,verified,provider,authentication_source | Format-List
