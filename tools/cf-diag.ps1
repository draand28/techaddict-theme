$ErrorActionPreference='Stop'
$token=(& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Get CF_API_TOKEN).Trim()
$h=@{Authorization="Bearer $token";'Content-Type'='application/json'}
$v=Invoke-RestMethod -Uri 'https://api.cloudflare.com/client/v4/user/tokens/verify' -Headers $h
"token: $($v.result.status)"
$zid=(Invoke-RestMethod -Uri 'https://api.cloudflare.com/client/v4/zones?name=techaddict.ro' -Headers $h).result[0].id
try {
  $rs=Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$zid/rulesets" -Headers $h
  "rulesets:"
  $rs.result | Select-Object phase,id,kind | Format-Table -AutoSize
} catch { "rulesets read error: $($_.ErrorDetails.Message)" }
foreach ($phase in 'http_ratelimit','http_request_firewall_custom') {
  try {
    $r=Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$zid/rulesets/phases/$phase/entrypoint" -Headers $h
    "$phase entrypoint: $($r.result.id) rules=$($r.result.rules.Count)"
  } catch { "$phase entrypoint error: $($_.Exception.Response.StatusCode.value__) $($_.ErrorDetails.Message)" }
}