[void][System.Reflection.Assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
[void][System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
$frmMain = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.ListView]$lvwSources = $null
[System.Windows.Forms.ColumnHeader]$colUser = $null
[System.Windows.Forms.ColumnHeader]$colBackupSize = $null
[System.Windows.Forms.Button]$btnBackup = $null
[System.Windows.Forms.Button]$btnReport = $null
[System.Windows.Forms.GroupBox]$gbxSources = $null
[System.Windows.Forms.GroupBox]$gbxDestination = $null
[System.Windows.Forms.ColumnHeader]$colDriveName = $null
[System.Windows.Forms.ListView]$lvwDestination = $null
[System.Windows.Forms.ColumnHeader]$colDriveLetter = $null
[System.Windows.Forms.ColumnHeader]$colDriveSpace = $null
[System.Windows.Forms.Button]$button1 = $null
function InitializeComponent
{
$resources = Invoke-Expression (Get-Content -Path (Join-Path $PSScriptRoot 'BackerUpper.resources.psd1') -Raw)
$btnBackup = (New-Object -TypeName System.Windows.Forms.Button)
$btnReport = (New-Object -TypeName System.Windows.Forms.Button)
$gbxSources = (New-Object -TypeName System.Windows.Forms.GroupBox)
$lvwSources = (New-Object -TypeName System.Windows.Forms.ListView)
$colUser = (New-Object -TypeName System.Windows.Forms.ColumnHeader)
$colBackupSize = (New-Object -TypeName System.Windows.Forms.ColumnHeader)
$gbxDestination = (New-Object -TypeName System.Windows.Forms.GroupBox)
$lvwDestination = (New-Object -TypeName System.Windows.Forms.ListView)
$colDriveLetter = (New-Object -TypeName System.Windows.Forms.ColumnHeader)
$colDriveName = (New-Object -TypeName System.Windows.Forms.ColumnHeader)
$colDriveSpace = (New-Object -TypeName System.Windows.Forms.ColumnHeader)
$gbxSources.SuspendLayout()
$gbxDestination.SuspendLayout()
$frmMain.SuspendLayout()
#
#btnBackup
#
$btnBackup.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]194,[System.Int32]275))
$btnBackup.Name = [System.String]'btnBackup'
$btnBackup.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]80,[System.Int32]28))
$btnBackup.TabIndex = [System.Int32]4
$btnBackup.Text = [System.String]'Backup'
$btnBackup.UseVisualStyleBackColor = $true
#
#btnReport
#
$btnReport.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]108,[System.Int32]275))
$btnReport.Name = [System.String]'btnReport'
$btnReport.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]80,[System.Int32]28))
$btnReport.TabIndex = [System.Int32]5
$btnReport.Text = [System.String]'Report Only'
$btnReport.UseVisualStyleBackColor = $true
#
#gbxSources
#
$gbxSources.Controls.Add($lvwSources)
$gbxSources.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]9,[System.Int32]4))
$gbxSources.Name = [System.String]'gbxSources'
$gbxSources.Padding = (New-Object -TypeName System.Windows.Forms.Padding -ArgumentList @([System.Int32]7,[System.Int32]2,[System.Int32]7,[System.Int32]7))
$gbxSources.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]265,[System.Int32]129))
$gbxSources.TabIndex = [System.Int32]10
$gbxSources.TabStop = $false
$gbxSources.Text = [System.String]'Sources'
#
#lvwSources
#
$lvwSources.CheckBoxes = $true
$lvwSources.Columns.AddRange([System.Windows.Forms.ColumnHeader[]]@($colUser,$colBackupSize))
$lvwSources.FullRowSelect = $true
$lvwSources.HeaderStyle = [System.Windows.Forms.ColumnHeaderStyle]::Nonclickable
$lvwSources.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]10,[System.Int32]18))
$lvwSources.MultiSelect = $false
$lvwSources.Name = [System.String]'lvwSources'
$lvwSources.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]245,[System.Int32]99))
$lvwSources.TabIndex = [System.Int32]12
$lvwSources.UseCompatibleStateImageBehavior = $false
$lvwSources.View = [System.Windows.Forms.View]::Details
#
#colUser
#
$colUser.Text = [System.String]'User'
$colUser.Width = [System.Int32]150
#
#colBackupSize
#
$colBackupSize.Text = [System.String]'Backup Size'
$colBackupSize.Width = [System.Int32]75
#
#gbxDestination
#
$gbxDestination.Controls.Add($lvwDestination)
$gbxDestination.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]9,[System.Int32]139))
$gbxDestination.Name = [System.String]'gbxDestination'
$gbxDestination.Padding = (New-Object -TypeName System.Windows.Forms.Padding -ArgumentList @([System.Int32]7,[System.Int32]2,[System.Int32]7,[System.Int32]7))
$gbxDestination.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]265,[System.Int32]129))
$gbxDestination.TabIndex = [System.Int32]13
$gbxDestination.TabStop = $false
$gbxDestination.Text = [System.String]'Destination'
#
#lvwDestination
#
$lvwDestination.Columns.AddRange([System.Windows.Forms.ColumnHeader[]]@($colDriveLetter,$colDriveName,$colDriveSpace))
$lvwDestination.FullRowSelect = $true
$lvwDestination.HeaderStyle = [System.Windows.Forms.ColumnHeaderStyle]::Nonclickable
$lvwDestination.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]10,[System.Int32]18))
$lvwDestination.MultiSelect = $false
$lvwDestination.Name = [System.String]'lvwDestination'
$lvwDestination.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]245,[System.Int32]99))
$lvwDestination.TabIndex = [System.Int32]12
$lvwDestination.UseCompatibleStateImageBehavior = $false
$lvwDestination.View = [System.Windows.Forms.View]::Details
#
#colDriveLetter
#
$colDriveLetter.Text = [System.String]''
$colDriveLetter.Width = [System.Int32]20
#
#colDriveName
#
$colDriveName.Text = [System.String]'Location'
$colDriveName.Width = [System.Int32]130
#
#colDriveSpace
#
$colDriveSpace.Text = [System.String]'Free Space'
$colDriveSpace.Width = [System.Int32]75
#
#frmMain
#
$frmMain.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]283,[System.Int32]311))
$frmMain.Controls.Add($gbxDestination)
$frmMain.Controls.Add($gbxSources)
$frmMain.Controls.Add($btnReport)
$frmMain.Controls.Add($btnBackup)
$frmMain.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$frmMain.Icon = ([System.Drawing.Icon]$resources.'$this.Icon')
$frmMain.MaximizeBox = $false
$frmMain.Name = [System.String]'frmMain'
$frmMain.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$frmMain.Text = [System.String]'BackerUpper'
$frmMain.TopMost = $true
$gbxSources.ResumeLayout($false)
$gbxDestination.ResumeLayout($false)
$frmMain.ResumeLayout($false)
Add-Member -InputObject $frmMain -Name base -Value $base -MemberType NoteProperty
Add-Member -InputObject $frmMain -Name lvwSources -Value $lvwSources -MemberType NoteProperty
Add-Member -InputObject $frmMain -Name colUser -Value $colUser -MemberType NoteProperty
Add-Member -InputObject $frmMain -Name colBackupSize -Value $colBackupSize -MemberType NoteProperty
Add-Member -InputObject $frmMain -Name btnBackup -Value $btnBackup -MemberType NoteProperty
Add-Member -InputObject $frmMain -Name btnReport -Value $btnReport -MemberType NoteProperty
Add-Member -InputObject $frmMain -Name gbxSources -Value $gbxSources -MemberType NoteProperty
Add-Member -InputObject $frmMain -Name gbxDestination -Value $gbxDestination -MemberType NoteProperty
Add-Member -InputObject $frmMain -Name colDriveName -Value $colDriveName -MemberType NoteProperty
Add-Member -InputObject $frmMain -Name lvwDestination -Value $lvwDestination -MemberType NoteProperty
Add-Member -InputObject $frmMain -Name colDriveLetter -Value $colDriveLetter -MemberType NoteProperty
Add-Member -InputObject $frmMain -Name colDriveSpace -Value $colDriveSpace -MemberType NoteProperty
Add-Member -InputObject $frmMain -Name button1 -Value $button1 -MemberType NoteProperty
}
. InitializeComponent
