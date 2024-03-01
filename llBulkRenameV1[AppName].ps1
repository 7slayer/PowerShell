$path = ''
$files = Get-ChildItem -Path $path | Select-Object Name, FullName
$files.Name
Read-Host 'Press enter to rename the above items or CTRL+C to exit.\n'
Foreach ($file in $files){
	$correctedName = $file.Name.Replace('','')
	Rename-Item -Path $file.FullName -NewName $correctedName
}
