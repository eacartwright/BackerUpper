<#
* Flatten everything in top level folder
* Fix installed application list
* Warn if local Dragon is installed
* Add known license locations (Dragon, Adobe, etc.)
* Fix false bookmark backup
* See if there's a License Crawler CLI
* Improve log formatting and information
  * Fix output width (printer info cutoff)
  * Add more information to computer info like model
  * What else would be good to know about the old computer? What would be most helpful?
* Transition to GUI possibly
#>

#$ErrorActionPreference = "SilentlyContinue"
#$host.UI.RawUI.WindowTitle = "BackerUpper"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#################### REPORT ####################
function CreateReport {
    Add-Content -Path $backupFile -Value @'
******************************************
*           Report Information           *
******************************************

'@

    Add-Content -Path $backupFile -Value "Computer:`t$env:COMPUTERNAME"
    Add-Content -Path $backupFile -Value "Taken:`t`t$(Get-Date -Format "M/d/yyyy hh:mm tt")"

    Add-Content -Path $backupFile -Value @'

******************************************
*                Printers                *
******************************************

'@

    $printers = 
    (Get-WmiObject -Class Win32_Printer |
        Where-Object { $_.Name -notmatch "Fax" -and $_.Name -notmatch "XPS" -and $_.Name -notmatch "Microsoft Print to PDF"-and $_.Name -notmatch "OneNote" } |
        Format-Table Name, DriverName, PortName -AutoSize |
        Out-String).Trim()

    if (!$printers) {
        $printers = "No printers found."
    }

    Add-Content -Path $backupFile -Value $printers

    Add-Content -Path $backupFile -Value @'

******************************************
*             Network Drives             *
******************************************

'@

    $networkDrives = 
    (Get-ItemProperty -Path "HKCU:\Network\*" |
        Format-Table PSChildName, RemotePath -AutoSize |
        Out-String).Trim()

    Add-Content -Path $backupFile -Value $networkDrives

    Add-Content -Path $backupFile -Value @'

******************************************
*             Root Structure             *
******************************************

'@

    $rootStructure = 
    (Get-ChildItem "$((Split-Path -Qualifier $env:SystemRoot))\" |
        Format-Table Name, LastWriteTime, Mode -AutoSize |
        Out-String).Trim()

    Add-Content -Path $backupFile -Value $rootStructure

    Add-Content -Path $backupFile -Value @'

******************************************
*              User Folders              *
******************************************

'@

    $userAccounts = 
    (Get-ChildItem -Path C:\Users -Exclude Administrator, Public |
        Sort-Object -Descending LastAccessTime |
        Format-Table Name, LastAccessTime -AutoSize |
        Out-String).Trim()

    Add-Content -Path $backupFile -Value $userAccounts

    Add-Content -Path $backupFile -Value @'

******************************************
*           Installed Programs           *
******************************************

'@

    $installedPrograms = 
    (Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" |
        Where-Object { $null -ne $_.DisplayName } |
        Sort-Object DisplayName |
        Format-Table DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation -AutoSize |
        Out-String -Width 1024).Trim()

    Add-Content -Path $backupFile -Value $installedPrograms

    Add-Content -Path $backupFile -Value @'

******************************************
*            Network Adapters            *
******************************************
'@

    $ipConfig = Invoke-Expression -Command "cmd.exe /C ipconfig /all"

    Add-Content -Path $backupFile -Value $ipConfig

    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Notepad" -Name fWrap -Type DWORD -Value 0 -Force
    Start-Process -FilePath $backupFile -WindowStyle Maximized
}

