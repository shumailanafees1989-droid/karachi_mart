param(
    [int]$Port = 5174
)

# Parse .env if exists
function Get-EnvMap {
    $envFile = Join-Path $PSScriptRoot ".env"
    $map = @{}
    if (Test-Path $envFile) {
        $lines = Get-Content $envFile
        foreach ($line in $lines) {
            $trimmed = $line.Trim()
            if ($trimmed -and -not $trimmed.StartsWith('#') -and $trimmed.Contains('=')) {
                $idx = $trimmed.IndexOf('=')
                $k = $trimmed.Substring(0, $idx).Trim()
                $v = $trimmed.Substring($idx + 1).Trim()
                $map[$k] = $v
            }
        }
    }
    return $map
}

$listener = New-Object System.Net.HttpListener
$prefix = "http://localhost:$Port/"
$listener.Prefixes.Add($prefix)

try {
    $listener.Start()
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host " Karachi Mart Retail ERP Server Running on: $prefix" -ForegroundColor Cyan
    Write-Host " Supabase Integration: Active (.env loaded)" -ForegroundColor Yellow
    Write-Host " Press Ctrl+C in this terminal window to stop the server." -ForegroundColor Gray
    Write-Host "==========================================================" -ForegroundColor Green

    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $path = $request.Url.LocalPath.TrimStart('/')
        if ([string]::IsNullOrWhiteSpace($path)) {
            $path = "index.html"
        }

        # Serve virtual /env.js dynamically from .env
        if ($path -eq "env.js") {
            $envMap = Get-EnvMap
            $json = ConvertTo-Json $envMap
            $jsContent = "window.ENV = $json; console.log('[KarachiMart] Loaded .env configuration');"
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($jsContent)
            $response.ContentType = "application/javascript; charset=utf-8"
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.Close()
            continue
        }

        $filePath = Join-Path $PSScriptRoot $path

        if (Test-Path $filePath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            $mime = switch ($ext) {
                ".html" { "text/html; charset=utf-8" }
                ".css"  { "text/css" }
                ".js"   { "application/javascript" }
                ".json" { "application/json" }
                ".sql"  { "text/plain; charset=utf-8" }
                ".env"  { "text/plain; charset=utf-8" }
                ".png"  { "image/png" }
                ".jpg"  { "image/jpeg" }
                ".svg"  { "image/svg+xml" }
                default { "application/octet-stream" }
            }
            $response.ContentType = $mime
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $msg = [System.Text.Encoding]::UTF8.GetBytes("404 - Karachi Mart ERP Page Not Found")
            $response.OutputStream.Write($msg, 0, $msg.Length)
        }
        $response.Close()
    }
} finally {
    $listener.Stop()
}
