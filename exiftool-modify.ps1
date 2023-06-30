param (
    [string]$Path = (Get-Location)
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
foreach ($ImageFile in $ImageFiles) {
    # Extract the date/time from the image file name
    $DateTime = $ImageFile.BaseName -replace ".*(\d{8}_\d{6}).*", '$1'
    # Format the date/time for ExifTool
    $DateTimeFormatted = $DateTime.Insert(4, ":").Insert(7, ":").Insert(10, " ").Insert(13, ":")

    # Get the existing metadata dates
    $ExistingDates = & exiftool -DateTimeOriginal -CreateDate -ModifyDate -d "%Y:%m:%d %H:%M:%S" $ImageFile | ForEach-Object { ($_ -split ': ')[1] }

    # If all the existing metadata dates are the same as the date we want to set, skip this image file
    if ($ExistingDates -notcontains $DateTimeFormatted) {
	# Set the creation date/time metadata of the image file
	$ExifToolArguments = "-DateTimeOriginal=$DateTimeFormatted", "-CreateDate=$DateTimeFormatted", "-ModifyDate=$DateTimeFormatted", "`"$($ImageFile.FullName)`""
	& exiftool $ExifToolArguments


        # Log the modification
        $CurrentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Output "$CurrentDateTime - Image: $($ImageFile.Name) changed from $ExistingDates to $DateTimeFormatted"
    } else {
        # Log that the image file was skipped
        $CurrentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Output "$CurrentDateTime - Image: $($ImageFile.Name) already has date/time $DateTimeFormatted, skipping."
    }
}