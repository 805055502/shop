param([switch]$Submit)

$ErrorActionPreference = 'Stop'
$siteOrigin = 'https://fomo9527.top'
$keyFile = Join-Path (Split-Path $PSScriptRoot -Parent) 'indexnow-key.txt'
$key = (Get-Content -LiteralPath $keyFile -Raw -Encoding UTF8).Trim()
if ($key -cnotmatch '^[a-f0-9]{32}$') {
    throw 'Invalid local IndexNow key.'
}

$keyUrl = "$siteOrigin/indexnow-key.txt"
$payload = @{
    host = ([uri]$siteOrigin).DnsSafeHost
    key = $key
    keyLocation = $keyUrl
    urlList = @("$siteOrigin/")
} | ConvertTo-Json

if (-not $Submit) {
    Write-Output $payload
    Write-Output 'Preview only. After deployment, run with -Submit to notify IndexNow.'
    return
}

# Verify the deployed ownership file before sending any notification.
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
$verification = Invoke-WebRequest -Uri $keyUrl -UseBasicParsing -MaximumRedirection 0 -TimeoutSec 20
if ($verification.StatusCode -ne 200 -or $verification.Content.Trim() -cne $key) {
    throw 'The deployed key does not match. Deploy indexnow-key.txt before submitting.'
}

$homepage = Invoke-WebRequest -Uri "$siteOrigin/" -UseBasicParsing -MaximumRedirection 0 -TimeoutSec 20
if ($homepage.StatusCode -ne 200 -or
    $homepage.Content -notmatch '<link\b(?=[^>]*\brel\s*=\s*["'']canonical["''])(?=[^>]*\bhref\s*=\s*["'']https://fomo9527\.top/["''])[^>]*>' -or
    $homepage.Content -match '<meta\b(?=[^>]*\bname\s*=\s*["''](?:robots|bingbot)["''])(?=[^>]*\bcontent\s*=\s*["''][^"'']*\b(?:noindex|none)\b)[^>]*>' -or
    [string]$homepage.Headers['X-Robots-Tag'] -match '\b(?:noindex|none)\b') {
    throw 'The deployed homepage is not ready: check HTTP status, canonical URL and noindex directives.'
}

# Notify once after a meaningful homepage update; do not schedule repeated submissions.
$response = Invoke-WebRequest -Uri 'https://api.indexnow.org/indexnow' -Method Post `
    -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($payload)) `
    -UseBasicParsing -TimeoutSec 20

switch ([int]$response.StatusCode) {
    200 { Write-Output 'HTTP 200: URL received by IndexNow. Crawling and indexing are not confirmed.' }
    202 { Write-Output 'HTTP 202: URL received; ownership key validation is pending. Indexing is not confirmed.' }
    default { throw "Unexpected IndexNow response: HTTP $($response.StatusCode)." }
}
