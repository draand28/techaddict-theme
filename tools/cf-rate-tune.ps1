$ErrorActionPreference='Stop'
$token=(& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Get CF_API_TOKEN).Trim()
$h=@{Authorization="Bearer $token";'Content-Type'='application/json'}
$zid=(Invoke-RestMethod -Uri 'https://api.cloudflare.com/client/v4/zones?name=techaddict.ro' -Headers $h).result[0].id
$base="https://api.cloudflare.com/client/v4/zones/$zid/rulesets/phases/http_ratelimit/entrypoint"
$body=@{
  rules=@(@{
    action='block'; description='wp-login POST rate limit'; enabled=$true
    expression='(http.request.uri.path eq "/wp-login.php" and http.request.method eq "POST")'
    ratelimit=@{characteristics=@('cf.colo.id','ip.src');period=10;requests_per_period=5;mitigation_timeout=10}
  })
}|ConvertTo-Json -Depth 6
$r=Invoke-RestMethod -Method Put -Uri $base -Headers $h -Body $body
Write-Host "rule updated: requests=$($r.result.rules[0].ratelimit.requests_per_period) period=$($r.result.rules[0].ratelimit.period) block=$($r.result.rules[0].ratelimit.mitigation_timeout)s action=$($r.result.rules[0].action)"