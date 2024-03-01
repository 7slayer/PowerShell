$source = ''
$destinationProcessed = ''
$destinationProcessing = ''
$destinationProcessingPDF = ''
$destinationProcessingDupes = $destinationProcessingPDF + 'dupes\'

$existingFiles = Get-ChildItem -Path ($destinationProcessed + '*.zip')

$sourceFiles = Get-ChildItem -Path ($source + '*.zip') | Sort-Object -Descending | Select-Object -First 100

$sourceFiles | ForEach-Object {
	if( -Not ($existingFiles.Name -contains $_.Name)) {
		$indexFile = $_.Name.Replace('.zip', '_index.txt')
		$zipFile = $_.Name
		$tempDirectory = New-Item -ItemType Directory -Path $destinationProcessing -Name $_.BaseName
	
		try {
			Expand-Archive -Path $_.FullName -DestinationPath $tempDirectory.FullName -Force
			$_ | Move-Item -Destination $destinationProcessed -ErrorAction Stop
			$fileExpandedList = Get-ChildItem -Path $tempDirectory -Recurse | Sort-Object -Descending
			$fileExpandedList | Set-Content -Path ($destinationProcessing + $indexFile)
			$pdfList = Get-ChildItem -Path ($tempDirectory.FullName + '\*.pdf')
		ForEach ($pdf in $pdfList){
			try {
				$pdf | Move-Item -Destination $destinationProcessingPDF -ErrorAction Stop
			} catch {
				Write-Host($pdf.Name + ' is a duplicate and has been moved to the duplicate folder')
				Move-Item -Path $pdf.FullName -Destination $destinationProcessingDupes
			}	
		}
		} catch {
			Write-Host ($zipFile + ' failed')
		}
	
		if ((Get-ChildItem -Path $tempDirectory -Recurse) -eq $null) {
			Remove-Item -Path $tempDirectory -Recurse
		} else {
			Write-Host('Items remain in ' + $tempDirectory)
		}
	} else {
		Write-Host($_.Name + ' has already been processed')
	}
}
