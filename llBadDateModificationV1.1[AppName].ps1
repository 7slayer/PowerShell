$file = Get-ChildItem -Path ""

# Read the file
$content = $file | Get-Content

# Define the regular expression pattern
$dateFormat = 'MM-dd-yyyy'
$fileDatePattern = '(?<=_)(\w+_\d{1,2}_\d{3,4})'
$datePattern = '(?<="_")(\w+)(?="_")'

$modifiedIndex = @()
# Process each line in the file
foreach ($line in $content) {
    # Find matches
    $fileDateMatch = ($line | Select-String -Pattern $fileDatePattern).Matches.Value
    $dateMatch = ($line | Select-String -Pattern $datePattern).Matches.Value

    $dateMatch
    $fileDateMatch

	# Replace underscores with dashes
	$match = $fileDateMatch -replace "_", "-"
	$formatedMatch = ([DateTime]::Parse($match).ToString($dateFormat))
	

	# Replace the date in the Date column
	$newLine = ($line -replace $datePattern, $formatedMatch) -Replace '"_"', '","'
	
	$modifiedIndex += @($newLine)
    
}

$modifiedIndex | Set-Content ($file.Directory.ToString() + '\\MOD_' + $file.Name)