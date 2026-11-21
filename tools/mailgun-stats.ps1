$ErrorActionPreference='Stop'
$key=(& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Get MAILGUN_API_KEY).Trim()
$auth=@{Authorization='Basic '+[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("api:$key"))}
$d=Invoke-RestMethod -Uri 'https://api.mailgun.net/v3/domains/mail.terracactus.net' -Headers $auth
"domain: $($d.domain.name) state=$($d.domain.state) created=$($d.domain.created_at) smtp_login=$($d.domain.smtp_login)"
try {
  $s=Invoke-RestMethod -Uri 'https://api.mailgun.net/v3/mail.terracactus.net/stats/total?event=accepted&duration=30d' -Headers $auth
  "accepted last 30d: $($s.total_count) | last event: $($s.start)-$($s.end)"
} catch { "stats error: $($_.Exception.Message)" }