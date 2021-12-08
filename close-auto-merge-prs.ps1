gh pr list --author azure-sdk --label "auto-merge" --search "is:open Increment version for resourcemanager/" --json number,title | ConvertFrom-Json | ForEach-Object {
    $number = $_.number
    Write-Host Closing $number
    gh pr close $number
}