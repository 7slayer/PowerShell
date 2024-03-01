$path = '\Backup\Corrected\'
$destination = '\Backup\Validation\'

$files = @(
	[pscustomobject]@{Index = '214203'; DataSet = '202401'; DocumentCount = 0; IndexCount = 0},
	[pscustomobject]@{Index = '436195'; DataSet = '202312'; DocumentCount = 0; IndexCount = 0},
	[pscustomobject]@{Index = '905419'; DataSet = '202311'; DocumentCount = 0; IndexCount = 0},
	[pscustomobject]@{Index = '202009'; DataSet = '202009'; DocumentCount = 0; IndexCount = 0})



ForEach($file in $files) {

	$indexFiles = Get-ChildItem -Path ($path + '*' + $file.Index + '*')
	$DocumentCount = 0
	$printFile = @()
	$indexCount = 0
	ForEach($index in $indexFiles) {
		$fileLines = $index | Get-Content | Measure-Object -Line | Select-Object -ExpandProperty Lines
		$dataSetValues = [pscustomobject]@{FileName = $index.Name; DocCount = $fileLines}
		$printFile += @($dataSetValues)
		$documentCount += $fileLines
		$indexCount++
	}
	#Write-Host( $file.DataSet + ': ' + $documentCount) -ForegroundColor green
	$fileName = 'indexCount_' + $file.DataSet + 'COR.txt'
	$file.DocumentCount = $documentCount
	$file.IndexCount = $indexCount
	$totalCount = [pscustomobject]@{FileName = $fileName; DocCount = $documentCount}
	$printFile += @($totalCount)
	$printFile | Export-CSV -Path ($destination + $fileName) -NoTypeInformation
}
$files | Format-Table
$files | Out-File -FilePath ($destination + 'CORSummary.txt')