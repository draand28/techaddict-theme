# Deploy the Carbon style to the live forum and refresh caches.
# Usage: powershell -NoProfile -File tools/deploy.ps1
$ErrorActionPreference = 'Stop'
$style = 'C:\Users\draan\opencode\techaddict-theme\styles\techaddict'
$srv = 'root@192.168.45.133'
$remote = '/var/www/techaddict.ro/html/forum/styles/techaddict'

scp "$style\theme\stylesheet.css" "$style\theme\colours.css" "$style\theme\techaddict.css" "${srv}:$remote/theme/"
scp "$style\template\overall_header.html" "$style\template\navbar_header.html" "${srv}:$remote/template/"
ssh $srv "chown -R www-data:www-data $remote; find $remote -type d -exec chmod 755 {} +; find $remote -type f -exec chmod 644 {} +; sudo -u www-data php /var/www/techaddict.ro/html/forum/bin/phpbbcli.php cache:purge"

$token = (& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Get CF_API_TOKEN).Trim()
$hdr = @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' }
$zones = Invoke-RestMethod -Uri 'https://api.cloudflare.com/client/v4/zones?name=techaddict.ro' -Headers $hdr
$zone = $zones.result[0].id
$files = @(
	'https://techaddict.ro/forum/styles/techaddict/theme/stylesheet.css',
	'https://techaddict.ro/forum/styles/techaddict/theme/colours.css',
	'https://techaddict.ro/forum/styles/techaddict/theme/techaddict.css',
	'https://techaddict.ro/forum/styles/techaddict/theme/en/stylesheet.css'
)
$body = @{ files = $files } | ConvertTo-Json
$purge = Invoke-RestMethod -Method Post -Uri "https://api.cloudflare.com/client/v4/zones/$zone/purge_cache" -Headers $hdr -Body $body
"cloudflare purge success: $($purge.success)"
