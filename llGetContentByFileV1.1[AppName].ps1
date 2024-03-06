param (
    [string[]]$Path = '',
    [string[]]$Filter = '',
    [string]$Search = ''
)

[PSCustomObject[]] $matchedLines = @()

foreach ($pattern in $Filter) {
    $previousDirectory = ''
    foreach ($directory in $Path) {
        if ($directory -ne $previousDirectory) {
            $matchedLines = Get-ChildItem -Path $directory -Filter ('*' + $pattern + '*') | ForEach-Object{
                $file = $_
                $content = $_ | Get-Content
                foreach ($line in $content) {
                    if ($line -like ("*" + $Search + '*')) {
                         @{
                            Directory = $directory
                            FileName = $file.Name
                            Line = $line
                        }
                    }
                }
            }
        }
        $previousDirectory = $directory
    }
}
return $matchedLines