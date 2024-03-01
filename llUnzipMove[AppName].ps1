$source = ''
$destinationProcessed = ''
$destinationProcessing = ''
$destinationProcessingPDF = '\PDFs\'
$destinationProcessingDupes = $destinationProcessingPDF + 'dupes\'

$existingFiles = Get-ChildItem -Path ($destinationProcessed + '*.zip')

$sourceFiles = Get-ChildItem -Path ($source + '*.zip') | Sort-Object -Descending | Select-Object -First 2000

$sourceFiles | ForEach-Object {
	
	#$indexFile = $_.Name.Replace('.zip', '_index.txt')
	$zipFile = $_.Name
	if ( -Not ($existingFiles.Name -contains $_.Name)){
		$tempDirectory = New-Item -ItemType Directory -Path $destinationProcessing -Name $_.BaseName
	
		try {
			
			Expand-Archive -Path $_.FullName -DestinationPath $tempDirectory.FullName -Force
			#$fileExpandedList = Get-ChildItem -Path $tempDirectory -Recurse | Sort-Object -Descending
			$_ | Move-Item -Destination $destinationProcessed
			
		} catch {
			Write-Output ($zipFile + ' failed')
		}

		
		#$fileExpandedList | Set-Content -Path ($destinationProcessing + $indexFile)
		$txtList = Get-ChildItem -Path ($tempDirectory.FullName + '\*.txt')
		ForEach ($txt in $txtList){
			try {
				$txt | Move-Item -Destination $destinationProcessing
			} catch {
				Write-Host('Failed to move the following txt file ' + $txt.Name + 'item will remain in temp folder')
			}	
		}
		
		$pdfList = Get-ChildItem -Path ($tempDirectory.FullName + '\*.pdf')
		ForEach ($pdf in $pdfList){
			try {
				$pdf | Move-Item -Destination $destinationProcessingPDF -ErrorAction Stop
			} catch {
				Write-Host($pdf.Name + ' is a duplicate and has been moved to the duplicate folder')
				Move-Item -Path $pdf.FullName -Destination $destinationProcessingDupes
			}	
		}
		
		if ((Get-ChildItem -Path $tempDirectory -Recurse) -eq $null) {
			Remove-Item -Path $tempDirectory -Recurse
		} else {
			Write-Host('Items remain in ' + $tempDirectory)
		}
	} else {
			Write-Output ($_.Name + ' Has already been processed')
		}

}

