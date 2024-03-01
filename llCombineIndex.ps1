$path = ''
$destination = ''
$fileName = ''

$indexFiles = Get-ChildItem -Path $path
$index = @()
ForEach($file in $indexFiles) {
	$fileLines = $file | Get-Content
	$index += $fileLines
}
$index | Set-Content -Path ($destination + $fileName)