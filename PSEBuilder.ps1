#Requires -Version 3.0

<#
.SYNOPSIS
    PowerShell Executor Builder XAML GUI with Debug Logging

.DESCRIPTION
    A modern WPF GUI with comprehensive debug logging to diagnose binding issues.
    Log files are automatically saved to the user's Downloads folder.

.EXAMPLE
    .\PSEBuilder-XAML-Fixed2.ps1
#>

# Set error action preference
$ErrorActionPreference = "Stop"

# Initialize logging
$global:LogFilePath = Join-Path ([Environment]::GetFolderPath('UserProfile')) "Downloads\PSEBuilder-Debug-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$global:LogMessages = @()

function Write-DebugLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $logEntry = "[$timestamp] [$Level] $Message"
    $global:LogMessages += $logEntry
    Write-Host $logEntry -ForegroundColor $(if($Level -eq "ERROR"){"Red"}elseif($Level -eq "WARN"){"Yellow"}else{"Green"})
}

function Save-DebugLog {
    try {
        $global:LogMessages | Out-File -FilePath $global:LogFilePath -Encoding UTF8
        Write-Host "Log saved to: $global:LogFilePath" -ForegroundColor Cyan
    } catch {
        Write-Host "Failed to save log: $_" -ForegroundColor Red
    }
}

Write-DebugLog "=== PSEBuilder XAML GUI Debug Session Started ==="
Write-DebugLog "Log file will be saved to: $global:LogFilePath"

# Add required assemblies
Write-DebugLog "Loading required assemblies..."
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic
Write-DebugLog "All assemblies loaded successfully"

