param(
    [switch]$Help,
    [switch]$Clear,
    [switch]$Force,
    [switch]$Debug,
    [switch]$Glzr
)

$OldConfigs = Join-Path $PSScriptRoot 'old'

# Every entry is a path relative to this repo. It is copied to the same
# relative path under %USERPROFILE%.
$WindowsConfigs = @(
    '.emacs.local'
    '.emacs.rc'
    '.emacs.snippets'
    '.emacs'
    '.emacs.custom.el'
    '.gitconfig'
    '.gitignore'
    '_vimrc'
)

if ($Glzr) {
    $WindowsConfigs += '.glzr'
}

function Write-DebugMsg {
    param([string]$Message)
    if ($Debug) {
        Write-Host "[debug] $Message"
    }
}

# Returns $true if the path was a symlink/junction and has been removed.
# Only the link itself is deleted, never the directory/file it points to.
function Remove-ReparsePoint {
    param([string]$Path)

    $item = Get-Item -Force -LiteralPath $Path -ErrorAction SilentlyContinue
    if ($null -eq $item) {
        return $false
    }
    if (-not $item.Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint)) {
        return $false
    }

    Write-DebugMsg "Removing stale link: $Path"
    if ($item.PSIsContainer) {
        [System.IO.Directory]::Delete($Path)
    }
    else {
        [System.IO.File]::Delete($Path)
    }
    return $true
}

function Push-Files {
    Write-Host "Deploying configs to $env:USERPROFILE"

    foreach ($item in $WindowsConfigs) {
        $source = Join-Path $PSScriptRoot $item
        $destination = Join-Path $env:USERPROFILE $item

        Write-DebugMsg "Source: $source"
        Write-DebugMsg "Destination: $destination"

        if (-not (Test-Path -LiteralPath $source)) {
            Write-Warning "Missing source: $source"
            continue
        }

        # A dangling symlink/junction left over from an old repo location
        # makes Copy-Item fail. Remove the link itself before copying.
        if (Remove-ReparsePoint -Path $destination) {
            Write-DebugMsg "Removed stale link at $destination"
        }

        try {
            Copy-Item -LiteralPath $source -Destination $env:USERPROFILE -Recurse -Force -ErrorAction Stop
            Write-DebugMsg "Copied: $item"
        }
        catch {
            Write-Warning "Failed to copy ${item}: $($_.Exception.Message)"
        }
    }
}

function Remove-OldFiles {
    if (-not (Test-Path -LiteralPath $OldConfigs)) {
        Write-Warning "Old configs directory not found: $OldConfigs"
        return
    }

    $names = Get-ChildItem -LiteralPath $OldConfigs -Force | Select-Object -ExpandProperty Name
    Write-DebugMsg "Files in old dir: $($names -join ', ')"

    foreach ($dir in @($env:USERPROFILE, $env:APPDATA)) {
        foreach ($name in $names) {
            $path = Join-Path $dir $name
            if ($null -eq (Get-Item -Force -LiteralPath $path -ErrorAction SilentlyContinue)) {
                Write-DebugMsg "Not present: $path"
                continue
            }

            if (-not (Remove-ReparsePoint -Path $path)) {
                Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction SilentlyContinue
            }
            Write-DebugMsg "Removed: $path"
        }
    }
}

function Show-Help {
    Write-Host @'
---HELP---
-help, -h       print info about program
-clear, -cl     remove all configs and plugins
-debug, -d      debug mode
-force, -f      delete old files and push newer
-glzr           also deploy .glzr (GlazeWM/Zebar)
'@
}

if ($Help) {
    Show-Help
    exit 0
}

if ($Clear) {
    Write-Host 'clearing...'
    Remove-OldFiles
    exit 0
}

if ($Force) {
    Write-Host 'Deleting the old config and push newer'
    Remove-OldFiles
}

Push-Files
