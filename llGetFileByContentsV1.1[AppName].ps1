param (
    [string]$Path = '',
    [string]$Search = ''
)

$matchingFiles = Get-ChildItem -Path $Path | ForEach-Object {
    $file = $_
    $content = $file | Get-Content
    foreach ($line in $content) {
        if ($line -like ("*" + $Search + '*')) {
            $file
            break
        }
    }
}

return $matchingFiles
