$delimiter = '_'
$dateFormat = 'MM-dd-yyyy'
[String[]] $errorDate = @('yyyyMMdd', 'MMddyyyy','MMddyy', 'Mddyyyy')
$headers = @('Account', 'Date', 'File')
$sourcePath = 'D:\naprd\IVR\Reports\Processing_REP\'
$destinationPath = 'D:\naprd\IVR\Reports\Processing_REP\REP_00@\'
$indexFile = Get-ChildItem -Path *.txt | Select-Object -Property Name, FullName
$processingNum = 4
$count1 = 1
$badDateFile = 'badDate2.txt'
$badDatePath = '\backup\badDate\'
$reportFile = 'report2.txt'
$reportPath = 'backup\report\'
$reportText = @('Report on Index Correction')
$correctedPath = ''

ForEach ($index in $indexFile) {
	$sourceIndexPath = $index.FullName
	#$extension = '*.pdf'
	#$dirFiles = Get-ChildItem -Path $extension | Select-Object -ExpandProperty FullName
	$sourceFiles = Get-Content -Path $sourceIndexPath
	$sourceIndex = Import-Csv -Path $sourceIndexPath -Delimiter $delimiter -Header $headers
	$count2 = 0
	
	ForEach ($file in $SourceIndex) {
		#$fullFile = $dirFiles | Where-Object {$_ -like ('*' + $file.File)}
		
		$fullFile = ($sourcePath + $sourceFiles[$count2])
		$uncFile = $fullFile.Replace('D:', '\\SNTNYCBISFS01')
		$account = $file.Account
		$correctedAccount = $account.Replace('X', '').Replace(',', '')
		
		$file.File = $uncFile
		$file.Account = $correctedAccount
		
		if ($correctedAccount -notmatch "[a-zA-Z]") {
			
			if ($file.Date.Length -gt 6) {
				try {
					$date = [DateTime]::Parse($file.Date)
					$file.Date = $date.ToString($dateFormat)
				} catch {
					try {
						$date = [DateTime]::ParseExact($file.Date, $errorDate, [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None)
						$file.Date = $date.ToString($dateFormat)
					} catch {
						Write-Host ('invalid date format: ' + $file.Date + ' The following file has been removed ' + $file.Name)
						$reportText += @('Invalid date format: ' + $file.Date + ' ' + $index.Name)
					}
				}
			} else {
				$file | Export-Csv -Path ($badDatePath + $badDateFile) -Append -NoTypeInformation -Delimiter '_'
				$reportText += @('Removed the following item: ' + $file + ' ' + $index.Name)
				Write-Host ('Removed the following item: ' + $file)
				$file.Date = $null
			}
		} else {
			Write-Host ('Account #: ' + $account + ' should not contain letters')
			$reportText += @('Account #: ' + $account + ' should not contain letters ' + $index.Name)
			$file.Account = $null
		}
		
		$count2++
	}
	
	$destination = $destinationPath.Replace('@', $count1) + 'CORRECTED_' + $index.Name
	Write-Host ($index.FullName + ' has been corrected')
	Move-Item -Path $index.FullName -Destination $correctedPath
	$filteredIndex = $sourceIndex | Where-Object {$_.Date -ne $null -or $_.Account -ne $null} | ConvertTo-Csv -NoType | Select-Object -Skip 1 #| Select-Object -SkipLast 2
	$filteredIndex | Set-Content -Path $destination
	$reportText | Set-Content -Path ($reportPath + $reportFile)
	
	if ($count1 -lt $processingNum) {
		$count1++
	} else {
		$count1 = 1
	}
}