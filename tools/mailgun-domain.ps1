$ErrorActionPreference = 'Stop'
$key = (& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Get MAILGUN_API_KEY).Trim()
$auth = @{ Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("api:$key")) }
$base = 'https://api.mailgun.net'
$domain = 'mg.techaddict.ro'

$smPass = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object { [char]$_ })
& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Set MAILGUN_SMTP_PASSWORD -Value $smPass | Out-Null
& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Set MAILGUN_SMTP_USER -Value "postmaster@$domain" | Out-Null

$exists = $true
try { $null = Invoke-RestMethod -Uri "$base/v3/domains/$domain" -Headers $auth } catch { $exists = $false }

if (-not $exists) {
	$body = @{ name = $domain; smtp_password = $smPass; spam_action = 'disabled'; wildcard = 'false' }
	try {
		$created = Invoke-RestMethod -Method Post -Uri "$base/v3/domains" -Headers $auth -Body $body
		"created domain: $($created.domain.name) state=$($created.domain.state)"
	} catch {
		$resp = $_.Exception.Response
		$sr = New-Object IO.StreamReader($resp.GetResponseStream())
		"create failed: $($sr.ReadToEnd())"
		throw
	}
} else { "domain already exists" }

$d = Invoke-RestMethod -Uri "$base/v3/domains/$domain" -Headers $auth
"domain: $($d.domain.name) state=$($d.domain.state) type=$($d.domain.type)"
"dns records:"
$d.sending_dns_records | Select-Object record_type, name, value, ttl, priority, valid | Format-Table -AutoSize -Wrap