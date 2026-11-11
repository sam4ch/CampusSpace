param(
    [string]$SqliteDirectory = "$PSScriptRoot/.local",
    [int]$Port = 8080
)
$ErrorActionPreference = 'Stop'
$previousPath = $env:PATH
$previousPort = $env:PORT
Push-Location $PSScriptRoot
try {
    if (Test-Path -LiteralPath (Join-Path $SqliteDirectory 'sqlite3.dll')) {
        $env:PATH = "$SqliteDirectory;$env:PATH"
    }
    $env:PORT = "$Port"
    & dart bin/server.dart
    if ($LASTEXITCODE -ne 0) { throw "Server exited: $LASTEXITCODE" }
} finally {
    $env:PATH = $previousPath
    $env:PORT = $previousPort
    Pop-Location
}
