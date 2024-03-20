param (
	[string]$DataSet = '',
	[string]$ReportPath = '',
	[string[]]$Exclude = @()
)
$reportFiles = @()
$fileName = @()
$searchPattern = '92278.P.DOC.' + $DataSet + '??_92278DOC'
$reportFiles = & '.\llGetFileByContentsV1.1[AppName].ps1' -Search $searchPattern -Path $ReportPath
if ($reportFiles.Count -eq 0) {
	$searchPattern = '92278.P.DOC.' + $DataSet + '??_92278DOC'
	$reportFiles = & '.\llGetFileByContentsV1.1[AppName].ps1' -Search $searchPattern -Path $ReportPath
}
if ($reportFiles.Count -eq 0) {
	$searchPattern = '92278.Flagstar_STM_' + $DataSet + '_Doc'
	$reportFiles = & '.\llGetFileByContentsV1.1[AppName].ps1' -Search $searchPattern -Path $ReportPath
}
if ($reportFiles.Count -eq 0) {
	$searchPattern = '92278.' + $DataSet + '_Doc'
	$reportFiles = & '.\llGetFileByContentsV1.1[AppName].ps1' -Search $searchPattern -Path $ReportPath
}
if ($reportFiles.Count -eq 0) {
	$searchPattern = '92278..P.DOC.' + $DataSet + '_DOC'
	$reportFiles = & '.\llGetFileByContentsV1.1[AppName].ps1' -Search $searchPattern -Path $ReportPath
	$reportFiles.Count
}

if ($reportFiles.Count -eq 0) {
	$searchPattern = '92278.P.DOC.' + $DataSet + '_STM'
	$reportFiles = & '.\llGetFileByContentsV1.1[AppName].ps1' -Search $searchPattern -Path $ReportPath
}

	ForEach ($file in $reportFiles){
		$fileName = $file.Name -Replace 'report', ''
		if ($PSBoundParameters.ContainsKey("Exclude")) {
			$matchedDataSet += & '.\llGetContentByFileV1.1[AppName].ps1' -Search $searchPattern -Filter $fileName -Path $reportFiles.DirectoryName -Exclude $Exclude
		} else {
			$matchedDataSet += & '.\llGetContentByFileV1.1[AppName].ps1' -Search $searchPattern -Filter $fileName -Path $reportFiles.DirectoryName
		}
	}
ForEach ($match in $matchedDataSet) {
	if ($match.Line -like '*Removed the following item: @*' -or $match.Line -like '*Invalid date format: *') {
		$matchedBadDates += @(
		[pscustomobject]@{
			Directory = $match.Directory
			FileName = $match.FileName
			Line = $match.Line
			}
		)
	}
}

$matchedBadDates | Export-Csv -Path "D:\NAPRD\IVR\Reports\Processing_REP\Backup\Validation\report$DataSet BAD_1.txt" -NoTypeInformation
return $matchedBadDates