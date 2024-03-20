param (
[string]$DataSet = '202401',
[string]$ReportPath = 'D:\NAPRD\IVR\Reports\Processing_REP\Backup\Report',
[string[]]$Exclude = @(),
[int]$IndexCount = 1
)
if ($PSBoundParameters.ContainsKey("Exclude")) {
	$reportFiles = @(& '.\llGetBadReportV1.2[REP].ps1' -DataSet $DataSet -ReportPath $ReportPath -IndexCount $IndexCount -Exclude $Exclude)
} else {
	$reportFiles = @(& '.\llGetBadReportV1.2[REP].ps1' -DataSet $DataSet -ReportPath $ReportPath -IndexCount $IndexCount)
}
$splitDataSet = $DataSet -split "(?<=^\d{4})"

$searchPattern = $splitDataSet[1] + '-*-' + $splitDataSet[0]

[pscustomobject[]]$matchedLines = @()
ForEach ($file in $reportFiles) {
		$fileSearch = ''
		$fileName = ''
		$filePath = ($file | Select-Object -ExpandProperty Directory) -Replace 'Report$', 'badDate'
		if ($file | Select-Object -ExpandProperty Line | Select-String -Pattern '(?<=@{Account=)\d+' -Quiet) { 
			$fileName = ($file | Select-Object -ExpandProperty FileName) -Replace 'report', '_*'
			$fileSearch = ($file | Select-Object -ExpandProperty Line | Select-String -Pattern '(?<=@{Account=)\d+').Matches.Value
		} elseif ($file | Select-Object -ExpandProperty Line | Select-String -Pattern '(?<=Invalid date format: )\d+' -Quiet) {
			$fileName = ($file | Select-Object -ExpandProperty FileName) -Replace 'report', ''
			$fileSearch = ($file | Select-Object -ExpandProperty Line | Select-String -Pattern '(?<=Invalid date format: )\d+').Matches.Value
		} else {
			"No good search patterns for $file"
			$matchedLines += @([pscustomobject]@{
				Line = "No good search patterns for $file.Line"
			})
		}
		if ($fileName -ne '' -and $fileSearch -ne '') {
			if ($PSBoundParameters.ContainsKey("Exclude")) {
				$matchedLines += [pscustomobject]@(&'.\llGetContentByFileV1.1[AppName].ps1' -Search $fileSearch -Filter $fileName -Path $filePath -OneMatch -Exclude $Exclude)
			} else {
				$matchedLines += [pscustomobject]@(&'.\llGetContentByFileV1.1[AppName].ps1' -Search $fileSearch -Filter $fileName -Path $filePath -OneMatch)
			}
	
		}
}

ForEach ($line in $matchedLines) {
	$line.Line = $line.Line -Replace '"', ''
}

$matchedLines | Export-Csv -Path "D:\NAPRD\IVR\Reports\Processing_REP\Backup\Validation\index$DataSet BAD_1.txt" -NoTypeInformation
return $matchedLines