#################### BACKUP ####################
function BackupData {
    if ($backupMode -eq 1) {
        foreach ($folder in $userFolders) {
            $folderSize = (Get-ChildItem $env:USERPROFILE\$folder -Recurse | Measure-Object Length -Sum).Sum

            if ($folderSize -gt 0) {
                Write-Host "`nCopying $folder..." -NoNewline -ForegroundColor Gray
                New-Item -Path "$backupPath\$env:USERNAME" -ItemType Directory -Force | Out-Null
                robocopy "$env:USERPROFILE\$folder" "$backupPath\$env:USERNAME\$folder" /MT:32 /R:2 /W:2 /E /DCOPY:T /XD $backupFolder /XF desktop.ini BackerUpper.exe /NJH /NJS /NDL /NFL /NP | Out-Null
            }
        }

        Copy-Item "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper*" "$backupPath\$env:USERNAME\Wallpaper.jpg"

        if (Test-Path $env:LOCALAPPDATA\Google\Chrome) {
            New-Item -Path "$backupPath\$env:USERNAME\Exported Bookmarks\Chrome" -ItemType Directory -Force | Out-Null
            Copy-Item "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Bookmarks" "$backupPath\$env:USERNAME\Exported Bookmarks\Chrome"
        }

        if (Test-Path $env:APPDATA\Mozilla\Firefox) {
            $firefoxBookmarks = 
            Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" |
            Select-Object *, @{Name = "Size"; Expression = { (Get-ChildItem $_.FullName -Recurse | Measure-Object Length -Sum).Sum } } |
            Sort-Object -Descending Size |
            Select-Object -First 1 |
            Get-ChildItem |
            Where-Object { $_.Name -match "bookmarkbackups" } |
            Get-ChildItem |
            Sort-Object -Descending LastWriteTime |
            Select-Object -First 1

            if ($firefoxBookmarks) {
                New-Item -Path "$backupPath\$env:USERNAME\Exported Bookmarks\Firefox" -ItemType Directory -Force | Out-Null
                Copy-Item $firefoxBookmarks.FullName "$backupPath\$env:USERNAME\Exported Bookmarks\Firefox" -Recurse -Force
            }
        }

        $shell = New-Object -ComObject "Shell.Application"
        $shell.MinimizeAll()
        Start-Sleep -Seconds 1
    
        $file = "$backupPath\$env:USERNAME\Desktop Screenshot.jpg"
        $screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
        $bitmap = New-Object System.Drawing.Bitmap $screen.Width, $screen.Height
        $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphic.CopyFromScreen(0, 0, 0, 0, $bitmap.Size)
        $bitmap.Save($file, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    
        $shell.UndoMinimizeALL()
    }
}

function BackupMode {
    Write-Host "Choose backup mode:`n" -ForegroundColor Yellow
    Write-Host " [1] Full backup ($(Convert-ToBytes $backupSize))`n [2] Report only"

    $backupMode = Read-Host -Prompt "`nMode"

    Write-Host "`nChoose backup drive:`n" -ForegroundColor Yellow

    if (!$backupMode -or $backupMode -eq 1) {
        $backupMode = 1
        $usbDrives = @()
        Get-WmiObject -Class Win32_LogicalDisk |
        Where-Object { $_.DeviceID -ne "C:" -and $_.FreeSpace -gt ($backupSize + 5MB) }
    }
    else {
        $backupMode = 2
        $usbDrives = @() 
        Get-WmiObject -Class Win32_LogicalDisk |
        Where-Object { $_.DeviceID -ne "C:" -and $_.FreeSpace -gt 5MB }
    }

    for ($i = 1; $i -le $usbDrives.Count; $i++) {
        Write-Host " [$i] $($usbDrives[$i - 1].VolumeName) ($($usbDrives[$i - 1].DeviceID))"
    }

    Write-Host " [$($usbDrives.Count + 1)] Desktop"

    $backupDrive = Read-Host -Prompt "`nDrive"

    if (!$backupDrive) {
        $backupDrive = 1
    }

    $backupFolder = "$($env:COMPUTERNAME) ($(Get-Date -Format "M-d-yyyy"))"

    if ($backupDrive -eq ($usbDrives.Count + 1)) {
        $backupPath = "$env:USERPROFILE\Desktop\$backupFolder"
    }
    else {
        $backupPath = "$($usbDrives[$backupDrive - 1].DeviceID)\$backupFolder"
    }

    $backupFile = "$backupPath\$env:COMPUTERNAME Report ($(Get-Date -Format "M-d-yyyy")).txt"

    if (!(Test-Path $backupPath)) {
        New-Item -Path $backupPath -ItemType Directory | Out-Null
    }
    else {
        Write-Host "`r"
        Write-Warning "A current backup already exists on the $(Split-Path $backupPath -Qualifier) drive. Remove and retry?"
        $backupRemoval = Read-Host "[Y]es/[N]o"
    
        if (!$backupRemoval -or $backupRemoval.ToLower() -eq "y") {
            Remove-Item -Path $backupPath -Recurse -Force
            Start-Sleep -Seconds 1
            New-Item -Path $backupPath -ItemType Directory | Out-Null
        }
        else {
            break
        }
    }
}

$userFolders = @(
    "Desktop"
    "Documents"
    "Downloads"
    "Favorites"
    "Pictures"
    "Videos"
)

function ConvertToBytes {
    param (
        $num
    )
    $suffix = @('B','KB','MB','GB','TB')
    $i = 0
    while ($num -gt 1KB) {
        $num = $num / 1KB
        $i++
    }
    '{0:N1} {1}' -f $num, $suffix[$i]
}
 
function CalculateUserBackups {
    $script:UserBackups = @()
    $enabledUsers = Get-LocalUser |
        Where-Object { $_.Enabled -eq $true -and $_.Name -notlike 'Administrator' } |
        Select-Object -ExpandProperty Name

    foreach ($user in $enabledUsers) {
        if (Test-Path "C:\Users\$user") {
            $totalBackupSize = 0

            foreach ($folder in $userFolders.GetEnumerator()) {
                $totalBackupSize += (Get-ChildItem "C:\Users\$user\$folder" -Recurse |
                    Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            }

            $userBackupSize = ConvertToBytes $totalBackupSize
            $script:UserBackups += [pscustomobject]@{ User = $user; BackupSize = $userBackupSize }
        }
    }
}


CalculateUserBackups

[void][System.Windows.Forms.Application]::EnableVisualStyles()
. (Join-Path $PSScriptRoot 'BackerUpper.designer.ps1')

foreach ($Entry in $UserBackups) {
    $ListView_Item = New-Object System.Windows.Forms.ListViewItem($Entry.User)
    [void]$ListView_Item.SubItems.Add($Entry.BackupSize)
    $lvwSources.Items.AddRange(($ListView_Item))
}

$frmMain.ShowDialog()
