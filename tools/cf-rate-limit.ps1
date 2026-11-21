$ErrorActionPreference = 'Stop'
$token = (& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Get CF_API_TOKEN).Trim()
$h = @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' }
$zid = (Invoke-RestMethod -Uri 'https://api.cloudflare.com/client/v4/zones?name=techaddict.ro' -Headers $h).result[0].id
$uri = "https://api.cloudflare.com/client/v4/zones/$zid/rulesets/phases/http_ratelimit/entrypoint"

try {
    $current = Invoke-RestMethod -Uri $uri -Headers $h
    "current ruleset: $($current.result.id), rules: $($current.result.rules.Count)"
} catch {
    "no existing rate limit ruleset: $($_.Exception.Message)"
}

function Try-Rule($action, $period, $requests, $timeout, $expression) {
    $body = @{
        description = 'Login brute force protection'
        rules = @(@{
            action = $action
            description = 'wp-login POST rate limit'
            enabled = $true
            expression = $expression
            ratelimit = @{
                characteristics = @('ip.src')
                period = $period
                requests_per_period = $requests
                mitigation_timeout = $timeout
            }
        })
    } | ConvertTo-Json -Depth 6
    try {
        $r = Invoke-RestMethod -Method Put -Uri $uri -Headers $h -Body $body
        "created: action=$action period=$period requests=$requests timeout=$timeout (rules=$($r.result.rules.Count))"
        return $true
    } catch {
        $msg = $_.ErrorDetails.Message
        if (-not $msg) { $msg = $_.Exception.Message }
        "failed: action=$action period=$period timeout=$timeout -> $msg"
        return $false
    }
}

$expr = '(http.request.uri.path eq "/wp-login.php" and http.request.method eq "POST")'
if (Try-Rule 'managed_challenge' 10 10 60 $expr) { }
elseif (Try-Rule 'block' 10 10 60 $expr) { }
elseif (Try-Rule 'block' 10 10 10 $expr) { }
else { "no rate limit rule was accepted" }

try {
    $out = Invoke-RestMethod -Uri $uri -Headers $h
    $out.result.rules | Select-Object action, expression, enabled, @{n='ratelimit';e={$_.ratelimit | ConvertTo-Json -Compress}} | Format-List
} catch { "could not read back the ruleset" }
