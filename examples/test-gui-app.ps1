# Test GUI Application - PowerShell Script with File and Image Display
# This script demonstrates reading a text file and displaying an image in a WPF GUI
# Files needed: test.txt, image.png

#Requires -Version 3.0

# Add required assemblies for WPF
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Drawing

# Set error action preference
$ErrorActionPreference = "Stop"

# Initialize logging
$global:AppLogPath = Join-Path ([Environment]::GetFolderPath('UserProfile')) "Downloads\TestGUI-Runtime-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$global:AppLogMessages = @()

function Write-AppLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $logEntry = "[$timestamp] [$Level] $Message"
    $global:AppLogMessages += $logEntry
    Write-Host $logEntry -ForegroundColor $(if($Level -eq "ERROR"){"Red"}elseif($Level -eq "WARN"){"Yellow"}else{"Cyan"})
}

function Save-AppLog {
    try {
        $global:AppLogMessages | Out-File -FilePath $global:AppLogPath -Encoding UTF8
        Write-Host "Application log saved to: $global:AppLogPath" -ForegroundColor Green
    } catch {
        Write-Host "Failed to save application log: $_" -ForegroundColor Red
    }
}

Write-AppLog "=== Test GUI Application Started ==="
Write-AppLog "Log file: $global:AppLogPath"
Write-AppLog "PowerShell Version: $($PSVersionTable.PSVersion)"

# Log all environment variables related to resources
Write-AppLog "Environment Variables:"
Write-AppLog "  PS_RESOURCE_DIR = $($env:PS_RESOURCE_DIR)"
Write-AppLog "  TEMP = $($env:TEMP)"
Write-AppLog "  TMP = $($env:TMP)"

# List all files in resource directory if it exists
if ($env:PS_RESOURCE_DIR -and (Test-Path $env:PS_RESOURCE_DIR)) {
    Write-AppLog "Files in PS_RESOURCE_DIR:"
    try {
        $files = Get-ChildItem -Path $env:PS_RESOURCE_DIR -File
        foreach ($file in $files) {
            Write-AppLog "  - $($file.Name) ($($file.Length) bytes)"
        }
        Write-AppLog "Total files found: $($files.Count)"
    } catch {
        Write-AppLog "  ERROR listing files: $($_.Exception.Message)" "ERROR"
    }
} else {
    Write-AppLog "PS_RESOURCE_DIR not set or directory does not exist" "WARN"
}

# Function to get resource file path (will work with embedded resources)
function Get-ResourcePath {
    param([string]$FileName)

    Write-AppLog "Searching for file: $FileName"

    # FIRST: Check if running from executable (environment variable set by C# runtime)
    if ($env:PS_RESOURCE_DIR) {
        $resourcePath = Join-Path $env:PS_RESOURCE_DIR $FileName
        Write-AppLog "  Checking resource dir: $resourcePath"
        if (Test-Path $resourcePath) {
            Write-AppLog "  SUCCESS: Found in resource directory!" "SUCCESS"
            return $resourcePath
        } else {
            Write-AppLog "  Not found in resource dir" "WARN"
        }
    } else {
        Write-AppLog "  PS_RESOURCE_DIR not set" "WARN"
    }

    # Try current script directory
    $scriptDir = if ($MyInvocation.ScriptName) { Split-Path -Parent $MyInvocation.ScriptName } else { $PSScriptRoot }
    if (-not $scriptDir) { $scriptDir = Get-Location }
    $localPath = Join-Path $scriptDir $FileName
    Write-AppLog "  Checking script dir: $localPath"

    if (Test-Path $localPath) {
        Write-AppLog "  SUCCESS: Found in script directory!"
        return $localPath
    }

    # Try working directory
    $workingPath = Join-Path (Get-Location) $FileName
    Write-AppLog "  Checking working dir: $workingPath"
    if (Test-Path $workingPath) {
        Write-AppLog "  SUCCESS: Found in working directory!"
        return $workingPath
    }

    # Try temp directory (legacy check)
    $tempPath = Join-Path $env:TEMP $FileName
    Write-AppLog "  Checking temp dir: $tempPath"
    if (Test-Path $tempPath) {
        Write-AppLog "  SUCCESS: Found in temp directory!"
        return $tempPath
    }

    Write-AppLog "  ERROR: File not found in any location!" "ERROR"
    return $null
}

