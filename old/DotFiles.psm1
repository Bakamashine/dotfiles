function Symlink-File {
    param(
        [Parameter(Position=0)]$DestPath,
        [Parameter(Position=1)]$SourcePath,
        [switch]$Force
    )
    if (Test-Path $DestPath) {
        if ($Force) {
            Write-Warning "$DestPath already exists. Removing it because of -force flag."
            if ((Get-Item $SourcePath) -is [System.IO.DirectoryInfo]) {
                cmd /c rmdir "$DestPath"
            } else {
                cmd /c del "$DestPath"
            }
        } else {
            Write-Warning "$DestPath is already symlinked"
            return
        }
    }
    if ((Get-Item $SourcePath) -is [System.IO.DirectoryInfo]) {
        cmd /c mklink /D "$DestPath" "$SourcePath"
    } else {
        cmd /c mklink "$DestPath" "$SourcePath"
    }
    echo "$DestPath has been symlinked"
}

function Unsymlink-File {
    $DestPath = $args[0]
    $SourcePath = $args[1]
    if (Test-Path $DestPath) {
        if ((Get-Item $SourcePath) -is [System.IO.DirectoryInfo]) {
            cmd /c rmdir "$DestPath"
        } else {
            cmd /c del "$DestPath"
        }
        echo "$DestPath has been unsymlinked"
    } else {
        Write-Warning "$DestPath doesn't exist"
    }
}

function Deploy-Manifest {
    param(
        [Parameter(Position=0)]$ManifestFile,
        [switch]$Force
    )
    
    echo "Deploying $ManifestFile..."

    $Manifest = Import-Csv -Header ("file", "operation") -Delimiter ("|") -Path ".\$ManifestFile"
    $EmacsHome = $env:HOME
    foreach ($ManifestRow in $Manifest) {
        $DeployFile = $ManifestRow.file
        $DeployOp = $ManifestRow.operation
        $SourcePath = "$PSScriptRoot\$DeployFile"
        $DestPath = "$EmacsHome\$DeployFile"
        switch($DeployOp) {
            "symlink" {
                Symlink-File $DestPath $SourcePath -Force:$Force
            }
    
            "copy" {
                Write-Warning "The 'copy' operation is not implemented yet. Skipping..."
            }
    
            default {
                Write-Warning "Unknown operation $operation. Skipping..."
            }
        }
    }
}

function Undeploy-Manifest {
    $ManifestFile = $args[0]
    
    echo "Undeploying $ManifestFile..."

    $Manifest = Import-Csv -Header ("file", "operation") -Delimiter ("|") -Path ".\$ManifestFile"
    $EmacsHome = $env:HOME
    foreach ($ManifestRow in $Manifest) {
        $DeployFile = $ManifestRow.file
        $DeployOp = $ManifestRow.operation
        $SourcePath = "$PSScriptRoot\$DeployFile"
        $DestPath = "$EmacsHome\$DeployFile"
        switch($DeployOp) {
            "symlink" {
                Unsymlink-File $DestPath $SourcePath
            }
    
            "copy" {
                Write-Warning "The 'copy' operation is not implemented yet. Skipping..."
            }
    
            default {
                Write-Warning "Unknown operation $operation. Skipping..."
            }
        }
    }
}
