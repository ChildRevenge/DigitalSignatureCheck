# Get the current user's username
$currentUsername = $env:USERNAME

# Define the list of folders to scan, including the Music folder
$foldersToScan = @(
    "C:\Program Files\SystemInformer\plugins",
    "C:\Program Files\Process Hacker 2\plugins",
    "C:\Users\$currentUsername\Music",
    "C:\Windows\System32",
    "C:\Users\$currentUsername\AppData\Roaming\Spotify",
    "C:\Users\$currentUsername\AppData\Roaming\discord",
    "C:\Users\$currentUsername\AppData\Local\Discord"
)

# Define the destination directory for copied files
$destinationDirectory = [System.IO.Path]::Combine($env:APPDATA, 'Revenge')

# Define a list of excluded file paths
$excludedPaths = @(
    'C:\Program Files\SystemInformer\plugins\DotNetTools.dll',
    'C:\Program Files\SystemInformer\plugins\ExtendedNotifications.dll',
    'C:\Program Files\SystemInformer\plugins\ExtendedServices.dll',
    'C:\Program Files\SystemInformer\plugins\ExtendedTools.dll',
    'C:\Program Files\SystemInformer\plugins\HardwareDevices.dll',
    'C:\Program Files\SystemInformer\plugins\NetworkTools.dll',
    'C:\Program Files\SystemInformer\plugins\OnlineChecks.dll',
    'C:\Program Files\SystemInformer\plugins\ToolStatus.dll',
    'C:\Program Files\SystemInformer\plugins\Updater.dll',
    'C:\Program Files\SystemInformer\plugins\UserNotes.dll',
    'C:\Program Files\SystemInformer\plugins\WindowExplorer.dll',
    'C:\Windows\System32\d3dref9.dll',
    'C:\Windows\System32\gameplatformservices.dll',
    'C:\Windows\System32\TimelineExplorer\Plugins\TLEFileEZTools.dll'
)

# Ensure the destination directory exists; create it if necessary
if (-not (Test-Path -Path $destinationDirectory)) {
    New-Item -ItemType Directory -Path $destinationDirectory | Out-Null
}

# Loop through each folder and its subfolders
foreach ($folder in $foldersToScan) {
    Write-Host "Scanning folder: $folder"
    $files = Get-ChildItem -Path $folder -File -Recurse -Include *.dll, *.exe

    # Process each .dll and .exe file found in the folder and its subfolders
    foreach ($file in $files) {
        $filePath = $file.FullName
        $attributes = (Get-Item $filePath).Attributes
        $signature = Get-AuthenticodeSignature -FilePath $filePath

        # Check if the file is hidden and has the system attribute, and if it's unsigned
        if (($attributes -band [System.IO.FileAttributes]::Hidden) -and ($attributes -band [System.IO.FileAttributes]::System) -and (-not $signature) -and $filePath -notin $excludedPaths) {
            Write-Host "Unsigned file with both hidden and system attributes found: $filePath"
            # You can perform actions on the found file here
        }
        elseif ($signature.Status -ne 'Valid' -and $filePath -notin $excludedPaths) {
            Write-Host "Copying file $filePath to $destinationDirectory..."
            Copy-Item -Path $filePath -Destination $destinationDirectory -Force
        }
    }
}

Write-Host "Unsigned files with both hidden and system attributes have been processed."

# Open the destination directory in Windows Explorer
Invoke-Item -Path $destinationDirectory