$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="PowerShell Executor Builder - XAML GUI"
        Height="750" Width="1000"
        MinHeight="700" MinWidth="950"
        WindowStartupLocation="CenterScreen"
        Background="#FFF8F9FA">

    <Window.Resources>
        <Style TargetType="GroupBox">
            <Setter Property="Margin" Value="5"/>
            <Setter Property="Padding" Value="10"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="BorderBrush" Value="#FFDEE2E6"/>
            <Setter Property="BorderThickness" Value="1"/>
        </Style>
        <Style TargetType="TabItem">
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="FontSize" Value="12"/>
        </Style>
        <Style TargetType="Button">
            <Setter Property="Margin" Value="5"/>
            <Setter Property="Padding" Value="10,5"/>
            <Setter Property="MinWidth" Value="90"/>
            <Setter Property="Background" Value="#FF007BFF"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontWeight" Value="Bold"/>
        </Style>
        <Style TargetType="TextBox">
            <Setter Property="Margin" Value="5"/>
            <Setter Property="Padding" Value="5"/>
            <Setter Property="BorderBrush" Value="#FFCED4DA"/>
            <Setter Property="BorderThickness" Value="1"/>
        </Style>
        <Style TargetType="ComboBox">
            <Setter Property="Margin" Value="5"/>
            <Setter Property="Padding" Value="5"/>
        </Style>
        <Style TargetType="CheckBox">
            <Setter Property="Margin" Value="5"/>
            <Setter Property="VerticalAlignment" Value="Center"/>
        </Style>
        <Style TargetType="Label">
            <Setter Property="VerticalAlignment" Value="Center"/>
            <Setter Property="Padding" Value="5"/>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Header -->
        <Border Grid.Row="0" Background="#FF343A40" Padding="20">
            <StackPanel>
                <TextBlock Text="PowerShell Executor Builder"
                          FontSize="24" FontWeight="Bold"
                          Foreground="White" HorizontalAlignment="Center"/>
                <TextBlock Text="Create powerful PowerShell executables with embedded resources"
                          FontSize="13" Foreground="#FFE9ECEF"
                          HorizontalAlignment="Center" Margin="0,5,0,0"/>
            </StackPanel>
        </Border>

        <!-- Main Content -->
        <TabControl Grid.Row="1" Margin="15" x:Name="MainTabControl">

            <!-- Basic Configuration Tab -->
            <TabItem Header="Basic Configuration">
                <ScrollViewer VerticalScrollBarVisibility="Auto">
                    <StackPanel Margin="15">

                        <!-- Main Script Selection -->
                        <GroupBox Header="Main PowerShell Script" Margin="0,0,0,15">
                            <Grid>
                                <Grid.RowDefinitions>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="Auto"/>
                                </Grid.RowDefinitions>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="Auto"/>
                                    <ColumnDefinition Width="Auto"/>
                                </Grid.ColumnDefinitions>

                                <TextBox Name="txtMainScript" Grid.Row="0" Grid.Column="0"
                                        IsReadOnly="True" Background="White"
                                        Text="Select your main PowerShell script file (.ps1)"/>
                                <Button Name="btnBrowseMainScript" Grid.Row="0" Grid.Column="1"
                                       Content="Browse..."/>
                                <Button Name="btnClearMainScript" Grid.Row="0" Grid.Column="2"
                                       Content="Clear"/>

                                <TextBlock Grid.Row="1" Grid.ColumnSpan="3"
                                          Text="This script will be executed when your executable runs. You can add additional scripts in the Scripts tab."
                                          FontStyle="Italic" Foreground="Gray" Margin="5,10,5,5"/>
                            </Grid>
                        </GroupBox>

                        <!-- Executable Information -->
                        <GroupBox Header="Executable Information" Margin="0,0,0,15">
                            <Grid>
                                <Grid.RowDefinitions>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="Auto"/>
                                </Grid.RowDefinitions>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="100"/>
                                    <ColumnDefinition Width="2*"/>
                                    <ColumnDefinition Width="80"/>
                                    <ColumnDefinition Width="1*"/>
                                </Grid.ColumnDefinitions>

                                <Label Grid.Row="0" Grid.Column="0" Content="Name:"/>
                                <TextBox Name="txtName" Grid.Row="0" Grid.Column="1" Text="PowerShell Tool"/>
                                <Label Grid.Row="0" Grid.Column="2" Content="Version:"/>
                                <TextBox Name="txtVersion" Grid.Row="0" Grid.Column="3" Text="1.0.0"/>

                                <Label Grid.Row="1" Grid.Column="0" Content="Description:"/>
                                <TextBox Name="txtDescription" Grid.Row="1" Grid.Column="1" Grid.ColumnSpan="3"
                                        Text="Custom PowerShell executable"/>

                                <Label Grid.Row="2" Grid.Column="0" Content="Company:"/>
                                <TextBox Name="txtCompany" Grid.Row="2" Grid.Column="1" Text="Your Company"/>
                                <Label Grid.Row="2" Grid.Column="2" Content="Copyright:"/>
                                <TextBox Name="txtCopyright" Grid.Row="2" Grid.Column="3" Text="2025"/>

                                <Label Grid.Row="3" Grid.Column="0" Content="Icon File:"/>
                                <TextBox Name="txtIcon" Grid.Row="3" Grid.Column="1" Grid.ColumnSpan="2"
                                        IsReadOnly="True" Text="Optional: Select .ico file"/>
                                <Button Name="btnBrowseIcon" Grid.Row="3" Grid.Column="3"
                                       Content="Browse..."/>
                            </Grid>
                        </GroupBox>

                        <!-- Execution Options -->
                        <GroupBox Header="Execution Options" Margin="0,0,0,15">
                            <Grid>
                                <Grid.RowDefinitions>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="Auto"/>
                                </Grid.RowDefinitions>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>

                                <CheckBox Name="chkRequireAdmin" Grid.Row="0" Grid.Column="0"
                                         Content="Require Administrator privileges"/>
                                <CheckBox Name="chkShowWindow" Grid.Row="0" Grid.Column="1"
                                         Content="Show PowerShell window"/>

                                <StackPanel Grid.Row="1" Grid.Column="0" Orientation="Horizontal">
                                    <Label Content="Timeout (minutes):" Width="120"/>
                                    <TextBox Name="txtTimeout" Width="60" Text="5"/>
                                </StackPanel>

                                <StackPanel Grid.Row="1" Grid.Column="1" Orientation="Horizontal">
                                    <Label Content="Execution Policy:" Width="110"/>
                                    <ComboBox Name="cmbExecutionPolicy" Width="140" SelectedIndex="0">
                                        <ComboBoxItem Content="Bypass"/>
                                        <ComboBoxItem Content="Unrestricted"/>
                                        <ComboBoxItem Content="RemoteSigned"/>
                                        <ComboBoxItem Content="AllSigned"/>
                                    </ComboBox>
                                </StackPanel>

                                <StackPanel Grid.Row="2" Grid.ColumnSpan="2" Orientation="Horizontal">
                                    <Label Content="Working Directory:" Width="120"/>
                                    <TextBox Name="txtWorkingDir" Width="300" Text="%TEMP%"/>
                                </StackPanel>
                            </Grid>
                        </GroupBox>

                        <!-- Output Configuration -->
                        <GroupBox Header="Output Configuration">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="100"/>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="Auto"/>
                                </Grid.ColumnDefinitions>

                                <Label Grid.Column="0" Content="Output File:"/>
                                <TextBox Name="txtOutputFile" Grid.Column="1"
                                        IsReadOnly="True" Text="Choose where to save your executable"/>
                                <Button Name="btnBrowseOutput" Grid.Column="2"
                                       Content="Browse..."/>
                            </Grid>
                        </GroupBox>

                    </StackPanel>
                </ScrollViewer>
            </TabItem>

            <!-- Assets Tab -->
            <TabItem Header="Assets">
                <Grid Margin="15">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <TextBlock Grid.Row="0" Text="Resource Files (Images, Configs, Certificates, Data Files)"
                              FontSize="16" FontWeight="Bold" Margin="0,0,0,10"/>

                    <DataGrid Name="dgAssets" Grid.Row="1" Margin="0,0,0,10"
                             AutoGenerateColumns="False" CanUserAddRows="False"
                             SelectionMode="Single" GridLinesVisibility="All"
                             HeadersVisibility="All" AlternatingRowBackground="#FFF8F9FA">
                        <DataGrid.Columns>
                            <DataGridTextColumn Header="File Name" Binding="{Binding Name}" Width="200"/>
                            <DataGridTextColumn Header="File Path" Binding="{Binding FilePath}" Width="400"/>
                            <DataGridTextColumn Header="Type" Binding="{Binding FileType}" Width="100"/>
                            <DataGridTextColumn Header="Size" Binding="{Binding FileSize}" Width="100"/>
                        </DataGrid.Columns>
                    </DataGrid>

                    <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Center">
                        <Button Name="btnAddAsset" Content="Add Files" Margin="5"/>
                        <Button Name="btnRemoveAsset" Content="Remove Selected" Margin="5"/>
                    </StackPanel>
                </Grid>
            </TabItem>
        </TabControl>

        <!-- Build Section -->
        <Border Grid.Row="2" Background="#FFFFFF" Padding="15" BorderBrush="#FFDEE2E6" BorderThickness="0,1,0,0">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <Button Name="btnBuild" Grid.Row="0"
                       Content="Build Executable"
                       FontSize="16" FontWeight="Bold"
                       Height="45" Width="250"
                       Background="#FF28A745" Foreground="White"
                       HorizontalAlignment="Center"/>

                <TextBlock Name="lblBuildStatus" Grid.Row="1"
                          Text="Ready to build your PowerShell executable"
                          HorizontalAlignment="Center" Margin="0,10,0,5"
                          FontSize="12" Foreground="#FF6C757D"/>

                <ProgressBar Name="progressBar" Grid.Row="2"
                            Height="20" Margin="50,0,50,0"
                            Visibility="Collapsed"/>
            </Grid>
        </Border>
    </Grid>
