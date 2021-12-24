[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $autorestArtifactPath,
    [Parameter()]
    [string]
    $dotnetSDKPath
)

$root = Join-Path $dotnetSDKPath "sdk"
Get-ChildItem $root -Recurse -Attributes Directory -Depth 2 | ForEach-Object {
    if ($_.Name -match "^Azure.ResourceManager") {
        Write-Host "regenerating $_"
        $path = Join-Path $_ "src"
        Push-Location $path
        autorest --use=$autorestArtifactPath autorest.md
        Pop-Location  
    }
}

Write-Host 1
