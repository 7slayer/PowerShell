$delimiter = '_'
$dateFormat = 'MM-dd-yyyy'
$currentDateTime = Get-Date -Format 'MM-dd-yyyy HH-mm'
[String[]] $errorDate = @('yyyyMMdd', 'MMddyyyy','MMddyy', 'Mddyyyy', 'dMMyyyy')
$headers = @('Account', 'Date', 'File')
$sourcePath = ''
$sourcePDFPath = $sourcePath + 'PDFs\'
$destinationPath = '00@\'
$indexFile = Get-ChildItem -Path *.txt | Sort-Object -Descending | Select-Object -Property Name, FullName -First 200
$processingNum = 4
$count1 = 1
$fileCount = 0
$noDateFile = 'noDate' + $currentDateTime + '.txt'
$badDateFile = 'badDate' + $currentDateTime + '.txt'
$badDatePath = 'D:\naprd\IVR\Reports\Processing_STM\backup\badDate\'
$reportFile = 'report' + $currentDateTime + '.txt'
$reportPath = '\backup\report\'
$reportText = @('Report on Index Correction')
$correctedOriginal = '\Backup\Corrected\Original\'
$correctedPath = '\Backup\Corrected\'

ForEach ($index in $indexFile) {
	$sourceIndexPath = $index.FullName
	#$extension = '*.pdf'
	#$dirFiles = Get-ChildItem -Path $extension | Select-Object -ExpandProperty FullName
	$sourceFiles = Get-Content -Path $sourceIndexPath
	$sourceIndex = Import-Csv -Path $sourceIndexPath -Delimiter $delimiter -Header $headers
	$count2 = 0
	
	ForEach ($file in $SourceIndex) {
		#$fullFile = $dirFiles | Where-Object {$_ -like ('*' + $file.File)}
		
		$fullFile = ($sourcePDFPath + $sourceFiles[$count2])
		$uncFile = $fullFile.Replace('D:', '')
		$account = $file.Account
		$correctedAccount = $account.Replace('X', '').Replace(',', '').Replace('-', '').Replace('.PDF', '')
		
		$file.File = $uncFile
		$file.Account = $correctedAccount
		
		if ($correctedAccount -notmatch "[a-zA-Z]") {
			
			if ($file.Date.Length -ne 0) {
				try {
					$date = ($file.Date).Replace('.PDF', '')
					$formatedDate = [DateTime]::Parse($date)
					$file.Date = $formatedDate.ToString($dateFormat)
				} catch {
					try {
						$formatedDate = [DateTime]::ParseExact($date, $errorDate, [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None)
						$file.Date = $formatedDate.ToString($dateFormat)
					} catch {
						$file | Export-Csv -Path ($badDatePath + $badDateFile) -Append -NoTypeInformation -Delimiter '_'
						Write-Host ('invalid date format: ' + $date + ' The following file has been removed ' + $file.Name) -ForegroundColor Red
						$reportText += @('Invalid date format: ' + $date + ' ' + $index.Name)
						$file.Date = $null
					}
				}
			} else {
				$file | Export-Csv -Path ($badDatePath + $noDateFile) -Append -NoTypeInformation -Delimiter '_'
				$reportText += @('Removed the following item: ' + $file + ' ' + $index.Name)
				Write-Host ('Removed the following item: ' + $file) -ForegroundColor Red
				$file.Date = $null
			}
		} else {
			Write-Host ('Account #: ' + $account + ' should not contain letters') -ForegroundColor Red
			$reportText += @('Account #: ' + $account + ' should not contain letters ' + $index.Name)
			$file.Account = $null
		}
		$count2++
	}
	
	$combinedDestination = $destinationPath.Replace('@', $count1) + 'CORRECTED_' + $currentDateTime + '.txt'
	$individualDestination = $correctedPath + 'CORRECTED_' + $index.Name
	Write-Host ($index.FullName + ' has been corrected and moved to process number ' + $count1)
	$reportText += @($index.FullName + ' has been corrected and moved to process number ' + $count1)
	Move-Item -Path $index.FullName -Destination $correctedOriginal
	
	$filteredIndex = $sourceIndex | Where-Object {($_.Account -ne $null)} | Where-Object {($_.Date -ne $null)} | ConvertTo-Csv -NoType | Select-Object -Skip 1 #| Select-Object -SkipLast 2
	try {
		$filteredIndex | Set-Content -Path $individualDestination -ErrorAction Stop
	} catch {
		Write-Host ($_.Exception.Message + $index.FullName + ' was not able to be added to process ' + $count1) -ForegroundColor Red
		$reportText += @($index.FullName + ' was not able to be added to process ' + $count1)
	}
	$filteredIndex | Out-File -FilePath $combinedDestination -Append
	$reportText | Set-Content -Path ($reportPath + $reportFile)
	if ($count1 -le $processingNum) {
		if ($fileCount -le 50) {
			$fileCount++
		} else {
			$count1++
			$fileCount = 0
		}
	} else {
		$count1 = 1
	}
}