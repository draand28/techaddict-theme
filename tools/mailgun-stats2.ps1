$ErrorActionPreference='Stop'
$key=(& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Get MAILGUN_API_KEY).Trim()
$auth=@{Authorization='Basic '+[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("api:$key"))}
foreach ($ev in 'delivered','failed','stored') {
  try { $s=Invoke-RestMethod -Uri "https://api.mailgun.net/v3/mail.terracactus.net/stats/total?event=$ev&duration=90d" -Headers $auth; "$ev last 90d: $($s.total_count)" } catch { "$ev error" }
}