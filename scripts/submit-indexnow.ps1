param([switch]$Submit)

$ErrorActionPreference = 'Stop'
$siteOrigin = 'https://fomo9527.top'
$projectRoot = Split-Path $PSScriptRoot -Parent
$keyFile = Join-Path $projectRoot 'indexnow-key.txt'
$key = (Get-Content -LiteralPath $keyFile -Raw -Encoding UTF8).Trim()
if ($key -cnotmatch '^[a-f0-9]{32}$') {
    throw 'Invalid local IndexNow key.'
}

$sitemap = [Xml.XmlDocument]::new()
$sitemap.XmlResolver = $null
$sitemap.LoadXml((Get-Content -LiteralPath (Join-Path $projectRoot 'sitemap.xml') -Raw -Encoding UTF8))
$namespaces = [Xml.XmlNamespaceManager]::new($sitemap.NameTable)
$namespaces.AddNamespace('s', 'http://www.sitemaps.org/schemas/sitemap/0.9')
$urlList = @($sitemap.SelectNodes('/s:urlset/s:url/s:loc', $namespaces) | ForEach-Object { $_.InnerText.Trim() })
if ($urlList.Count -eq 0) {
    throw 'The local sitemap has no URLs to notify.'
}
foreach ($url in $urlList) {
    $parsedUrl = $null
    if (-not [uri]::TryCreate($url, [UriKind]::Absolute, [ref]$parsedUrl) -or
        $parsedUrl.GetLeftPart([UriPartial]::Authority) -cne $siteOrigin -or
        $parsedUrl.Query -or $parsedUrl.Fragment) {
        throw "The sitemap URL must use $siteOrigin without a query or fragment: $url"
    }
}

$keyUrl = "$siteOrigin/indexnow-key.txt"
$payload = @{
    host = ([uri]$siteOrigin).DnsSafeHost
    key = $key
    keyLocation = $keyUrl
    urlList = $urlList
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

foreach ($url in $urlList) {
    $page = Invoke-WebRequest -Uri $url -UseBasicParsing -MaximumRedirection 0 -TimeoutSec 20
    $canonicalPattern = '<link\b(?=[^>]*\brel\s*=\s*["'']canonical["''])(?=[^>]*\bhref\s*=\s*["''](?-i:' + [regex]::Escape($url) + ')["''])[^>]*>'
    if ($page.StatusCode -ne 200 -or
        $page.Content -notmatch $canonicalPattern -or
        $page.Content -match '<meta\b(?=[^>]*\bname\s*=\s*["''](?:robots|bingbot)["''])(?=[^>]*\bcontent\s*=\s*["''][^"'']*\b(?:noindex|none)\b)[^>]*>' -or
        [string]$page.Headers['X-Robots-Tag'] -match '\b(?:noindex|none)\b') {
        throw "The deployed page is not ready: check HTTP status, canonical URL and noindex directives: $url"
    }
}

# Notify once after meaningful page updates; do not schedule repeated submissions.
$response = Invoke-WebRequest -Uri 'https://api.indexnow.org/indexnow' -Method Post `
    -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($payload)) `
    -UseBasicParsing -TimeoutSec 20

switch ([int]$response.StatusCode) {
    200 { Write-Output 'HTTP 200: URLs received by IndexNow. Crawling and indexing are not confirmed.' }
    202 { Write-Output 'HTTP 202: URLs received; ownership key validation is pending. Indexing is not confirmed.' }
    default { throw "Unexpected IndexNow response: HTTP $($response.StatusCode)." }
}
