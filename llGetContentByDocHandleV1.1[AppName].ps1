# Define the paths to the input and output files
$KeywordFile = "E:\Nautilus Builds\Sample Files\DIP\dip\Sig Cards\keywords.txt"
$taggedIndexFile = "E:\Nautilus Builds\Sample Files\DIP\dip\Sig Cards\SIGCARDSDIP.TXT"
$newIndexFile = "E:\Program Files\Microsoft VS Code\Workspace\PowerShell\sample.txt"

# Import the document handles from the file
$keywords = Get-Content $KeywordFile
# Initialize an empty array to store the document information


    # Retrieve the document information from the tagged index file
    $tagCount = 0
    $beginTag = "BEGIN:"
    $documentInfo = Get-Content $taggedIndexFile
    $documentInformation = @()
    $document = @()
    ForEach ($line in $documentInfo) {
        if ($line -eq $beginTag) {
            $tagCount++
        }
        if ($tagCount -ne 1) {
            $document += @($line)
        } else {
            $tagCount = 0
            $documentInformation += ,@($document)  # Modified line
            $document = @($line) # Reset $document array
            
        }
    }
# Filter the objects that contain the keyword values
Foreach ($keyword in $keywords) {
    $filteredDocumentInfo += $documentInformation | Where-Object {$_ -match $keyword}
}

# Write the document information to the new index file
$filteredDocumentInfo | Out-File $newIndexFile