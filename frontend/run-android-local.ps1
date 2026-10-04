param(
    [Parameter(Mandatory = $true)]
    [string]$DeviceId
)

$ErrorActionPreference = 'Stop'
$adbCommand = Get-Command adb -ErrorAction SilentlyContinue
if ($adbCommand) {
    $adb = $adbCommand.Source
}
else {
    $sdkRoots = @(
        $env:ANDROID_SDK_ROOT
        $env:ANDROID_HOME
        (Join-Path $env:LOCALAPPDATA 'Android\Sdk')
    ) | Where-Object { $_ }

    foreach ($sdkRoot in $sdkRoots) {
        $adbPath = Join-Path $sdkRoot 'platform-tools\adb.exe'
        if (Test-Path -LiteralPath $adbPath) {
            $adb = $adbPath
            break
        }
    }
}

if (-not $adb) {
    throw 'ADB was not found. Install Android SDK Platform-Tools or add adb to PATH.'
}

Push-Location $PSScriptRoot
try {
    & $adb -s $DeviceId reverse tcp:8080 tcp:8080
    if ($LASTEXITCODE -ne 0) {
        throw "Could not forward port 8080 to Android device $DeviceId. Check that it is connected and authorized for ADB."
    }

    & flutter run -d $DeviceId `
        --dart-define-from-file=dart_defines.json `
        --dart-define=API_BASE=http://localhost:8080
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
