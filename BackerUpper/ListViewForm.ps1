Add-Type -AssemblyName System.Windows.Forms

$ListView = New-Object -TypeName System.Windows.Forms.ListView
$ListView.Name = 'ListView'
$ListView.Width = 250
$ListView.Height = 300
$ListView.Location = '10,10'
$ListView.View = 'Details'
$ListView.FullRowSelect = $true

[void]$ListView.Columns.Add('User')
[void]$ListView.Columns.Add('BackupSize')

$Form = New-Object -TypeName System.Windows.Forms.Form
$Form.Name = 'Form'
$Form.Width = 350
$Form.Height = 400
$Form.StartPosition = 'CenterScreen'
$Form.TopMost = $true

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
    $suffix = @('B', 'KB', 'MB', 'GB', 'TB')
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
        Where-Object { $_.Enabled -eq $true } |
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

foreach ($Entry in $UserBackups) {
    $ListView_Item = New-Object System.Windows.Forms.ListViewItem($Entry.User)
    [void]$ListView_Item.SubItems.Add($Entry.BackupSize)
    $ListView.Items.AddRange(($ListView_Item))
}

$ListView.AutoResizeColumns(1)
$Form.Controls.Add($ListView)
#Add-Member -InputObject $Form -Name ListView -Value $ListView -MemberType NoteProperty
[System.Windows.Forms.Application]::EnableVisualStyles()
$Form.ShowDialog()
