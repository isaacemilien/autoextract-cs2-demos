# Define the path to the folder to monitor and the destination path
$sourcePath = ""
$destinationPath = ""

# Create the FileSystemWatcher object
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $sourcePath
$watcher.Filter = "*.*"  # Monitor all files
$watcher.NotifyFilter = [System.IO.NotifyFilters]::FileName -bor [System.IO.NotifyFilters]::LastWrite

# Function to rename an item with a numeric suffix if the name already exists
function Rename-ItemWithSuffix {
    param (
        [string]$Path,
        [string]$NewName
    )

    # Get the directory and original name
    $directory = [System.IO.Path]::GetDirectoryName($Path)
    $extension = [System.IO.Path]::GetExtension($NewName)
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($NewName)
    
    # Initial target name
    $targetName = $NewName
    $suffix = 2

    # Check if the target name already exists
    while (Test-Path -Path (Join-Path -Path $directory -ChildPath $targetName)) {
        $targetName = "$baseName-$suffix$extension"
        $suffix++
    }

    # Perform the renaming
    $newPath = Join-Path -Path $directory -ChildPath $targetName
    Rename-Item -Path $Path -NewName $targetName

    # Return the new path
    return $newPath
}

# Define the action to take when a file is renamed (indicating a completed download)
$action = {
    $name = $Event.SourceEventArgs.Name
    $changeType = $Event.SourceEventArgs.ChangeType
    $timeStamp = $Event.TimeGenerated

    if ($name -like "*.dem.gz") {
        # Construct full paths for source and destination
        $sourceFile = Join-Path -Path $sourcePath -ChildPath $name
        $destinationFile = Join-Path -Path $destinationPath -ChildPath $name
        $extractedFile = $destinationFile -replace '\.gz$', ''

        # Perform actions
        Write-Output "File '$name' was $changeType at $timeStamp"
        
        # Move the file
        Move-Item -Path $sourceFile -Destination $destinationPath

        # Extract the .gz file
        try {
            Write-Output "Extracting $destinationFile to $extractedFile"
            $gzipStream = [System.IO.Compression.GzipStream]::new([System.IO.File]::OpenRead($destinationFile), [System.IO.Compression.CompressionMode]::Decompress)
            $fileStream = [System.IO.File]::Create($extractedFile)
            $gzipStream.CopyTo($fileStream)
            $gzipStream.Close()
            $fileStream.Close()
            Write-Output "Extraction complete for $destinationFile"

            # Delete the .gz file after extraction
            Remove-Item -Path $destinationFile
            Write-Output "Deleted $destinationFile"

            # Rename the extracted file to ensure it has a unique name
            Rename-ItemWithSuffix -Path $extractedFile -NewName "demo.dem"

        }
        catch {
            Write-Error "Failed to extract"
        }
    }
}

# Register the event handler for renamed events (finalize download)
Register-ObjectEvent -InputObject $watcher -EventName "Renamed" -Action $action
$watcher.EnableRaisingEvents = $true

# Keep the script running
while ($true) { Start-Sleep -Seconds 1 }