</Window>
'@


# Convert XAML to XML and create window
try {
    Write-DebugLog "Starting XAML parsing..."
    Write-DebugLog "XAML length: $($xaml.Length) characters"

    $reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$xaml)
    Write-DebugLog "XML Reader created successfully"

    $window = [Windows.Markup.XamlReader]::Load($reader)
    Write-DebugLog "XAML loaded into Window object successfully"

    $reader.Close()
    Write-DebugLog "XML Reader closed"

    Write-DebugLog "Window properties - Title: $($window.Title), Width: $($window.Width), Height: $($window.Height)"
} catch {
    Write-DebugLog "CRITICAL ERROR loading XAML: $($_.Exception.Message)" "ERROR"
    Write-DebugLog "Stack trace: $($_.Exception.StackTrace)" "ERROR"
    Write-DebugLog "Inner exception: $($_.Exception.InnerException)" "ERROR"
    Save-DebugLog
    exit 1
}

# Get references to controls using FindName method
Write-DebugLog "Retrieving control references..."

$txtMainScript = $window.FindName("txtMainScript")
$btnBrowseMainScript = $window.FindName("btnBrowseMainScript")
$btnClearMainScript = $window.FindName("btnClearMainScript")
$txtName = $window.FindName("txtName")
$txtVersion = $window.FindName("txtVersion")
$txtDescription = $window.FindName("txtDescription")
$txtCompany = $window.FindName("txtCompany")
$txtCopyright = $window.FindName("txtCopyright")
$txtIcon = $window.FindName("txtIcon")
$btnBrowseIcon = $window.FindName("btnBrowseIcon")
$chkRequireAdmin = $window.FindName("chkRequireAdmin")
$chkShowWindow = $window.FindName("chkShowWindow")
$txtTimeout = $window.FindName("txtTimeout")
$cmbExecutionPolicy = $window.FindName("cmbExecutionPolicy")
$txtWorkingDir = $window.FindName("txtWorkingDir")
$txtOutputFile = $window.FindName("txtOutputFile")
$btnBrowseOutput = $window.FindName("btnBrowseOutput")
$dgAssets = $window.FindName("dgAssets")
$btnAddAsset = $window.FindName("btnAddAsset")
$btnRemoveAsset = $window.FindName("btnRemoveAsset")
$btnBuild = $window.FindName("btnBuild")
$lblBuildStatus = $window.FindName("lblBuildStatus")
$progressBar = $window.FindName("progressBar")

Write-DebugLog "All controls retrieved successfully"

# Global variables for data collections
Write-DebugLog "Creating ObservableCollection instances..."
$global:AssetItems = New-Object System.Collections.ObjectModel.ObservableCollection[PSObject]
Write-DebugLog "Collections created successfully"


# Event handlers for browse buttons
Write-DebugLog "Attaching event handlers..."

$btnBrowseMainScript.Add_Click({
    Write-DebugLog "btnBrowseMainScript clicked"
    $openFileDialog = New-Object Microsoft.Win32.OpenFileDialog
    $openFileDialog.Filter = "PowerShell Scripts (*.ps1)|*.ps1|All Files (*.*)|*.*"
    $openFileDialog.Title = "Select Main PowerShell Script"
    $openFileDialog.InitialDirectory = [System.Environment]::GetFolderPath('MyDocuments')

    if ($openFileDialog.ShowDialog() -eq $true) {
        $txtMainScript.Text = $openFileDialog.FileName
        Write-DebugLog "Main script selected: $($openFileDialog.FileName)"
    }
})

$btnBrowseIcon.Add_Click({
    Write-DebugLog "btnBrowseIcon clicked"
    $openFileDialog = New-Object Microsoft.Win32.OpenFileDialog
    $openFileDialog.Filter = "Icon Files (*.ico)|*.ico|Image Files (*.png;*.jpg;*.bmp)|*.png;*.jpg;*.bmp|All Files (*.*)|*.*"
    $openFileDialog.Title = "Select Icon File"
    $openFileDialog.InitialDirectory = [System.Environment]::GetFolderPath('MyDocuments')

    if ($openFileDialog.ShowDialog() -eq $true) {
        $txtIcon.Text = $openFileDialog.FileName
        Write-DebugLog "Icon selected: $($openFileDialog.FileName)"
    }
})

$btnBrowseOutput.Add_Click({
    Write-DebugLog "btnBrowseOutput clicked"
    $saveFileDialog = New-Object Microsoft.Win32.SaveFileDialog
    $saveFileDialog.Filter = "Executable Files (*.exe)|*.exe|All Files (*.*)|*.*"
    $saveFileDialog.Title = "Save Executable As"
    $saveFileDialog.InitialDirectory = [System.Environment]::GetFolderPath('Desktop')
    $saveFileDialog.DefaultExt = "exe"

    if ($saveFileDialog.ShowDialog() -eq $true) {
        $txtOutputFile.Text = $saveFileDialog.FileName
        Write-DebugLog "Output file selected: $($saveFileDialog.FileName)"
    }
})