# XAML definition for the GUI
$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Test GUI Application - PowerShell Executor Builder Demo"
        Height="600" Width="800"
        WindowStartupLocation="CenterScreen"
        Background="#FFF8F9FA">

    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Margin" Value="10"/>
            <Setter Property="Padding" Value="15,8"/>
            <Setter Property="Background" Value="#FF007BFF"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="FontSize" Value="12"/>
        </Style>
        <Style TargetType="TextBox">
            <Setter Property="Margin" Value="10"/>
            <Setter Property="Padding" Value="10"/>
            <Setter Property="BorderBrush" Value="#FFCED4DA"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontFamily" Value="Consolas"/>
            <Setter Property="FontSize" Value="11"/>
        </Style>
        <Style TargetType="Label">
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Margin" Value="10,10,10,5"/>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Header -->
        <Border Grid.Row="0" Background="#FF343A40" Padding="20">
            <StackPanel>
                <TextBlock Text="PowerShell Executor Builder - Test Application"
                          FontSize="20" FontWeight="Bold"
                          Foreground="White" HorizontalAlignment="Center"/>
                <TextBlock Text="Demonstrating text file reading and image display with embedded resources"
                          FontSize="12" Foreground="#FFE9ECEF"
                          HorizontalAlignment="Center" Margin="0,5,0,0"/>
            </StackPanel>
        </Border>

        <!-- Text File Content -->
        <GroupBox Grid.Row="1" Header="Text File Content (test.txt)" Margin="15">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <StackPanel Grid.Row="0" Orientation="Horizontal">
                    <Button Name="btnLoadText" Content="Load Text File"/>
                    <Button Name="btnClearText" Content="Clear"/>
                    <TextBlock Name="txtFileStatus" Text="Click 'Load Text File' to read test.txt"
                              VerticalAlignment="Center" Margin="15,0,0,0" FontStyle="Italic"/>
                </StackPanel>

                <TextBox Name="txtFileContent" Grid.Row="1"
                        IsReadOnly="True" TextWrapping="Wrap"
                        VerticalScrollBarVisibility="Auto"
                        HorizontalScrollBarVisibility="Auto"
                        Background="#FFF8F8F8"/>
            </Grid>
        </GroupBox>

        <!-- Image Display -->
        <GroupBox Grid.Row="2" Header="Image Display (image.png)" Margin="15">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <StackPanel Grid.Row="0" Orientation="Horizontal">
                    <Button Name="btnLoadImage" Content="Load Image"/>
                    <Button Name="btnClearImage" Content="Clear Image"/>
                    <TextBlock Name="txtImageStatus" Text="Click 'Load Image' to display image.png"
                              VerticalAlignment="Center" Margin="15,0,0,0" FontStyle="Italic"/>
                </StackPanel>

                <Border Grid.Row="1" BorderBrush="#FFCED4DA" BorderThickness="1" Margin="10">
                    <ScrollViewer HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Auto">
                        <Image Name="imgDisplay" Stretch="Uniform" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </ScrollViewer>
                </Border>
            </Grid>
        </GroupBox>

        <!-- Action Buttons -->
        <StackPanel Grid.Row="3" Orientation="Horizontal" HorizontalAlignment="Center" Margin="20">
            <Button Name="btnLoadBoth" Content="Load Both Files" Width="150"/>
            <Button Name="btnAbout" Content="About" Width="100"/>
            <Button Name="btnExit" Content="Exit" Width="100"/>
        </StackPanel>
    </Grid>
</Window>
'@

try {
    Write-Host "Loading Test GUI Application..." -ForegroundColor Green

    # Load XAML
    $reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)
    $reader.Close()

    Write-Host "XAML loaded successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error loading XAML: $($_.Exception.Message)" -ForegroundColor Red
    [System.Windows.MessageBox]::Show("Error loading GUI: $($_.Exception.Message)", "Error", "OK", "Error")
    exit 1
}

