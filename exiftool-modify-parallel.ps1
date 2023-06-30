param (
    [string]$Path = (Get-Location),
    [int]$Threads = 20
)
# Define the directory containing the image files
$DirectoryPath = $Path

# Specify the image file extensions
$ImageFileExtensions = @('*.jpg', '*.jpeg', '*.jpe', '*.jfif', '*.png', '*.bmp', '*.dib', '*.rle', '*.gif', '*.ico', '*.heic', '*.heif', '*.ind', '*.indd', '*.indt', '*.jp2', '*.j2k', '*.jpf', '*.jpx', '*.jpm', '*.mj2', '*.svg', '*.svgz', '*.tif', '*.tiff', '*.wdp', '*.webp')

# Initialize an empty array to store image files
$ImageFiles = @()

# Initialize an empty hashtable to store the count of each image extension type
$ImageFileExtensionCounts = @{}

# Get all image files in the directory for each file extension
foreach ($ImageFileExtension in $ImageFileExtensions) {
    $Files = Get-ChildItem -Path $DirectoryPath -File -Filter $ImageFileExtension -Recurse
    if ($Files.Count -gt 0) {
        $ImageFiles += $Files
        $ImageFileExtensionCounts[$ImageFileExtension] = $Files.Count
    }
}

# Log the count of each image extension type
$CurrentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Output "$CurrentDateTime - Found the following image file extension counts:"
foreach ($ImageFileExtensionCount in $ImageFileExtensionCounts.GetEnumerator()) {
    Write-Output "$($ImageFileExtensionCount.Key): $($ImageFileExtensionCount.Value)"
}

# Iterate over each image file
$ImageFiles | ForEach-Object -ThrottleLimit $Threads -Parallel {
    # Extract the date/time from the image file name
    $DateTime = $_.BaseName -replace ".*(\d{8}_\d{6}).*", '$1'
    # Format the date/time for ExifTool
    # $DateTimeFormatted = $DateTime.Insert(4, ":").Insert(7, ":").Insert(10, " ").Insert(13, ":").Insert(16, ":")
    $DateTimeFormatted = $DateTime

	  # Set the creation date/time metadata of the image file
    $ExifToolArguments = "-DateTimeOriginal=$DateTimeFormatted", "-CreateDate=$DateTimeFormatted", "-ModifyDate=$DateTimeFormatted", $_.FullName
    Write-Output "Arguments: $ExifToolArguments"
    & exiftool $ExifToolArguments

    # Log the modification
    $CurrentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "$CurrentDateTime - Image: $($_.Name) changed to $DateTimeFormatted"
}