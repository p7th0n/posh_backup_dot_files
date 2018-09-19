# Backup Dot Files

$backup_dir = './backup/'
$backup_list_file = './backup_list.txt'
$commit_message_file = './commit_message.txt'

$git_status = "git status --porcelain"
$git_add = "git add -A ."
$git_commit = "git commit -F commit_message.txt"

Write-Host 'Backup dot files '

# fetch dot files to check for changes
Get-Content $backup_list_file | ForEach-Object {
    $src = '~/' + $_

    Copy-Item -Path $src -Destination $backup_dir -Recurse -Force
}

if (Invoke-Expression $git_status) {
    Write-Host "The dot files changed -- handling changes."

    $timestamp =  Get-Date -Format o
    $backup_results = Get-ChildItem $backup_dir | `
        Sort-Object LastWriteTime -Descending | `
        Format-Table  -Property Name, LastWriteTime, Attributes | `
        Out-String 
        
    "Backup-dot-files.`t" + `
        $timestamp + "`n`n" + `
        "Files-updated:`n`t" + `
        $backup_results | `
        Out-File -FilePath $commit_message_file -Encoding ascii

    Invoke-Expression $git_add
    Invoke-Expression $git_commit 
} else {
    Write-Host "No changes with the dot files."
}

Write-Host 'Done.'