# Helper function to get file size
function Get-FileSize {
    param([string]$FilePath)

    if (Test-Path $FilePath) {
        $size = (Get-Item $FilePath).Length
        if ($size -lt 1KB) { return "$size B" }
        elseif ($size -lt 1MB) { return "{0:N1} KB" -f ($size / 1KB) }
        elseif ($size -lt 1GB) { return "{0:N1} MB" -f ($size / 1MB) }
        else { return "{0:N1} GB" -f ($size / 1GB) }
    }
    return "0 B"
}


# Clear Main Script button
$btnClearMainScript.Add_Click({
    Write-DebugLog "btnClearMainScript clicked"
    $txtMainScript.Text = "Select your main PowerShell script file (.ps1)"
})

# Assets management
$btnAddAsset.Add_Click({
    Write-DebugLog "btnAddAsset clicked"
    $openFileDialog = New-Object Microsoft.Win32.OpenFileDialog
    $openFileDialog.Filter = "All Files (*.*)|*.*|Images (*.png;*.jpg;*.gif;*.bmp)|*.png;*.jpg;*.gif;*.bmp|Config Files (*.json;*.xml;*.cfg)|*.json;*.xml;*.cfg|Certificates (*.pfx;*.cer;*.crt)|*.pfx;*.cer;*.crt"
    $openFileDialog.Title = "Select Resource Files"
    $openFileDialog.Multiselect = $true

    if ($openFileDialog.ShowDialog() -eq $true) {
        # Set ItemsSource on first add
        if (-not $dgAssets.ItemsSource) {
            $dgAssets.ItemsSource = $global:AssetItems
            Write-DebugLog "  dgAssets ItemsSource set to AssetItems collection"
        }

        foreach ($file in $openFileDialog.FileNames) {
            $assetName = [System.IO.Path]::GetFileName($file)
            $assetObj = New-Object PSObject -Property @{
                Name = $assetName
                FilePath = $file
                FileType = [System.IO.Path]::GetExtension($file).ToUpper()
                FileSize = Get-FileSize $file
            }
            $global:AssetItems.Add($assetObj)
            Write-DebugLog "  Added asset: $assetName"
        }
    }
})

$btnRemoveAsset.Add_Click({
    Write-DebugLog "btnRemoveAsset clicked"
    $selected = $dgAssets.SelectedItem
    if ($selected) {
        $global:AssetItems.Remove($selected)
        Write-DebugLog "  Asset removed: $($selected.Name)"
    } else {
        [System.Windows.MessageBox]::Show("Please select an asset to remove.", "No Selection", "OK", "Warning")
    }
})


# Build functionality - Integrated builder
$btnBuild.Add_Click({
    Write-DebugLog "btnBuild clicked"
    try {
        # Validation
        if ($txtMainScript.Text -eq "Select your main PowerShell script file (.ps1)" -or -not (Test-Path $txtMainScript.Text)) {
            [System.Windows.MessageBox]::Show("Please select a valid main PowerShell script.", "Validation Error", "OK", "Warning")
            return
        }

        if ($txtOutputFile.Text -eq "Choose where to save your executable") {
            [System.Windows.MessageBox]::Show("Please specify an output file path.", "Validation Error", "OK", "Warning")
            return
        }

        # Validate all resource files with security checks
        $maxFileSizeBytes = 100MB
        foreach ($asset in $global:AssetItems) {
            if (-not (Test-Path $asset.FilePath)) {
                [System.Windows.MessageBox]::Show("Asset file not found: $($asset.FilePath)", "Validation Error", "OK", "Warning")
                return
            }

            # Check file size
            $fileInfo = Get-Item $asset.FilePath
            if ($fileInfo.Length -gt $maxFileSizeBytes) {
                $sizeMB = [Math]::Round($fileInfo.Length / 1MB, 2)
                [System.Windows.MessageBox]::Show("Asset file too large: $($asset.Name)`n`nSize: ${sizeMB}MB`nMaximum allowed: 100MB`n`nLarge files will cause memory issues during compilation.", "Validation Error", "OK", "Warning")
                return
            }

            # Validate filename doesn't contain path traversal or dangerous characters
            $filename = [System.IO.Path]::GetFileName($asset.FilePath)
            if ($filename -match '\.\.' -or $filename -match '[/\\]' -or $filename -match '[\x00-\x1F]') {
                [System.Windows.MessageBox]::Show("Asset filename contains unsafe characters: $filename`n`nFilenames cannot contain: path separators, '..' sequences, or control characters.", "Validation Error", "OK", "Warning")
                return
            }
        }

        # Validate timeout is positive integer
        if ($txtTimeout.Text -match '^\d+$') {
            $timeout = [int]$txtTimeout.Text
            if ($timeout -lt 1 -or $timeout -gt 1440) {
                [System.Windows.MessageBox]::Show("Timeout must be between 1 and 1440 minutes (24 hours).", "Validation Error", "OK", "Warning")
                return
            }
        } else {
            [System.Windows.MessageBox]::Show("Timeout must be a positive number.", "Validation Error", "OK", "Warning")
            return
        }

        Write-DebugLog "All validations passed (including security checks)"

        # Check if output file exists and delete with retry logic
        if (Test-Path $txtOutputFile.Text) {
            Write-DebugLog "Output file exists, attempting to delete..."

            $deleted = $false
            $maxRetries = 3
            $retryDelays = @(200, 500, 1000)  # Exponential backoff in milliseconds

            for ($retry = 0; $retry -lt $maxRetries; $retry++) {
                try {
                    # Try to check if file is locked
                    $fileStream = $null
                    try {
                        $fileStream = [System.IO.File]::Open($txtOutputFile.Text, 'Open', 'Write')
                        $fileStream.Close()
                        $fileStream.Dispose()
                        $fileStream = $null
                    } finally {
                        if ($fileStream) {
                            $fileStream.Close()
                            $fileStream.Dispose()
                        }
                    }

                    # File not locked, delete it
                    Remove-Item $txtOutputFile.Text -Force -ErrorAction Stop
                    Write-DebugLog "Old output file deleted successfully"
                    $deleted = $true
                    break

                } catch {
                    Write-DebugLog "Delete attempt $($retry + 1) failed: $($_.Exception.Message)" "WARN"

                    if ($retry -lt $maxRetries - 1) {
                        $delay = $retryDelays[$retry]
                        Write-DebugLog "Waiting ${delay}ms before retry..." "WARN"
                        Start-Sleep -Milliseconds $delay
                    }
                }
            }

            if (-not $deleted) {
                Write-DebugLog "Output file is LOCKED after $maxRetries attempts" "ERROR"
                $result = [System.Windows.MessageBox]::Show(
                    "The output file is currently in use by another process.`n`nFile: $($txtOutputFile.Text)`n`nPlease close any running instances of this executable and try again.",
                    "File Locked",
                    "OK",
                    "Warning"
                )
                return
            }
        }

        # Start build process
        $btnBuild.IsEnabled = $false
        $progressBar.Visibility = "Visible"
        $progressBar.IsIndeterminate = $true
        $lblBuildStatus.Text = "Building executable..."

        # Build directly (no external script)
        $buildSuccess = Build-Executable -OutputPath $txtOutputFile.Text

        $btnBuild.IsEnabled = $true
        $progressBar.Visibility = "Collapsed"

        if ($buildSuccess) {
            $lblBuildStatus.Text = "Build completed successfully!"

            $fileInfo = Get-Item $txtOutputFile.Text
            $size = Get-FileSize $txtOutputFile.Text

            $message = "Executable created successfully!`n`n"
            $message += "Path: $($txtOutputFile.Text)`n"
            $message += "Size: $size`n`n"
            $message += "Included Resources:`n"
            $message += "Main Script: $([System.IO.Path]::GetFileName($txtMainScript.Text))`n"
            $message += "Assets: $($global:AssetItems.Count)"

            [System.Windows.MessageBox]::Show($message, "Build Complete", "OK", "Information")
        }

    } catch {
        Write-DebugLog "ERROR during build: $($_.Exception.Message)" "ERROR"
        $btnBuild.IsEnabled = $true
        $progressBar.Visibility = "Collapsed"
        $lblBuildStatus.Text = "Build failed with error."
        [System.Windows.MessageBox]::Show("Error during build process: $($_.Exception.Message)", "Build Error", "OK", "Error")
    }
})


