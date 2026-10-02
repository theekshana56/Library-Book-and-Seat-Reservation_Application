$ErrorActionPreference = 'Stop'
$envFile = Join-Path $PSScriptRoot '.env'

if (-not (Test-Path -LiteralPath $envFile)) {
    throw "Missing $envFile. Copy .env.example to .env and set your MongoDB credentials."
}

Get-Content -LiteralPath $envFile | ForEach-Object {
    $line = $_.Trim()
    if (-not $line -or $line.StartsWith('#')) {
        return
    }

    if ($line -notmatch '^([A-Za-z_][A-Za-z0-9_]*)=(.*)$') {
        throw "Invalid setting in $envFile. Expected KEY=value."
    }

    $name = $Matches[1]
    $value = $Matches[2].Trim()
    if ($value.Length -ge 2 -and
        (($value.StartsWith('"') -and $value.EndsWith('"')) -or
            ($value.StartsWith("'") -and $value.EndsWith("'")))) {
        $value = $value.Substring(1, $value.Length - 2)
    }

    Set-Item -Path "Env:$name" -Value $value
}

foreach ($requiredName in @('MONGODB_USERNAME', 'MONGODB_PASSWORD', 'MONGODB_CLUSTER')) {
    if (-not (Get-Item -Path "Env:$requiredName" -ErrorAction SilentlyContinue)) {
        throw "Missing $requiredName in $envFile."
    }
}

$username = [uri]::EscapeDataString($env:MONGODB_USERNAME)
$password = [uri]::EscapeDataString($env:MONGODB_PASSWORD)
$database = if ($env:MONGODB_DATABASE) { $env:MONGODB_DATABASE } else { 'biblione_db' }
$env:MONGODB_URI = "mongodb+srv://${username}:${password}@${env:MONGODB_CLUSTER}/${database}?retryWrites=true&w=majority"

Push-Location $PSScriptRoot
try {
    & mvn spring-boot:run
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
