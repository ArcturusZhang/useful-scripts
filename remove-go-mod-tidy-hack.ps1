[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $sdkRoot
)

function ProcessPackage {
    param (
        $pkgPath
    )

    $filepath = Join-Path $pkgPath "autorest.md"
    if (!(Test-Path -Path $filepath)) {
        return
    }
    
    Write-Host "processing $pkgPath"

    Push-Location $pkgPath
    # first read version number
    $content = Get-Content $filepath
    $lineNumber = -1
    for ($i = 0; $i -lt $content.Count; $i++) {
        $line = $content[$i]
        if ($line -match "^module-version:") {
            $lineNumber = $i
            break
        }
    }
    $versionNumber = $content[$lineNumber].Substring(15).Trim()
    # get new version
    $versions = $versionNumber.Split('.')
    $versions[-1] = [int]$versionNumber.Split('.')[-1] + 1
    $newVersion = Join-String -Separator "." -InputObject $versions
    # replace old version in autorest.md
    $content[$lineNumber] = $content[$lineNumber].Replace($versionNumber, $newVersion)
    Set-Content -Path $filepath -Value $content
    # replace old version in zz_generated_constants.go
    $filepath = Join-Path $pkgPath "zz_generated_constants.go"
    $content = Get-Content $filepath
    $lineNumber = -1
    for ($i = 0; $i -lt $content.Count; $i++) {
        $line = $content[$i]
        if ($line -match "^\s*moduleVersion\s*=\s*" + '"' + [regex]::Escape("v" + $versionNumber) + '"' + "$") {
            $lineNumber = $i
            break
        }
    }
    $content[$lineNumber] = $content[$lineNumber].Replace($versionNumber, $newVersion)
    Set-Content -Path $filepath -Value $content
    # add new entry in changelog
    $filepath = Join-Path $pkgPath "CHANGELOG.md"
    $content = [System.Collections.ArrayList](Get-Content $filepath)
    $content.Insert(1, "") # insert two empty lines
    $newContent = "## $newVersion (2022-02-18)", "", "### Other Changes", "", "- Remove the `go_mod_tidy_hack.go` file."
    for ($i = 0; $i -lt $newContent.Count; $i++) {
        $content.Insert(2 + $i, $newContent[$i])
    }
    Set-Content -Path $filepath -Value $content
    # remove go_mod_tidy_hack.go file
    $filepath = Join-Path $pkgPath "go_mod_tidy_hack.go"
    Remove-Item -Path $filepath
    # call go mod tidy
    Write-Host "go mod tidying..."
    go mod tidy
    Pop-Location
}

$path = Join-Path $sdkRoot "sdk" "resourcemanager"

Get-ChildItem -Path $path -Recurse -Directory | ForEach-Object {
    ProcessPackage $_
}

