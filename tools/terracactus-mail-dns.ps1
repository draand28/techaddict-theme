$ErrorActionPreference='Stop'
$token=(& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Get CF_API_TOKEN).Trim()
$h=@{Authorization="Bearer $token"}
$z=(Invoke-RestMethod -Uri 'https://api.cloudflare.com/client/v4/zones?name=terracactus.net' -Headers $h).result[0]
if (-not $z) { "zone not visible with this token"; exit }
"zone: $($z.name) status=$($z.status)"
$r=(Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$($z.id)/dns_records?per_page=100" -Headers $h).result
$r | Where-Object { $_.type -in 'MX','TXT','CNAME' -and ($_.name -match 'mail|dmarc|dkim|domainkey|terracactus' -or $_.type -eq 'MX') } |
  Select-Object type,name,content,priority | Format-Table -AutoSize -Wrap