# Function to build executable directly (no external script needed)
function Build-Executable {
    param(
        [string]$OutputPath
    )

    Write-DebugLog "=== Starting Executable Build ==="
    Write-DebugLog "Output path: $OutputPath"

    try {
        # Validate main script
        if ($txtMainScript.Text -eq "Select your main PowerShell script file (.ps1)" -or -not (Test-Path $txtMainScript.Text)) {
            throw "Please select a valid main PowerShell script."
        }
        Write-DebugLog "Main script: $($txtMainScript.Text)"

        # Embed resources as base64
        Write-DebugLog "Embedding resources..."
        $embeddedResources = @{}

        # Read main script content
        $mainScriptContent = Get-Content -Path $txtMainScript.Text -Raw -Encoding UTF8

        # Embed main script directly (no icon helper needed - removed taskbar icon feature)
        $mainScriptBytes = [System.Text.Encoding]::UTF8.GetBytes($mainScriptContent)
        $mainScriptBase64 = [Convert]::ToBase64String($mainScriptBytes)
        $embeddedResources["script_main"] = $mainScriptBase64
        Write-DebugLog "  Embedded main script ($($mainScriptBytes.Length) bytes)"

        # Embed assets
        foreach ($asset in $global:AssetItems) {
            if (Test-Path $asset.FilePath) {
                $assetBytes = [System.IO.File]::ReadAllBytes($asset.FilePath)
                $assetBase64 = [Convert]::ToBase64String($assetBytes)
                $embeddedResources["asset_$($asset.Name)"] = $assetBase64
                Write-DebugLog "  Embedded asset: $($asset.Name) ($($assetBytes.Length) bytes)"
            }
        }

        Write-DebugLog "Total resources embedded: $($embeddedResources.Count)"

        # Helper function for C# string escaping (security-hardened)
        function Escape-CSharpString {
            param([string]$String)

            if (-not $String) { return "" }

            $sb = New-Object System.Text.StringBuilder
            foreach ($char in $String.ToCharArray()) {
                switch ($char) {
                    '\' { [void]$sb.Append('\\') }
                    '"' { [void]$sb.Append('\"') }
                    "`n" { [void]$sb.Append('\n') }
                    "`r" { [void]$sb.Append('\r') }
                    "`t" { [void]$sb.Append('\t') }
                    "`0" { [void]$sb.Append('\0') }
                    default {
                        if ([int]$char -lt 32 -or [int]$char -gt 126) {
                            # Escape non-printable and non-ASCII as unicode
                            [void]$sb.AppendFormat('\u{0:x4}', [int]$char)
                        } else {
                            [void]$sb.Append($char)
                        }
                    }
                }
            }
            return $sb.ToString()
        }

        # Generate C# code with embedded resources (injection-proof)
        $resourcesCode = "var resources = new Dictionary<string, string>();`n"
        foreach ($key in $embeddedResources.Keys) {
            # Validate key contains only safe characters
            if ($key -notmatch '^[a-zA-Z0-9_\.\-]+$') {
                Write-DebugLog "WARNING: Skipping resource with unsafe key: $key" "WARN"
                continue
            }

            $value = $embeddedResources[$key]
            $escapedValue = Escape-CSharpString $value
            $resourcesCode += "                resources[`"$key`"] = `"$escapedValue`";`n"
        }

        $windowStyle = if ($chkShowWindow.IsChecked) { "Normal" } else { "Hidden" }
        $executionPolicy = if ($cmbExecutionPolicy.SelectedItem) { $cmbExecutionPolicy.SelectedItem.Content } else { "Bypass" }
        $requireAdmin = $chkRequireAdmin.IsChecked.ToString().ToLower()
        $showWindow = $chkShowWindow.IsChecked.ToString().ToLower()
        $timeoutMinutes = if ($txtTimeout.Text) { $txtTimeout.Text } else { "5" }

        Write-DebugLog "Build settings:"
        Write-DebugLog "  Window style: $windowStyle"
        Write-DebugLog "  Execution policy: $executionPolicy"
        Write-DebugLog "  Require admin: $requireAdmin"
        Write-DebugLog "  Timeout: $timeoutMinutes minutes"

        # Use unique namespace for each build to avoid type conflicts
        $uniqueId = [Guid]::NewGuid().ToString("N").Substring(0, 8)
        $namespace = "PSExecutor_$uniqueId"
        Write-DebugLog "  Using namespace: $namespace"

        # Escape metadata for C# strings
        $escapedTitle = Escape-CSharpString $txtName.Text
        $escapedDescription = Escape-CSharpString $txtDescription.Text
        $escapedCompany = Escape-CSharpString $txtCompany.Text
        $escapedCopyright = Escape-CSharpString $txtCopyright.Text
        $escapedVersion = Escape-CSharpString $txtVersion.Text

        $csharpCode = @"
using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Diagnostics;
using System.Security.Principal;
using System.Reflection;

[assembly: AssemblyTitle("$escapedTitle")]
[assembly: AssemblyDescription("$escapedDescription")]
[assembly: AssemblyCompany("$escapedCompany")]
[assembly: AssemblyProduct("$escapedTitle")]
[assembly: AssemblyCopyright("Copyright © $escapedCopyright")]
[assembly: AssemblyVersion("$escapedVersion")]
[assembly: AssemblyFileVersion("$escapedVersion")]

namespace $namespace
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                bool requireAdmin = $requireAdmin;
                if (requireAdmin && !IsRunningAsAdmin())
                {
                    Console.WriteLine("This application requires administrator privileges.");
                    Console.WriteLine("Attempting to restart with elevated privileges...");
                    RestartAsAdmin();
                    return;
                }

                $resourcesCode

                string scriptName = "main";
                string resourceKey = "script_" + scriptName;

                if (!resources.ContainsKey(resourceKey))
                {
                    Console.WriteLine("Error: Default script not found in embedded resources.");
                    Environment.Exit(1);
                    return;
                }

                string scriptBase64 = resources[resourceKey];
                byte[] scriptBytes = Convert.FromBase64String(scriptBase64);
                string scriptContent = Encoding.UTF8.GetString(scriptBytes);

                string tempDir = Path.Combine(Path.GetTempPath(), "PSExecutor_" + Guid.NewGuid().ToString());
                Directory.CreateDirectory(tempDir);

                string scriptPath = Path.Combine(tempDir, scriptName + ".ps1");
                File.WriteAllText(scriptPath, scriptContent, Encoding.UTF8);

                foreach (var resource in resources)
                {
                    if (resource.Key != resourceKey)
                    {
                        string resourceName = resource.Key
                            .Replace("cert_", "")
                            .Replace("asset_", "")
                            .Replace("script_", "");

                        string extension = "";
                        if (resource.Key.StartsWith("script_"))
                        {
                            extension = ".ps1";
                        }
                        else if (resource.Key.StartsWith("cert_"))
                        {
                            extension = ".pfx";
                        }
                        else if (resource.Key.StartsWith("asset_"))
                        {
                            // Asset filenames already include their extension (e.g., "test.txt", "image.png")
                            // Only add .dat if the filename truly has no extension
                            string fileExt = Path.GetExtension(resourceName);
                            if (string.IsNullOrEmpty(fileExt))
                            {
                                extension = ".dat";
                            }
                            // Otherwise extension is empty string because resourceName already has it
                        }

                        string resourcePath = Path.Combine(tempDir, resourceName + extension);
                        byte[] resourceBytes = Convert.FromBase64String(resource.Value);
                        File.WriteAllBytes(resourcePath, resourceBytes);
                    }
                }

                // Set environment variable so PowerShell script can find resources
                Environment.SetEnvironmentVariable("PS_RESOURCE_DIR", tempDir, EnvironmentVariableTarget.Process);

                string psCommand = string.Format("-ExecutionPolicy $executionPolicy -File \`"{0}\`"", scriptPath);

                if (args.Length > 0)
                {
                    psCommand += " " + string.Join(" ", args);
                }

                var psi = new ProcessStartInfo
                {
                    FileName = "powershell.exe",
                    Arguments = psCommand,
                    UseShellExecute = false,
                    CreateNoWindow = !$showWindow,
                    WindowStyle = ProcessWindowStyle.$windowStyle,
                    WorkingDirectory = tempDir
                };

                Process process;

                if ($showWindow)
                {
                    // Show window - no output redirection
                    process = Process.Start(psi);
                }
                else
                {
                    // Hide window - redirect output
                    psi.RedirectStandardOutput = true;
                    psi.RedirectStandardError = true;
                    process = Process.Start(psi);

                    string output = process.StandardOutput.ReadToEnd();
                    string errors = process.StandardError.ReadToEnd();
                    if (!string.IsNullOrEmpty(output)) Console.WriteLine(output);
                    if (!string.IsNullOrEmpty(errors)) Console.Error.WriteLine(errors);
                }

                int timeoutMinutes = $timeoutMinutes;
                bool exited = false;
                if (timeoutMinutes > 0)
                {
                    exited = process.WaitForExit(timeoutMinutes * 60 * 1000);
                    if (!exited)
                    {
                        Console.WriteLine("Process timed out after {0} minutes. Terminating...", timeoutMinutes);
                        process.Kill();
                    }
                }
                else
                {
                    process.WaitForExit();
                    exited = true;
                }

                int exitCode = exited ? process.ExitCode : -1;

                try
                {
                    Directory.Delete(tempDir, true);
                }
                catch { }

                Environment.Exit(exitCode);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Fatal error: " + ex.Message);
                Environment.Exit(1);
            }
        }

        static bool IsRunningAsAdmin()
        {
            try
            {
                WindowsIdentity identity = WindowsIdentity.GetCurrent();
                WindowsPrincipal principal = new WindowsPrincipal(identity);
                return principal.IsInRole(WindowsBuiltInRole.Administrator);
            }
            catch
            {
                return false;
            }
        }

        static void RestartAsAdmin()
        {
            try
            {
                var psi = new ProcessStartInfo
                {
                    FileName = System.Reflection.Assembly.GetExecutingAssembly().Location,
                    UseShellExecute = true,
                    Verb = "runas"
                };
                Process.Start(psi);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Failed to restart with administrator privileges: " + ex.Message);
            }
        }
    }
}
"@

        Write-DebugLog "C# code generated (Length: $($csharpCode.Length) characters)"

        # Compile executable using csc.exe directly (avoids file locking)
        Write-DebugLog "Starting compilation..."

        # Locate csc.exe
        $cscPath = $null
        $frameworkPaths = @(
            "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe",
            "C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"
        )

        foreach ($path in $frameworkPaths) {
            if (Test-Path $path) {
                $cscPath = $path
                Write-DebugLog "Found csc.exe at: $cscPath"
                break
            }
        }

        if (-not $cscPath) {
            throw "C# compiler (csc.exe) not found. Please ensure .NET Framework 4.0+ is installed."
        }

        # Prepare icon path with conversion if needed
        $iconPath = $null
        $tempIcoPath = $null

        if ($txtIcon.Text -and
            $txtIcon.Text -ne "Optional: Select .ico file" -and
            (Test-Path $txtIcon.Text)) {

            $iconPath = $txtIcon.Text
            $iconExtension = [System.IO.Path]::GetExtension($iconPath).ToLower()

            # Convert image to ICO if needed
            if ($iconExtension -ne ".ico") {
                Write-DebugLog "Converting $iconExtension to ICO format..."

                $sourceImage = $null
                $iconStream = $null
                $writer = $null

                try {
                    Add-Type -AssemblyName System.Drawing

                    # Load source image with proper disposal
                    $sourceImage = [System.Drawing.Image]::FromFile($iconPath)

                    # Create temporary ICO file
                    $tempIcoPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "temp_icon_$([Guid]::NewGuid().ToString()).ico")

                    # Create icon with multiple sizes
                    $sizes = @(16, 32, 48, 256)
                    $iconStream = New-Object System.IO.MemoryStream
                    $writer = New-Object System.IO.BinaryWriter($iconStream)

                    # Write ICO header
                    $writer.Write([UInt16]0)  # Reserved
                    $writer.Write([UInt16]1)  # Type (ICO)
                    $writer.Write([UInt16]$sizes.Count)  # Number of images

                    $directoryOffset = $iconStream.Position
                    $imageDataOffset = $directoryOffset + (16 * $sizes.Count)

                    # Generate image data for each size with proper disposal
                    $imageData = @()
                    foreach ($size in $sizes) {
                        $bitmap = $null
                        $graphics = $null
                        $pngStream = $null

                        try {
                            $bitmap = New-Object System.Drawing.Bitmap($size, $size)
                            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
                            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                            $graphics.DrawImage($sourceImage, 0, 0, $size, $size)

                            $pngStream = New-Object System.IO.MemoryStream
                            $bitmap.Save($pngStream, [System.Drawing.Imaging.ImageFormat]::Png)
                            $pngBytes = $pngStream.ToArray()

                            $imageData += @{
                                Size = $size
                                Data = $pngBytes
                                Offset = $imageDataOffset
                                Length = $pngBytes.Length
                            }
                            $imageDataOffset += $pngBytes.Length

                        } finally {
                            if ($graphics) { $graphics.Dispose() }
                            if ($pngStream) { $pngStream.Dispose() }
                            if ($bitmap) { $bitmap.Dispose() }
                        }
                    }

                    # Write directory entries
                    foreach ($imgData in $imageData) {
                        $size = $imgData.Size
                        $width = if ($size -eq 256) { 0 } else { $size }
                        $height = if ($size -eq 256) { 0 } else { $size }

                        $writer.Write([Byte]$width)
                        $writer.Write([Byte]$height)
                        $writer.Write([Byte]0)
                        $writer.Write([Byte]0)
                        $writer.Write([UInt16]1)
                        $writer.Write([UInt16]32)
                        $writer.Write([UInt32]$imgData.Length)
                        $writer.Write([UInt32]$imgData.Offset)
                    }

                    # Write image data
                    foreach ($imgData in $imageData) {
                        $writer.Write($imgData.Data)
                    }

                    # Save to file
                    $writer.Flush()
                    [System.IO.File]::WriteAllBytes($tempIcoPath, $iconStream.ToArray())

                    $iconPath = $tempIcoPath
                    Write-DebugLog "Converted to ICO: $iconPath"

                } catch {
                    Write-DebugLog "WARNING: Image to ICO conversion failed: $($_.Exception.Message)" "WARN"
                    Write-DebugLog "Please use a .ico file instead of $iconExtension" "WARN"
                    $iconPath = $null
                } finally {
                    if ($writer) { $writer.Dispose() }
                    if ($iconStream) { $iconStream.Dispose() }
                    if ($sourceImage) { $sourceImage.Dispose() }
                }
            }
        }

        # Write C# code to temporary file
        $tempCS = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "PSEBuilder_$([Guid]::NewGuid().ToString('N').Substring(0,8)).cs")
        Write-DebugLog "Writing C# code to: $tempCS"
        [System.IO.File]::WriteAllText($tempCS, $csharpCode, [System.Text.Encoding]::UTF8)

        # Build compiler arguments
        $compilerArgs = @(
            "/target:winexe",
            "/platform:anycpu",
            "/out:`"$OutputPath`"",
            "/reference:System.dll",
            "/reference:System.Core.dll",
            "/optimize+",
            "/nologo"
        )

        if ($iconPath) {
            Write-DebugLog "Adding icon: $iconPath"
            $compilerArgs += "/win32icon:`"$iconPath`""
        } else {
            if ($txtIcon.Text -and $txtIcon.Text -ne "Optional: Select .ico file") {
                Write-DebugLog "WARNING: Icon file not found: $($txtIcon.Text)" "WARN"
            } else {
                Write-DebugLog "No icon specified, using default"
            }
        }

        $compilerArgs += "`"$tempCS`""

        Write-DebugLog "Compiler command: $cscPath $($compilerArgs -join ' ')"

        # Execute csc.exe
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $cscPath
        $psi.Arguments = $compilerArgs -join ' '
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.CreateNoWindow = $true

        $process = [System.Diagnostics.Process]::Start($psi)
        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        $process.WaitForExit()

        $exitCode = $process.ExitCode

        Write-DebugLog "Compiler exit code: $exitCode"
        if ($stdout) { Write-DebugLog "Compiler output: $stdout" }
        if ($stderr) { Write-DebugLog "Compiler errors: $stderr" }

        # Cleanup temporary files
        try {
            if (Test-Path $tempCS) {
                Remove-Item -Path $tempCS -Force -ErrorAction SilentlyContinue
                Write-DebugLog "Cleaned up temporary C# file"
            }
        } catch {
            Write-DebugLog "Could not delete temporary C# file: $($_.Exception.Message)" "WARN"
        }

        if ($tempIcoPath -and (Test-Path $tempIcoPath)) {
            try {
                Remove-Item -Path $tempIcoPath -Force -ErrorAction SilentlyContinue
                Write-DebugLog "Cleaned up temporary icon file"
            } catch {
                Write-DebugLog "Could not delete temporary icon: $($_.Exception.Message)" "WARN"
            }
        }

        # Check compilation result
        if ($exitCode -ne 0) {
            throw "Compilation failed with exit code $exitCode. Error: $stderr"
        }

        Write-DebugLog "Compilation completed successfully"

        # Force garbage collection to release any remaining handles
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        [System.GC]::Collect()

        if (Test-Path $OutputPath) {
            $fileInfo = Get-Item $OutputPath
            $sizeKB = [Math]::Round($fileInfo.Length / 1KB, 2)
            Write-DebugLog "=== BUILD SUCCESSFUL ==="
            Write-DebugLog "Output: $OutputPath"
            Write-DebugLog "Size: $sizeKB KB"

            # Release file info handle
            $fileInfo = $null
            [System.GC]::Collect()

            return $true
        } else {
            throw "Build completed but output file not created"
        }

    } catch {
        Write-DebugLog "BUILD FAILED: $($_.Exception.Message)" "ERROR"
        Write-DebugLog "Stack trace: $($_.Exception.StackTrace)" "ERROR"
        throw
    }
}

Write-DebugLog "All event handlers attached successfully"


# Show the window
Write-DebugLog "=== ATTEMPTING TO SHOW WINDOW ==="
Write-DebugLog "About to call window.ShowDialog()..."

try {
    Write-DebugLog "Calling window.ShowDialog() NOW..."
    $dialogResult = $window.ShowDialog()
    Write-DebugLog "window.ShowDialog() returned: $dialogResult"
    Write-DebugLog "Window closed normally"
} catch {
    Write-DebugLog "=== CRITICAL ERROR DURING ShowDialog() ===" "ERROR"
    Write-DebugLog "Error Type: $($_.Exception.GetType().FullName)" "ERROR"
    Write-DebugLog "Error Message: $($_.Exception.Message)" "ERROR"
    Write-DebugLog "Stack Trace: $($_.Exception.StackTrace)" "ERROR"

    if ($_.Exception.InnerException) {
        Write-DebugLog "Inner Exception: $($_.Exception.InnerException.Message)" "ERROR"
        Write-DebugLog "Inner Stack Trace: $($_.Exception.InnerException.StackTrace)" "ERROR"
    }
} finally {
    Write-DebugLog "=== SESSION ENDED ==="
    Save-DebugLog
    Write-Host "`nDebug log saved to: $global:LogFilePath" -ForegroundColor Cyan
}