# Set window icon (if Set-AppIcon function is available from PSEBuilder)
if (Get-Command Set-AppIcon -ErrorAction SilentlyContinue) {
    try {
        Set-AppIcon -Window $window
        Write-AppLog "Window icon set using Set-AppIcon function" "INFO"
    } catch {
        Write-AppLog "Could not set window icon: $($_.Exception.Message)" "WARN"
    }
} else {
    Write-AppLog "Set-AppIcon function not available (not built with icon support)" "INFO"
}

# Get control references
$btnLoadText = $window.FindName("btnLoadText")
$btnClearText = $window.FindName("btnClearText")
$txtFileStatus = $window.FindName("txtFileStatus")
$txtFileContent = $window.FindName("txtFileContent")
$btnLoadImage = $window.FindName("btnLoadImage")
$btnClearImage = $window.FindName("btnClearImage")
$txtImageStatus = $window.FindName("txtImageStatus")
$imgDisplay = $window.FindName("imgDisplay")
$btnLoadBoth = $window.FindName("btnLoadBoth")
$btnAbout = $window.FindName("btnAbout")
$btnExit = $window.FindName("btnExit")

# Function to load text file
function Load-TextFile {
    Write-AppLog "=== Load-TextFile function called ===" "INFO"
    try {
        $textPath = Get-ResourcePath "test.txt"

        if ($textPath) {
            Write-AppLog "Text file path resolved: $textPath" "INFO"
            Write-AppLog "File exists: $(Test-Path $textPath)" "INFO"

            if (Test-Path $textPath) {
                $fileInfo = Get-Item $textPath
                Write-AppLog "File size: $($fileInfo.Length) bytes" "INFO"
            }

            $content = Get-Content -Path $textPath -Raw
            Write-AppLog "Content loaded successfully (length: $($content.Length) characters)" "INFO"

            $txtFileContent.Text = $content
            $txtFileStatus.Text = "Loaded: $textPath"
            $txtFileStatus.Foreground = "Green"
            Write-Host "Text file loaded from: $textPath" -ForegroundColor Green
            Write-AppLog "Text file loaded and displayed successfully" "INFO"
        } else {
            Write-AppLog "Text file NOT FOUND - Get-ResourcePath returned null" "ERROR"
            $txtFileContent.Text = "test.txt file not found!"
            $txtFileStatus.Text = "Error: test.txt not found in script directory, working directory, or temp folder"
            $txtFileStatus.Foreground = "Red"
            Write-Host "Text file not found!" -ForegroundColor Red
        }
    } catch {
        Write-AppLog "EXCEPTION in Load-TextFile: $($_.Exception.Message)" "ERROR"
        Write-AppLog "Stack trace: $($_.ScriptStackTrace)" "ERROR"
        $txtFileContent.Text = "Error loading text file: $($_.Exception.Message)"
        $txtFileStatus.Text = "Error loading file"
        $txtFileStatus.Foreground = "Red"
        Write-Host "Error loading text file: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-AppLog "=== Load-TextFile function completed ===" "INFO"
}

# Function to load image
function Load-ImageFile {
    Write-AppLog "=== Load-ImageFile function called ===" "INFO"
    try {
        $imagePath = Get-ResourcePath "image.png"

        if ($imagePath) {
            Write-AppLog "Image file path resolved: $imagePath" "INFO"
            Write-AppLog "File exists: $(Test-Path $imagePath)" "INFO"

            if (Test-Path $imagePath) {
                $fileInfo = Get-Item $imagePath
                Write-AppLog "File size: $($fileInfo.Length) bytes" "INFO"
            }

            Write-AppLog "Creating BitmapImage object..." "INFO"
            $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
            $bitmap.BeginInit()
            $bitmap.UriSource = New-Object System.Uri($imagePath)
            $bitmap.EndInit()
            Write-AppLog "BitmapImage created successfully" "INFO"

            $imgDisplay.Source = $bitmap
            $txtImageStatus.Text = "Loaded: $imagePath"
            $txtImageStatus.Foreground = "Green"
            Write-Host "Image loaded from: $imagePath" -ForegroundColor Green
            Write-AppLog "Image loaded and displayed successfully" "INFO"
        } else {
            Write-AppLog "Image file NOT FOUND - Get-ResourcePath returned null" "ERROR"
            $imgDisplay.Source = $null
            $txtImageStatus.Text = "Error: image.png not found in script directory, working directory, or temp folder"
            $txtImageStatus.Foreground = "Red"
            Write-Host "Image file not found!" -ForegroundColor Red
        }
    } catch {
        Write-AppLog "EXCEPTION in Load-ImageFile: $($_.Exception.Message)" "ERROR"
        Write-AppLog "Stack trace: $($_.ScriptStackTrace)" "ERROR"
        $imgDisplay.Source = $null
        $txtImageStatus.Text = "Error loading image: $($_.Exception.Message)"
        $txtImageStatus.Foreground = "Red"
        Write-Host "Error loading image: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-AppLog "=== Load-ImageFile function completed ===" "INFO"
}

# Event handlers
if ($btnLoadText) {
    $btnLoadText.Add_Click({
        Load-TextFile
    })
}

if ($btnClearText) {
    $btnClearText.Add_Click({
        $txtFileContent.Text = ""
        $txtFileStatus.Text = "Text cleared"
        $txtFileStatus.Foreground = "Gray"
    })
}

if ($btnLoadImage) {
    $btnLoadImage.Add_Click({
        Load-ImageFile
    })
}

if ($btnClearImage) {
    $btnClearImage.Add_Click({
        $imgDisplay.Source = $null
        $txtImageStatus.Text = "Image cleared"
        $txtImageStatus.Foreground = "Gray"
    })
}

if ($btnLoadBoth) {
    $btnLoadBoth.Add_Click({
        Load-TextFile
        Load-ImageFile
    })
}

if ($btnAbout) {
    $btnAbout.Add_Click({
        $aboutMessage = @"
PowerShell Executor Builder - Test Application

This is a demonstration GUI application that:
• Reads content from test.txt file
• Displays image.png file
• Works with embedded resources when built as executable

Created for testing the PowerShell Executor Builder system.

File Locations Checked:
1. Script directory
2. Working directory
3. Temp directory (for extracted resources)

Version: 1.0
"@
        [System.Windows.MessageBox]::Show($aboutMessage, "About Test Application", "OK", "Information")
    })
}

if ($btnExit) {
    $btnExit.Add_Click({
        Write-AppLog "Exit button clicked - saving log and closing application"
        Save-AppLog
        $window.Close()
    })
}

# Add window closing event to save log
$window.Add_Closing({
    Write-AppLog "=== Test GUI Application Closing ==="
    Write-AppLog "Application ran for: $((Get-Date) - (Get-Date $global:AppLogMessages[0].Split(']')[0].Trim('[')))"
    Save-AppLog
})

# Show startup information
Write-Host "" -ForegroundColor Yellow
Write-Host "===============================================" -ForegroundColor Yellow
Write-Host "Test GUI Application Started" -ForegroundColor Yellow
Write-Host "===============================================" -ForegroundColor Yellow
$scriptDir = if ($MyInvocation.ScriptName) { Split-Path -Parent $MyInvocation.ScriptName } else { $PSScriptRoot }
if (-not $scriptDir) { $scriptDir = Get-Location }
Write-Host "Script Directory: $scriptDir" -ForegroundColor Cyan
Write-Host "Working Directory: $(Get-Location)" -ForegroundColor Cyan

if ($env:PS_RESOURCE_DIR) {
    Write-Host "Resource Directory (from exe): $env:PS_RESOURCE_DIR" -ForegroundColor Green
    Write-Host "Running as EXECUTABLE with embedded resources" -ForegroundColor Green
} else {
    Write-Host "Resource Directory: Not set (running as script)" -ForegroundColor Yellow
    Write-Host "Running as SCRIPT - resources should be in script directory" -ForegroundColor Yellow
}

Write-Host "" -ForegroundColor Cyan
Write-Host "Looking for files: test.txt, image.png" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Yellow
Write-Host ""

# Show the window
$window.ShowDialog() | Out-Null