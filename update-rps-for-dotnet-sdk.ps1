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
        if ($_.Name -match "^Azure.ResourceManager.Insights") {
            Write-Host "skipping $_"
            continue
        }
        # checking if the src/autorest.md exists
        $path = Join-Path $_ "src"
        $autorestMdFilepath = Join-Path $path "autorest.md"
        if (Test-Path -Path $autorestMdFilepath) {
            Write-Host "regenerating $_"
            Push-Location $path
            autorest --use=$autorestArtifactPath autorest.md
            Pop-Location  
        }
    }
}

Write-Host 1
