$fileNoDate = Get-ChildItem 'badDate02-22-2024 14-46.txt'
$fileDate = Get-ChildItem 'badDate02-22-2024 14-46Dates.txt'

$dateFormat = 'MM-dd-yyyy'
$errorDate = @('yyyyMMdd', 'MMddyyyy','MMddyy', 'Mddyyyy', 'dMMyyyy')

$contentNoDate = $fileNoDate | Get-Content
$contentDate = $fileDate | Get-Content

$count = 0

ForEach ($line in $contentNoDate) {
	Try {
		$newLine = ($line.Replace('""', '"' + [DateTime]::Parse($contentDate[$count]).ToString($dateFormat) + '"'))
	} Catch {
		[DateTime]::ParseExact($contentDate, $errorDate, [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None)
	}
	$modIndex += @($newLine)
	$newLine
	$count++
}

$modIndex | Set-Content -Path ($fileNoDate.Directory.ToString() + '\\MOD_' + $fileNoDate.Name)


