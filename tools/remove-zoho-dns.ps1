# Remove Zoho from DNS: MX records, verification TXT, Zoho SPF include.
# Keeps SPF/DMARC in place with neutral values until a new provider is chosen.
$ErrorActionPreference = 'Stop'
$token = (& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Get CF_API_TOKEN).Trim()
$h = @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' }
$zid = (Invoke-RestMethod -Uri 'https://api.cloudflare.com/client/v4/zones?name=techaddict.ro' -Headers $h).result[0].id
$records = (Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$zid/dns_records?per_page=100" -Headers $h).result

foreach ($r in $records) {
	if ($r.type -eq 'MX' -and $r.content -like '*zoho.com') {
		Invoke-RestMethod -Method Delete -Uri "https://api.cloudflare.com/client/v4/zones/$zid/dns_records/$($r.id)" -Headers $h | Out-Null
		"deleted MX $($r.content)"
	}
	if ($r.type -eq 'TXT' -and $r.content -like 'zoho-verification=*') {
		Invoke-RestMethod -Method Delete -Uri "https://api.cloudflare.com/client/v4/zones/$zid/dns_records/$($r.id)" -Headers $h | Out-Null
		"deleted TXT $($r.content)"
	}
	if ($r.type -eq 'TXT' -and $r.content -like 'v=spf1*') {
		$body = @{ content = 'v=spf1 -all' } | ConvertTo-Json
		Invoke-RestMethod -Method Patch -Uri "https://api.cloudflare.com/client/v4/zones/$zid/dns_records/$($r.id)" -Headers $h -Body $body | Out-Null
		"SPF set to v=spf1 -all"
	}
	if ($r.type -eq 'TXT' -and $r.name -eq '_dmarc.techaddict.ro') {
		$body = @{ content = 'v=DMARC1; p=none; rua=mailto:draand28@gmail.com; adkim=r; aspf=r' } | ConvertTo-Json
		Invoke-RestMethod -Method Patch -Uri "https://api.cloudflare.com/client/v4/zones/$zid/dns_records/$($r.id)" -Headers $h -Body $body | Out-Null
		"DMARC reports now go to draand28@gmail.com"
	}
}

Invoke-RestMethod -Method Post -Uri "https://api.cloudflare.com/client/v4/zones/$zid/purge_cache" -Headers $h -Body (@{ purge_everything = $true } | ConvertTo-Json) | Out-Null
(Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$zid/dns_records?per_page=100" -Headers $h).result |
	Select-Object type, name, content, priority | Format-Table -AutoSize
