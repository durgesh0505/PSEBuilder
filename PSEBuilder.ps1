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
        Title="PSEBuilder - PowerShell Executor Builder"
        Height="750" Width="1000"
        MinHeight="700" MinWidth="950"
        WindowStartupLocation="CenterScreen"
        Background="#1E1E1E">

    <Window.Resources>
        <!-- Dark Theme Styles -->
        <Style TargetType="TextBox">
            <Setter Property="Background" Value="#2D2D2D"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="#3F3F3F"/>
            <Setter Property="CaretBrush" Value="#FFFFFF"/>
            <Setter Property="SelectionBrush" Value="#0078D4"/>
            <Setter Property="Padding" Value="5,2"/>
            <Setter Property="Margin" Value="5"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Style.Triggers>
                <Trigger Property="IsReadOnly" Value="True">
                    <Setter Property="Background" Value="#1A1A1A"/>
                    <Setter Property="Foreground" Value="#CCCCCC"/>
                    <Setter Property="BorderBrush" Value="#2D2D2D"/>
                </Trigger>
                <Trigger Property="IsEnabled" Value="False">
                    <Setter Property="Background" Value="#1A1A1A"/>
                    <Setter Property="Foreground" Value="#666666"/>
                    <Setter Property="BorderBrush" Value="#2D2D2D"/>
                </Trigger>
                <Trigger Property="IsFocused" Value="True">
                    <Setter Property="BorderBrush" Value="#0078D4"/>
                    <Setter Property="BorderThickness" Value="2"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style TargetType="Button">
            <Setter Property="Background" Value="#0078D4"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="#0078D4"/>
            <Setter Property="Margin" Value="5"/>
            <Setter Property="Padding" Value="10,5"/>
            <Setter Property="MinWidth" Value="90"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="1"
                                CornerRadius="3">
                            <ContentPresenter HorizontalAlignment="Center"
                                            VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#106EBE"/>
                </Trigger>
                <Trigger Property="IsPressed" Value="True">
                    <Setter Property="Background" Value="#005A9E"/>
                </Trigger>
                <Trigger Property="IsEnabled" Value="False">
                    <Setter Property="Background" Value="#666666"/>
                    <Setter Property="BorderBrush" Value="#666666"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style TargetType="ComboBox">
            <Setter Property="Background" Value="#0078D4"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="#0078D4"/>
            <Setter Property="Margin" Value="5"/>
            <Setter Property="Padding" Value="5"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ComboBox">
                        <Grid>
                            <ToggleButton Name="ToggleButton"
                                        Background="{TemplateBinding Background}"
                                        BorderBrush="{TemplateBinding BorderBrush}"
                                        BorderThickness="1"
                                        Focusable="False"
                                        IsChecked="{Binding Path=IsDropDownOpen, Mode=TwoWay, RelativeSource={RelativeSource TemplatedParent}}"
                                        ClickMode="Press">
                                <ToggleButton.Template>
                                    <ControlTemplate TargetType="ToggleButton">
                                        <Border Name="Border" Background="{TemplateBinding Background}"
                                                BorderBrush="{TemplateBinding BorderBrush}"
                                                BorderThickness="1" CornerRadius="3">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition />
                                                    <ColumnDefinition Width="20" />
                                                </Grid.ColumnDefinitions>
                                                <Path Grid.Column="1"
                                                      Fill="#FFFFFF"
                                                      HorizontalAlignment="Center"
                                                      VerticalAlignment="Center"
                                                      Data="M 0 0 L 4 4 L 8 0 Z"/>
                                            </Grid>
                                        </Border>
                                    </ControlTemplate>
                                </ToggleButton.Template>
                            </ToggleButton>
                            <ContentPresenter Name="ContentSite"
                                            IsHitTestVisible="False"
                                            Content="{TemplateBinding SelectionBoxItem}"
                                            ContentTemplate="{TemplateBinding SelectionBoxItemTemplate}"
                                            ContentTemplateSelector="{TemplateBinding ItemTemplateSelector}"
                                            Margin="5,3,25,3"
                                            VerticalAlignment="Center"
                                            HorizontalAlignment="Left">
                                <ContentPresenter.Resources>
                                    <Style TargetType="TextBlock">
                                        <Setter Property="Foreground" Value="#FFFFFF"/>
                                    </Style>
                                </ContentPresenter.Resources>
                            </ContentPresenter>
                            <Popup Name="Popup"
                                   Placement="Bottom"
                                   IsOpen="{TemplateBinding IsDropDownOpen}"
                                   AllowsTransparency="True"
                                   Focusable="False"
                                   PopupAnimation="Slide">
                                <Grid Name="DropDown"
                                      SnapsToDevicePixels="True"
                                      MinWidth="{TemplateBinding ActualWidth}"
                                      MaxHeight="{TemplateBinding MaxDropDownHeight}">
                                    <Border Name="DropDownBorder"
                                            Background="#2D2D2D"
                                            BorderThickness="1"
                                            BorderBrush="#3F3F3F"/>
                                    <ScrollViewer Margin="4,6,4,6" SnapsToDevicePixels="True">
                                        <StackPanel IsItemsHost="True"
                                                  KeyboardNavigation.DirectionalNavigation="Contained" />
                                    </ScrollViewer>
                                </Grid>
                            </Popup>
                        </Grid>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="ToggleButton" Property="Background" Value="#106EBE"/>
                                <Setter TargetName="ToggleButton" Property="BorderBrush" Value="#106EBE"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="ComboBoxItem">
            <Setter Property="Background" Value="#2D2D2D"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="Padding" Value="8,6"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ComboBoxItem">
                        <Border Name="Border" Background="#2D2D2D"
                                BorderThickness="0" Padding="{TemplateBinding Padding}">
                            <ContentPresenter/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsHighlighted" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#0078D4"/>
                            </Trigger>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#0078D4"/>
                                <Setter Property="Foreground" Value="#FFFFFF"/>
                            </Trigger>
                            <MultiTrigger>
                                <MultiTrigger.Conditions>
                                    <Condition Property="IsSelected" Value="True"/>
                                    <Condition Property="IsHighlighted" Value="True"/>
                                </MultiTrigger.Conditions>
                                <Setter TargetName="Border" Property="Background" Value="#106EBE"/>
                            </MultiTrigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="RadioButton">
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="Background" Value="#2D2D2D"/>
            <Setter Property="BorderBrush" Value="#3F3F3F"/>
            <Setter Property="Margin" Value="5"/>
            <Setter Property="VerticalAlignment" Value="Center"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="RadioButton">
                        <StackPanel Orientation="Horizontal">
                            <Border Name="RadioBorder"
                                    Width="18" Height="18"
                                    Background="{TemplateBinding Background}"
                                    BorderBrush="{TemplateBinding BorderBrush}"
                                    BorderThickness="1"
                                    CornerRadius="9"
                                    VerticalAlignment="Center">
                                <Ellipse Name="RadioCheck"
                                        Width="10" Height="10"
                                        Fill="Transparent"
                                        Visibility="Collapsed"/>
                            </Border>
                            <ContentPresenter Margin="5,0,0,0"
                                            VerticalAlignment="Center"
                                            HorizontalAlignment="Left"/>
                        </StackPanel>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="RadioBorder" Property="Background" Value="#0078D4"/>
                                <Setter TargetName="RadioBorder" Property="BorderBrush" Value="#0078D4"/>
                                <Setter TargetName="RadioCheck" Property="Fill" Value="#FFFFFF"/>
                                <Setter TargetName="RadioCheck" Property="Visibility" Value="Visible"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="RadioBorder" Property="BorderBrush" Value="#0078D4"/>
                            </Trigger>
                            <MultiTrigger>
                                <MultiTrigger.Conditions>
                                    <Condition Property="IsChecked" Value="True"/>
                                    <Condition Property="IsMouseOver" Value="True"/>
                                </MultiTrigger.Conditions>
                                <Setter TargetName="RadioBorder" Property="Background" Value="#106EBE"/>
                                <Setter TargetName="RadioBorder" Property="BorderBrush" Value="#106EBE"/>
                            </MultiTrigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="RadioBorder" Property="Background" Value="#1A1A1A"/>
                                <Setter TargetName="RadioBorder" Property="BorderBrush" Value="#2D2D2D"/>
                                <Setter Property="Foreground" Value="#666666"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="Background" Value="#2D2D2D"/>
            <Setter Property="BorderBrush" Value="#3F3F3F"/>
            <Setter Property="Margin" Value="5"/>
            <Setter Property="VerticalAlignment" Value="Center"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="CheckBox">
                        <StackPanel Orientation="Horizontal">
                            <Border Name="CheckBoxBorder"
                                    Width="18" Height="18"
                                    Background="{TemplateBinding Background}"
                                    BorderBrush="{TemplateBinding BorderBrush}"
                                    BorderThickness="1"
                                    CornerRadius="3"
                                    VerticalAlignment="Center">
                                <Path Name="CheckMark"
                                      Stretch="Uniform"
                                      Fill="Transparent"
                                      Data="M 2,6 L 6,10 L 14,2"
                                      Stroke="#FFFFFF"
                                      StrokeThickness="2"
                                      StrokeStartLineCap="Round"
                                      StrokeEndLineCap="Round"
                                      StrokeLineJoin="Round"
                                      Margin="2"
                                      Visibility="Collapsed"/>
                            </Border>
                            <ContentPresenter Margin="5,0,0,0"
                                            VerticalAlignment="Center"
                                            HorizontalAlignment="Left"/>
                        </StackPanel>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="CheckBoxBorder" Property="Background" Value="#0078D4"/>
                                <Setter TargetName="CheckBoxBorder" Property="BorderBrush" Value="#0078D4"/>
                                <Setter TargetName="CheckMark" Property="Visibility" Value="Visible"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="CheckBoxBorder" Property="BorderBrush" Value="#0078D4"/>
                            </Trigger>
                            <MultiTrigger>
                                <MultiTrigger.Conditions>
                                    <Condition Property="IsChecked" Value="True"/>
                                    <Condition Property="IsMouseOver" Value="True"/>
                                </MultiTrigger.Conditions>
                                <Setter TargetName="CheckBoxBorder" Property="Background" Value="#106EBE"/>
                                <Setter TargetName="CheckBoxBorder" Property="BorderBrush" Value="#106EBE"/>
                            </MultiTrigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="CheckBoxBorder" Property="Background" Value="#1A1A1A"/>
                                <Setter TargetName="CheckBoxBorder" Property="BorderBrush" Value="#2D2D2D"/>
                                <Setter Property="Foreground" Value="#666666"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="Label">
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Padding" Value="5,2"/>
            <Setter Property="VerticalAlignment" Value="Center"/>
        </Style>

        <Style TargetType="GroupBox">
            <Setter Property="Background" Value="#1E1E1E"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="#3F3F3F"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Margin" Value="5"/>
            <Setter Property="Padding" Value="10"/>
            <Setter Property="FontWeight" Value="Bold"/>
        </Style>

        <Style TargetType="TabControl">
            <Setter Property="Background" Value="#1E1E1E"/>
            <Setter Property="BorderBrush" Value="#3F3F3F"/>
        </Style>

        <Style TargetType="TabItem">
            <Setter Property="Background" Value="#2D2D2D"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="#3F3F3F"/>
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border Name="Border" BorderThickness="1,1,1,0"
                                BorderBrush="#3F3F3F" CornerRadius="2,2,0,0" Margin="2,0">
                            <ContentPresenter x:Name="ContentSite"
                                            VerticalAlignment="Center"
                                            HorizontalAlignment="Center"
                                            ContentSource="Header" Margin="10,5"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#0078D4"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                            <Trigger Property="IsSelected" Value="False">
                                <Setter TargetName="Border" Property="Background" Value="#2D2D2D"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#106EBE"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="TextBlock">
            <Setter Property="Foreground" Value="#FFFFFF"/>
        </Style>

        <Style TargetType="ProgressBar">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#0078D4"/>
            <Setter Property="BorderBrush" Value="Transparent"/>
            <Setter Property="Height" Value="4"/>
        </Style>

        <Style TargetType="DataGrid">
            <Setter Property="Background" Value="#2D2D2D"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="#3F3F3F"/>
            <Setter Property="RowBackground" Value="#2D2D2D"/>
            <Setter Property="AlternatingRowBackground" Value="#252525"/>
            <Setter Property="HeadersVisibility" Value="All"/>
            <Setter Property="GridLinesVisibility" Value="All"/>
            <Setter Property="HorizontalGridLinesBrush" Value="#3F3F3F"/>
            <Setter Property="VerticalGridLinesBrush" Value="#3F3F3F"/>
        </Style>

        <Style TargetType="DataGridColumnHeader">
            <Setter Property="Background" Value="#2D2D2D"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="#3F3F3F"/>
            <Setter Property="Padding" Value="5"/>
            <Setter Property="FontWeight" Value="Bold"/>
        </Style>

        <Style TargetType="DataGridRow">
            <Setter Property="Background" Value="#2D2D2D"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Style.Triggers>
                <Trigger Property="IsSelected" Value="True">
                    <Setter Property="Background" Value="#0078D4"/>
                    <Setter Property="Foreground" Value="#FFFFFF"/>
                </Trigger>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#3E3E42"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style TargetType="DataGridCell">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="#3F3F3F"/>
            <Style.Triggers>
                <Trigger Property="IsSelected" Value="True">
                    <Setter Property="Background" Value="#0078D4"/>
                    <Setter Property="Foreground" Value="#FFFFFF"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style TargetType="ScrollViewer">
            <Setter Property="Background" Value="#2D2D2D"/>
            <Setter Property="BorderBrush" Value="#3F3F3F"/>
        </Style>

        <Style TargetType="ScrollBar">
            <Setter Property="Background" Value="#2D2D2D"/>
            <Setter Property="BorderBrush" Value="#3F3F3F"/>
            <Setter Property="Foreground" Value="#666666"/>
            <Setter Property="Width" Value="18"/>
            <Style.Triggers>
                <Trigger Property="Orientation" Value="Horizontal">
                    <Setter Property="Height" Value="18"/>
                    <Setter Property="Width" Value="Auto"/>
                </Trigger>
            </Style.Triggers>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Header -->
        <Border Grid.Row="0" Background="#252525" Padding="20" BorderBrush="#3F3F3F" BorderThickness="0,0,0,1">
            <StackPanel>
                <TextBlock Text="PowerShell Executor Builder"
                          FontSize="24" FontWeight="Bold"
                          Foreground="#FFFFFF" HorizontalAlignment="Center"/>
                <TextBlock Text="Create powerful PowerShell executables with embedded resources"
                          FontSize="13" Foreground="#CCCCCC"
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
                                        IsReadOnly="True"
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
                             HeadersVisibility="All">
                        <DataGrid.Columns>
                            <DataGridTextColumn Header="File Name" Binding="{Binding Name}" Width="200"/>
                            <DataGridTextColumn Header="File Path" Binding="{Binding FilePath}" Width="400"/>
                            <DataGridTextColumn Header="Type" Binding="{Binding FileType}" Width="100"/>
                            <DataGridTextColumn Header="Size" Binding="{Binding FileSize}" Width="100"/>
                        </DataGrid.Columns>
                    </DataGrid>

                    <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Center">
                        <Button Name="btnAddAsset" Content="Add Files"
                               Margin="10" Padding="20,10" MinWidth="140" FontSize="14"/>
                        <Button Name="btnRemoveAsset" Content="Remove Selected"
                               Margin="10" Padding="20,10" MinWidth="180" FontSize="14"/>
                    </StackPanel>
                </Grid>
            </TabItem>

            <!-- Code Signing Tab -->
            <TabItem Header="Code Signing">
                <ScrollViewer VerticalScrollBarVisibility="Auto">
                    <StackPanel Margin="15">

                        <!-- Enable Code Signing -->
                        <GroupBox Header="Enable Code Signing" Margin="0,0,0,15">
                            <StackPanel>
                                <CheckBox Name="chkEnableSigning" Content="Enable Authenticode signing for the executable"
                                         Margin="5" FontSize="13"/>
                                <TextBlock Text="Sign the executable with a code signing certificate to establish trust and authenticity."
                                          FontStyle="Italic" Foreground="Gray" Margin="10,5,5,10"/>
                            </StackPanel>
                        </GroupBox>

                        <!-- Certificate Source -->
                        <GroupBox Header="Certificate Source" Margin="0,0,0,15" Name="grpCertSource">
                            <StackPanel>
                                <RadioButton Name="rbWindowsStore" Content="Windows Certificate Store"
                                           GroupName="CertSource" IsChecked="True"
                                           Margin="5" FontSize="13"/>
                                <RadioButton Name="rbPfxFile" Content="PFX/P12 File"
                                           GroupName="CertSource"
                                           Margin="5,5,5,15" FontSize="13"/>

                                <!-- Windows Store Certificate Selection -->
                                <StackPanel Name="pnlWindowsStore">
                                    <TextBlock Text="Select Certificate from Windows Store:"
                                              Margin="5,0,5,5" FontWeight="Bold"/>
                                    <ComboBox Name="cmbCertificates" Margin="5"
                                            DisplayMemberPath="Subject" Height="30"/>
                                    <Button Name="btnRefreshCerts" Content="Refresh Certificates"
                                           Margin="5" Padding="10,5" HorizontalAlignment="Left"/>
                                </StackPanel>

                                <!-- PFX File Selection -->
                                <StackPanel Name="pnlPfxFile" Visibility="Collapsed">
                                    <TextBlock Text="PFX/P12 File Path:" Margin="5,0,5,5" FontWeight="Bold"/>
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        <TextBox Name="txtPfxPath" Grid.Column="0"
                                                IsReadOnly="True"
                                                Text="Select a PFX or P12 certificate file"/>
                                        <Button Name="btnBrowsePfx" Grid.Column="1"
                                               Content="Browse..." Margin="5,5,5,5"/>
                                    </Grid>
                                    <TextBlock Text="PFX Password:" Margin="5,10,5,5" FontWeight="Bold"/>
                                    <PasswordBox Name="txtPfxPassword" Margin="5" Height="30"/>
                                </StackPanel>
                            </StackPanel>
                        </GroupBox>

                        <!-- Certificate Details -->
                        <GroupBox Header="Certificate Details" Margin="0,0,0,15" Name="grpCertDetails">
                            <Grid>
                                <Grid.RowDefinitions>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="Auto"/>
                                </Grid.RowDefinitions>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="120"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>

                                <TextBlock Grid.Row="0" Grid.Column="0" Text="Subject:"
                                          Margin="5" FontWeight="Bold"/>
                                <TextBlock Grid.Row="0" Grid.Column="1" Name="lblCertSubject"
                                          Text="No certificate selected" Margin="5" Foreground="#CCCCCC"/>

                                <TextBlock Grid.Row="1" Grid.Column="0" Text="Issuer:"
                                          Margin="5" FontWeight="Bold"/>
                                <TextBlock Grid.Row="1" Grid.Column="1" Name="lblCertIssuer"
                                          Text="-" Margin="5" Foreground="#CCCCCC"/>

                                <TextBlock Grid.Row="2" Grid.Column="0" Text="Valid From:"
                                          Margin="5" FontWeight="Bold"/>
                                <TextBlock Grid.Row="2" Grid.Column="1" Name="lblCertValidFrom"
                                          Text="-" Margin="5" Foreground="#CCCCCC"/>

                                <TextBlock Grid.Row="3" Grid.Column="0" Text="Valid Until:"
                                          Margin="5" FontWeight="Bold"/>
                                <TextBlock Grid.Row="3" Grid.Column="1" Name="lblCertValidUntil"
                                          Text="-" Margin="5" Foreground="#CCCCCC"/>

                                <TextBlock Grid.Row="4" Grid.Column="0" Text="Thumbprint:"
                                          Margin="5" FontWeight="Bold"/>
                                <TextBlock Grid.Row="4" Grid.Column="1" Name="lblCertThumbprint"
                                          Text="-" Margin="5" Foreground="#CCCCCC"/>

                                <TextBlock Grid.Row="5" Grid.Column="0" Text="Status:"
                                          Margin="5" FontWeight="Bold"/>
                                <TextBlock Grid.Row="5" Grid.Column="1" Name="lblCertStatus"
                                          Text="-" Margin="5" Foreground="#CCCCCC"/>
                            </Grid>
                        </GroupBox>

                        <!-- Timestamp Server -->
                        <GroupBox Header="Timestamp Server" Margin="0,0,0,15" Name="grpTimestamp">
                            <StackPanel>
                                <TextBlock Text="Timestamp server ensures signature validity after certificate expiration."
                                          FontStyle="Italic" Foreground="Gray" Margin="5,0,5,10"/>
                                <TextBlock Text="Select Timestamp Server:" Margin="5,0,5,5" FontWeight="Bold"/>
                                <ComboBox Name="cmbTimestampServer" Margin="5" Height="30">
                                    <ComboBoxItem Content="DigiCert (http://timestamp.digicert.com)" IsSelected="True"/>
                                    <ComboBoxItem Content="Sectigo (http://timestamp.sectigo.com)"/>
                                    <ComboBoxItem Content="GlobalSign (http://timestamp.globalsign.com/tsa/r6advanced1)"/>
                                    <ComboBoxItem Content="Custom"/>
                                </ComboBox>
                                <TextBlock Text="Custom Timestamp URL:" Margin="5,10,5,5"
                                          FontWeight="Bold" Name="lblCustomTimestamp" Visibility="Collapsed"/>
                                <TextBox Name="txtCustomTimestamp" Margin="5"
                                        Visibility="Collapsed"
                                        Text="http://"/>
                            </StackPanel>
                        </GroupBox>

                        <!-- Self-Signed Certificate Creation -->
                        <GroupBox Header="Create Self-Signed Certificate (Testing Only)" Margin="0,0,0,15">
                            <StackPanel>
                                <TextBlock Text="WARNING: Self-signed certificates are NOT trusted by Windows and should only be used for testing."
                                          FontStyle="Italic" Foreground="#FFA500" Margin="5,0,5,10" TextWrapping="Wrap"/>
                                <Button Name="btnCreateSelfSigned" Content="Create Self-Signed Certificate"
                                       Margin="5" Padding="10,5" HorizontalAlignment="Left"/>
                            </StackPanel>
                        </GroupBox>

                    </StackPanel>
                </ScrollViewer>
            </TabItem>
        </TabControl>

        <!-- Build Section -->
        <Border Grid.Row="2" Background="#252525" Padding="15" BorderBrush="#3F3F3F" BorderThickness="0,1,0,0">
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
                       Background="#28A745" Foreground="White"
                       HorizontalAlignment="Center"/>

                <TextBlock Name="lblBuildStatus" Grid.Row="1"
                          Text="Ready to build your PowerShell executable"
                          HorizontalAlignment="Center" Margin="0,10,0,5"
                          FontSize="12" Foreground="#CCCCCC"/>

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

# Code Signing tab controls
$chkEnableSigning = $window.FindName("chkEnableSigning")
$rbWindowsStore = $window.FindName("rbWindowsStore")
$rbPfxFile = $window.FindName("rbPfxFile")
$grpCertSource = $window.FindName("grpCertSource")
$pnlWindowsStore = $window.FindName("pnlWindowsStore")
$pnlPfxFile = $window.FindName("pnlPfxFile")
$cmbCertificates = $window.FindName("cmbCertificates")
$btnRefreshCerts = $window.FindName("btnRefreshCerts")
$txtPfxPath = $window.FindName("txtPfxPath")
$btnBrowsePfx = $window.FindName("btnBrowsePfx")
$txtPfxPassword = $window.FindName("txtPfxPassword")
$grpCertDetails = $window.FindName("grpCertDetails")
$lblCertSubject = $window.FindName("lblCertSubject")
$lblCertIssuer = $window.FindName("lblCertIssuer")
$lblCertValidFrom = $window.FindName("lblCertValidFrom")
$lblCertValidUntil = $window.FindName("lblCertValidUntil")
$lblCertThumbprint = $window.FindName("lblCertThumbprint")
$lblCertStatus = $window.FindName("lblCertStatus")
$grpTimestamp = $window.FindName("grpTimestamp")
$cmbTimestampServer = $window.FindName("cmbTimestampServer")
$lblCustomTimestamp = $window.FindName("lblCustomTimestamp")
$txtCustomTimestamp = $window.FindName("txtCustomTimestamp")
$btnCreateSelfSigned = $window.FindName("btnCreateSelfSigned")

Write-DebugLog "All controls retrieved successfully"

# Global variables for data collections
Write-DebugLog "Creating ObservableCollection instances..."
$global:AssetItems = New-Object System.Collections.ObjectModel.ObservableCollection[PSObject]
$global:SelectedCertificate = $null
Write-DebugLog "Collections created successfully"


#region Code Signing Helper Functions

function Get-CodeSigningCertificates {
    <#
    .SYNOPSIS
        Retrieves code signing certificates from Windows Certificate Store
    #>
    try {
        Write-DebugLog "Retrieving code signing certificates from Windows Store..."

        # Get certificates from CurrentUser\My with CodeSigningCert filter
        $certs = @(Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert -ErrorAction SilentlyContinue)

        if ($certs.Count -gt 0) {
            Write-DebugLog "Found $($certs.Count) code signing certificate(s)"
            # Always return as array, even for single certificate
            return ,$certs
        } else {
            Write-DebugLog "No code signing certificates found in Windows Store" "WARN"
            return @()
        }
    }
    catch {
        Write-DebugLog "Error retrieving certificates: $_" "ERROR"
        return @()
    }
}

function Get-PfxCertificateSecure {
    <#
    .SYNOPSIS
        Loads a PFX certificate file with secure password handling
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$PfxFilePath,

        [Parameter(Mandatory=$true)]
        [System.Security.SecureString]$SecurePassword
    )

    try {
        Write-DebugLog "Loading PFX certificate from: $PfxFilePath"

        if (-not (Test-Path $PfxFilePath)) {
            throw "PFX file not found: $PfxFilePath"
        }

        # Convert SecureString to plain text for Get-PfxCertificate
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
        $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)

        # Load the PFX certificate
        $cert = Get-PfxCertificate -FilePath $PfxFilePath -Password (ConvertTo-SecureString -String $plainPassword -AsPlainText -Force)

        # Clear plain password from memory
        $plainPassword = $null
        [System.GC]::Collect()

        if ($cert) {
            Write-DebugLog "PFX certificate loaded successfully"
            return $cert
        } else {
            throw "Failed to load PFX certificate"
        }
    }
    catch {
        Write-DebugLog "Error loading PFX certificate: $_" "ERROR"
        return $null
    }
}

function Test-CertificateValidity {
    <#
    .SYNOPSIS
        Validates a code signing certificate
    #>
    param(
        [Parameter(Mandatory=$true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate
    )

    $result = @{
        Valid = $false
        Status = ""
        Message = ""
        WarningLevel = "None"  # None, Warning, Error
    }

    try {
        # Check 1: Has private key
        if (-not $Certificate.HasPrivateKey) {
            $result.Status = "[INVALID]"
            $result.Message = "Certificate does not have a private key"
            $result.WarningLevel = "Error"
            return $result
        }

        # Check 2: Not expired
        $now = Get-Date
        if ($Certificate.NotAfter -lt $now) {
            $result.Status = "[EXPIRED]"
            $result.Message = "Certificate expired on $($Certificate.NotAfter.ToString('yyyy-MM-dd'))"
            $result.WarningLevel = "Error"
            return $result
        }

        # Check 3: Not yet valid
        if ($Certificate.NotBefore -gt $now) {
            $result.Status = "[NOT YET VALID]"
            $result.Message = "Certificate not valid until $($Certificate.NotBefore.ToString('yyyy-MM-dd'))"
            $result.WarningLevel = "Error"
            return $result
        }

        # Check 4: Expiring soon (within 30 days)
        $daysUntilExpiry = ($Certificate.NotAfter - $now).Days
        if ($daysUntilExpiry -le 30) {
            $result.Status = "[EXPIRING SOON]"
            $result.Message = "Certificate expires in $daysUntilExpiry day(s)"
            $result.WarningLevel = "Warning"
            $result.Valid = $true
            return $result
        }

        # Check 5: Self-signed (informational)
        if ($Certificate.Subject -eq $Certificate.Issuer) {
            $result.Status = "[SELF-SIGNED]"
            $result.Message = "Self-signed certificate (not trusted by Windows)"
            $result.WarningLevel = "Warning"
            $result.Valid = $true
            return $result
        }

        # All checks passed
        $result.Status = "[VALID]"
        $result.Message = "Certificate is valid and trusted"
        $result.WarningLevel = "None"
        $result.Valid = $true
        return $result
    }
    catch {
        $result.Status = "[ERROR]"
        $result.Message = "Validation error: $_"
        $result.WarningLevel = "Error"
        return $result
    }
}

function Invoke-ExecutableSigning {
    <#
    .SYNOPSIS
        Signs an executable with Authenticode signature
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath,

        [Parameter(Mandatory=$true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,

        [Parameter(Mandatory=$false)]
        [string]$TimestampServer = "http://timestamp.digicert.com"
    )

    try {
        Write-DebugLog "Signing executable: $FilePath"
        Write-DebugLog "Certificate Subject: $($Certificate.Subject)"
        Write-DebugLog "Timestamp Server: $TimestampServer"

        # Verify file exists
        if (-not (Test-Path $FilePath)) {
            throw "File not found: $FilePath"
        }

        # Validate certificate before signing
        $validation = Test-CertificateValidity -Certificate $Certificate
        if (-not $validation.Valid) {
            throw "Certificate validation failed: $($validation.Message)"
        }

        # Sign the file with SHA256 and timestamping
        $signature = Set-AuthenticodeSignature -FilePath $FilePath `
                                               -Certificate $Certificate `
                                               -TimestampServer $TimestampServer `
                                               -HashAlgorithm SHA256 `
                                               -ErrorAction Stop

        if ($signature.Status -eq 'Valid') {
            Write-DebugLog "Executable signed successfully"
            return @{
                Success = $true
                Status = $signature.Status
                Message = "Executable signed successfully with $($Certificate.Subject)"
            }
        } else {
            throw "Signing failed with status: $($signature.Status)"
        }
    }
    catch {
        Write-DebugLog "Error signing executable: $_" "ERROR"
        return @{
            Success = $false
            Status = "Error"
            Message = "Signing failed: $_"
        }
    }
}

function New-SelfSignedCodeCert {
    <#
    .SYNOPSIS
        Creates a self-signed code signing certificate for testing
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$CertificateName = "PSEBuilder Test Certificate",

        [Parameter(Mandatory=$false)]
        [int]$ValidityYears = 2
    )

    try {
        Write-DebugLog "Creating self-signed code signing certificate..."

        # Create the certificate
        $cert = New-SelfSignedCertificate -Type CodeSigningCert `
                                          -Subject "CN=$CertificateName" `
                                          -CertStoreLocation "Cert:\CurrentUser\My" `
                                          -NotAfter (Get-Date).AddYears($ValidityYears) `
                                          -KeySpec Signature `
                                          -KeyLength 2048 `
                                          -KeyAlgorithm RSA `
                                          -HashAlgorithm SHA256 `
                                          -ErrorAction Stop

        if ($cert) {
            Write-DebugLog "Self-signed certificate created successfully"
            Write-DebugLog "Thumbprint: $($cert.Thumbprint)"

            return @{
                Success = $true
                Certificate = $cert
                Message = "Certificate created: $($cert.Subject)"
                Thumbprint = $cert.Thumbprint
            }
        } else {
            throw "Failed to create certificate"
        }
    }
    catch {
        Write-DebugLog "Error creating self-signed certificate: $_" "ERROR"
        return @{
            Success = $false
            Certificate = $null
            Message = "Failed to create certificate: $_"
            Thumbprint = $null
        }
    }
}

#endregion Code Signing Helper Functions


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


#region Code Signing Event Handlers

# Enable/Disable Code Signing Controls
$chkEnableSigning.Add_Checked({
    Write-DebugLog "Code signing enabled"
    $grpCertSource.IsEnabled = $true
    $grpCertDetails.IsEnabled = $true
    $grpTimestamp.IsEnabled = $true
})

$chkEnableSigning.Add_Unchecked({
    Write-DebugLog "Code signing disabled"
    $grpCertSource.IsEnabled = $false
    $grpCertDetails.IsEnabled = $false
    $grpTimestamp.IsEnabled = $false
})

# Toggle between Windows Store and PFX File
$rbWindowsStore.Add_Checked({
    Write-DebugLog "Windows Store certificate source selected"
    $pnlWindowsStore.Visibility = "Visible"
    $pnlPfxFile.Visibility = "Collapsed"

    # Refresh certificates
    $certs = Get-CodeSigningCertificates
    $cmbCertificates.ItemsSource = $certs
    if ($certs.Count -gt 0) {
        $cmbCertificates.SelectedIndex = 0
    }
})

$rbPfxFile.Add_Checked({
    Write-DebugLog "PFX file certificate source selected"
    $pnlWindowsStore.Visibility = "Collapsed"
    $pnlPfxFile.Visibility = "Visible"
})

# Refresh Certificates Button
$btnRefreshCerts.Add_Click({
    Write-DebugLog "Refreshing certificates"
    $certs = Get-CodeSigningCertificates
    $cmbCertificates.ItemsSource = $certs

    if ($certs.Count -eq 0) {
        [System.Windows.MessageBox]::Show("No code signing certificates found in Windows Certificate Store.`n`nYou can create a self-signed certificate for testing using the button at the bottom.", "No Certificates", "OK", "Information")
    } else {
        $cmbCertificates.SelectedIndex = 0
    }
})

# Certificate Selection Changed
$cmbCertificates.Add_SelectionChanged({
    $cert = $cmbCertificates.SelectedItem
    if ($cert) {
        Write-DebugLog "Certificate selected: $($cert.Subject)"
        $global:SelectedCertificate = $cert

        # Update certificate details
        $lblCertSubject.Text = $cert.Subject
        $lblCertIssuer.Text = $cert.Issuer
        $lblCertValidFrom.Text = $cert.NotBefore.ToString("yyyy-MM-dd HH:mm:ss")
        $lblCertValidUntil.Text = $cert.NotAfter.ToString("yyyy-MM-dd HH:mm:ss")
        $lblCertThumbprint.Text = $cert.Thumbprint

        # Validate certificate and update status
        $validation = Test-CertificateValidity -Certificate $cert
        $lblCertStatus.Text = $validation.Status + " - " + $validation.Message

        # Color-code status
        switch ($validation.WarningLevel) {
            "Error" { $lblCertStatus.Foreground = "#FF4444" }
            "Warning" { $lblCertStatus.Foreground = "#FFA500" }
            default { $lblCertStatus.Foreground = "#00FF00" }
        }
    }
})

# Browse PFX File
$btnBrowsePfx.Add_Click({
    Write-DebugLog "Browsing for PFX file"
    $openFileDialog = New-Object Microsoft.Win32.OpenFileDialog
    $openFileDialog.Filter = "Certificate Files (*.pfx;*.p12)|*.pfx;*.p12|All Files (*.*)|*.*"
    $openFileDialog.Title = "Select PFX Certificate File"

    if ($openFileDialog.ShowDialog() -eq $true) {
        $txtPfxPath.Text = $openFileDialog.FileName
        Write-DebugLog "PFX file selected: $($openFileDialog.FileName)"

        # Prompt for password and load certificate
        if ($txtPfxPassword.SecurePassword.Length -gt 0) {
            $cert = Get-PfxCertificateSecure -PfxFilePath $openFileDialog.FileName -SecurePassword $txtPfxPassword.SecurePassword

            if ($cert) {
                $global:SelectedCertificate = $cert

                # Update certificate details
                $lblCertSubject.Text = $cert.Subject
                $lblCertIssuer.Text = $cert.Issuer
                $lblCertValidFrom.Text = $cert.NotBefore.ToString("yyyy-MM-dd HH:mm:ss")
                $lblCertValidUntil.Text = $cert.NotAfter.ToString("yyyy-MM-dd HH:mm:ss")
                $lblCertThumbprint.Text = $cert.Thumbprint

                # Validate certificate
                $validation = Test-CertificateValidity -Certificate $cert
                $lblCertStatus.Text = $validation.Status + " - " + $validation.Message

                switch ($validation.WarningLevel) {
                    "Error" { $lblCertStatus.Foreground = "#FF4444" }
                    "Warning" { $lblCertStatus.Foreground = "#FFA500" }
                    default { $lblCertStatus.Foreground = "#00FF00" }
                }
            } else {
                [System.Windows.MessageBox]::Show("Failed to load PFX certificate. Please check the password.", "Error", "OK", "Error")
            }
        } else {
            [System.Windows.MessageBox]::Show("Please enter the PFX password first.", "Password Required", "OK", "Warning")
        }
    }
})

# PFX Password Changed - Auto-load certificate when password is entered
$txtPfxPassword.Add_PasswordChanged({
    if ($txtPfxPath.Text -ne "Select a PFX or P12 certificate file" -and (Test-Path $txtPfxPath.Text)) {
        if ($txtPfxPassword.SecurePassword.Length -gt 0) {
            Write-DebugLog "PFX password entered, loading certificate..."
            $cert = Get-PfxCertificateSecure -PfxFilePath $txtPfxPath.Text -SecurePassword $txtPfxPassword.SecurePassword

            if ($cert) {
                $global:SelectedCertificate = $cert

                # Update certificate details
                $lblCertSubject.Text = $cert.Subject
                $lblCertIssuer.Text = $cert.Issuer
                $lblCertValidFrom.Text = $cert.NotBefore.ToString("yyyy-MM-dd HH:mm:ss")
                $lblCertValidUntil.Text = $cert.NotAfter.ToString("yyyy-MM-dd HH:mm:ss")
                $lblCertThumbprint.Text = $cert.Thumbprint

                # Validate certificate
                $validation = Test-CertificateValidity -Certificate $cert
                $lblCertStatus.Text = $validation.Status + " - " + $validation.Message

                switch ($validation.WarningLevel) {
                    "Error" { $lblCertStatus.Foreground = "#FF4444" }
                    "Warning" { $lblCertStatus.Foreground = "#FFA500" }
                    default { $lblCertStatus.Foreground = "#00FF00" }
                }
            }
        }
    }
})

# Timestamp Server Selection Changed
$cmbTimestampServer.Add_SelectionChanged({
    $selected = $cmbTimestampServer.SelectedItem
    if ($selected.Content -eq "Custom") {
        Write-DebugLog "Custom timestamp server selected"
        $lblCustomTimestamp.Visibility = "Visible"
        $txtCustomTimestamp.Visibility = "Visible"
    } else {
        Write-DebugLog "Timestamp server selected: $($selected.Content)"
        $lblCustomTimestamp.Visibility = "Collapsed"
        $txtCustomTimestamp.Visibility = "Collapsed"
    }
})

# Create Self-Signed Certificate
$btnCreateSelfSigned.Add_Click({
    Write-DebugLog "Creating self-signed certificate"

    # Prompt for certificate name
    $certName = [Microsoft.VisualBasic.Interaction]::InputBox(
        "Enter a name for the self-signed certificate:",
        "Create Self-Signed Certificate",
        "PSEBuilder Test Certificate"
    )

    if ($certName) {
        $result = New-SelfSignedCodeCert -CertificateName $certName -ValidityYears 2

        if ($result.Success) {
            [System.Windows.MessageBox]::Show(
                "Self-signed certificate created successfully!`n`n$($result.Message)`nThumbprint: $($result.Thumbprint)`n`nWARNING: This certificate is self-signed and will NOT be trusted by Windows. It should only be used for testing.",
                "Success",
                "OK",
                "Information"
            )

            # Refresh the certificate list
            $certs = Get-CodeSigningCertificates
            $cmbCertificates.ItemsSource = $certs

            # Select the newly created certificate
            $newCert = $certs | Where-Object { $_.Thumbprint -eq $result.Thumbprint }
            if ($newCert) {
                $cmbCertificates.SelectedItem = $newCert
            }
        } else {
            [System.Windows.MessageBox]::Show(
                "Failed to create self-signed certificate.`n`n$($result.Message)",
                "Error",
                "OK",
                "Error"
            )
        }
    }
})

# Initialize Code Signing tab (disable controls by default)
$grpCertSource.IsEnabled = $false
$grpCertDetails.IsEnabled = $false
$grpTimestamp.IsEnabled = $false

# Load initial certificates
$certs = Get-CodeSigningCertificates
$cmbCertificates.ItemsSource = $certs
if ($certs.Count -gt 0) {
    $cmbCertificates.SelectedIndex = 0
}

#endregion Code Signing Event Handlers


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
            # Check if executable was signed
            if ($chkEnableSigning.IsChecked -eq $true -and $global:SelectedCertificate) {
                # Verify signature
                $signature = Get-AuthenticodeSignature -FilePath $txtOutputFile.Text
                if ($signature.Status -eq 'Valid') {
                    $lblBuildStatus.Text = "Build completed successfully! (Signed)"
                } else {
                    $lblBuildStatus.Text = "Build completed successfully! (Signing failed)"
                }
            } else {
                $lblBuildStatus.Text = "Build completed successfully!"
            }

            $fileInfo = Get-Item $txtOutputFile.Text
            $size = Get-FileSize $txtOutputFile.Text

            $message = "Executable created successfully!`n`n"
            $message += "Path: $($txtOutputFile.Text)`n"
            $message += "Size: $size`n`n"

            # Add signature status
            if ($chkEnableSigning.IsChecked -eq $true) {
                if ($global:SelectedCertificate) {
                    $signature = Get-AuthenticodeSignature -FilePath $txtOutputFile.Text
                    if ($signature.Status -eq 'Valid') {
                        $message += "Code Signature: [VALID]`n"
                        $message += "Signer: $($signature.SignerCertificate.Subject)`n"
                        $message += "Timestamp: $($signature.TimeStamperCertificate.Subject)`n`n"
                    } else {
                        $message += "Code Signature: [WARNING] $($signature.Status)`n`n"
                    }
                } else {
                    $message += "Code Signature: [ERROR] No certificate selected`n`n"
                }
            }

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
using System.Linq;
using System.Windows.Forms;
using System.Drawing;

[assembly: AssemblyTitle("$escapedTitle")]
[assembly: AssemblyDescription("$escapedDescription")]
[assembly: AssemblyCompany("$escapedCompany")]
[assembly: AssemblyProduct("$escapedTitle")]
[assembly: AssemblyCopyright("Copyright © $escapedCopyright")]
[assembly: AssemblyVersion("$escapedVersion")]
[assembly: AssemblyFileVersion("$escapedVersion")]

namespace $namespace
{
    /// <summary>
    /// Hidden form that hosts PowerShell child process and displays custom icon in taskbar
    /// </summary>
    class PowerShellHostForm : Form
    {
        private Process _process;
        private Timer _monitorTimer;
        private int _exitCode = 0;
        private int _timeoutMinutes = 0;
        private DateTime _startTime;

        public int ExitCode { get { return _exitCode; } }

        public PowerShellHostForm(int timeoutMinutes)
        {
            _timeoutMinutes = timeoutMinutes;
            _startTime = DateTime.Now;

            // Configure form to be invisible but show in taskbar
            var titleAttr = Assembly.GetExecutingAssembly().GetCustomAttribute<AssemblyTitleAttribute>();
            this.Text = titleAttr != null ? titleAttr.Title : "PowerShell Application";
            this.Size = new Size(1, 1);
            this.StartPosition = FormStartPosition.Manual;
            this.Location = new Point(-10000, -10000);
            this.ShowInTaskbar = true;
            this.WindowState = FormWindowState.Minimized;
            this.Opacity = 0.01; // Nearly invisible but still registers in taskbar

            // Extract and set icon
            try
            {
                string exePath = Assembly.GetExecutingAssembly().Location;
                this.Icon = Icon.ExtractAssociatedIcon(exePath);
            }
            catch
            {
                // Fallback to default icon if extraction fails
            }

            // Setup process monitor
            _monitorTimer = new Timer();
            _monitorTimer.Interval = 100; // Check every 100ms
            _monitorTimer.Tick += MonitorProcess;
        }

        public void StartPowerShellProcess(Process process)
        {
            _process = process;
            _monitorTimer.Start();
        }

        private void MonitorProcess(object sender, EventArgs e)
        {
            if (_process != null)
            {
                // Check for timeout
                if (_timeoutMinutes > 0)
                {
                    TimeSpan elapsed = DateTime.Now - _startTime;
                    if (elapsed.TotalMinutes >= _timeoutMinutes)
                    {
                        try
                        {
                            if (!_process.HasExited)
                            {
                                _process.Kill();
                                _exitCode = -1;
                            }
                        }
                        catch { }
                        _monitorTimer.Stop();
                        this.Close();
                        return;
                    }
                }

                // Check if process exited
                if (_process.HasExited)
                {
                    _exitCode = _process.ExitCode;
                    _monitorTimer.Stop();
                    this.Close();
                }
            }
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                if (_monitorTimer != null)
                {
                    _monitorTimer.Dispose();
                }
            }
            base.Dispose(disposing);
        }
    }

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

                // Automatic PowerShell 7+ detection with fallback to 5.1
                string psExecutable = FindPowerShellExecutable();
                string psVersion = psExecutable.Contains("pwsh") ? "PowerShell 7+" : "Windows PowerShell 5.1";

                if ($showWindow)
                {
                    Console.WriteLine("Using: " + psVersion + " (" + psExecutable + ")");
                }

                string psCommand = string.Format("-ExecutionPolicy $executionPolicy -File \`"{0}\`"", scriptPath);

                if (args.Length > 0)
                {
                    psCommand += " " + string.Join(" ", args);
                }

                var psi = new ProcessStartInfo
                {
                    FileName = psExecutable,
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
                int exitCode = 0;

                // Check if icon was embedded to decide on GUI vs console mode
                bool hasIcon = false;
                try
                {
                    Icon testIcon = Icon.ExtractAssociatedIcon(Assembly.GetExecutingAssembly().Location);
                    hasIcon = (testIcon != null && testIcon.Handle != IntPtr.Zero);
                }
                catch { }

                // Use GUI wrapper for taskbar icon display when:
                // 1. Icon is embedded
                // 2. ShowWindow is false (don't show PowerShell console)
                if (hasIcon && !$showWindow)
                {
                    // Use Windows Forms for proper taskbar icon display
                    Application.EnableVisualStyles();
                    Application.SetCompatibleTextRenderingDefault(false);

                    var form = new PowerShellHostForm(timeoutMinutes);
                    form.StartPowerShellProcess(process);
                    Application.Run(form);

                    exitCode = form.ExitCode;
                }
                else
                {
                    // Original console-based waiting (for ShowWindow=true or no icon)
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

                    exitCode = exited ? process.ExitCode : -1;
                }

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

        /// <summary>
        /// Finds PowerShell executable with preference for PowerShell 7+ (pwsh.exe)
        /// Falls back to Windows PowerShell 5.1 (powershell.exe) if pwsh not found
        /// </summary>
        static string FindPowerShellExecutable()
        {
            // First try PowerShell 7+ (pwsh.exe)
            string pwsh = FindExecutableInPath("pwsh.exe");
            if (!string.IsNullOrEmpty(pwsh))
            {
                return pwsh;
            }

            // Fallback to Windows PowerShell 5.1 (powershell.exe)
            string ps5 = FindExecutableInPath("powershell.exe");
            if (!string.IsNullOrEmpty(ps5))
            {
                return ps5;
            }

            // Last resort: return powershell.exe and let OS handle the error
            return "powershell.exe";
        }

        /// <summary>
        /// Searches for executable in PATH environment variable
        /// </summary>
        static string FindExecutableInPath(string executableName)
        {
            try
            {
                string pathEnv = Environment.GetEnvironmentVariable("PATH");
                if (string.IsNullOrEmpty(pathEnv))
                {
                    return null;
                }

                var paths = pathEnv.Split(';').Where(p => !string.IsNullOrWhiteSpace(p));

                foreach (string dir in paths)
                {
                    try
                    {
                        string fullPath = Path.Combine(dir.Trim(), executableName);
                        if (File.Exists(fullPath))
                        {
                            return fullPath;
                        }
                    }
                    catch
                    {
                        // Skip invalid paths
                        continue;
                    }
                }
            }
            catch
            {
                // PATH parsing failed
            }

            return null;
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
            "/reference:System.Windows.Forms.dll",
            "/reference:System.Drawing.dll",
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

            # Code Signing Integration
            if ($chkEnableSigning.IsChecked -eq $true) {
                Write-DebugLog "Code signing is enabled, proceeding with signature..."

                if ($global:SelectedCertificate) {
                    try {
                        # Get timestamp server URL
                        $timestampUrl = "http://timestamp.digicert.com"  # Default
                        $selectedTimestamp = $cmbTimestampServer.SelectedItem

                        if ($selectedTimestamp.Content -eq "Custom") {
                            $timestampUrl = $txtCustomTimestamp.Text
                            if ([string]::IsNullOrWhiteSpace($timestampUrl) -or $timestampUrl -eq "http://") {
                                Write-DebugLog "Custom timestamp URL is invalid, using default DigiCert" "WARN"
                                $timestampUrl = "http://timestamp.digicert.com"
                            }
                        } elseif ($selectedTimestamp.Content -like "*Sectigo*") {
                            $timestampUrl = "http://timestamp.sectigo.com"
                        } elseif ($selectedTimestamp.Content -like "*GlobalSign*") {
                            $timestampUrl = "http://timestamp.globalsign.com/tsa/r6advanced1"
                        }

                        Write-DebugLog "Signing executable with timestamp server: $timestampUrl"

                        # Sign the executable
                        $signResult = Invoke-ExecutableSigning -FilePath $OutputPath `
                                                               -Certificate $global:SelectedCertificate `
                                                               -TimestampServer $timestampUrl

                        if ($signResult.Success) {
                            Write-DebugLog "=== EXECUTABLE SIGNED SUCCESSFULLY ==="
                            Write-DebugLog $signResult.Message
                        } else {
                            Write-DebugLog "=== SIGNING FAILED ===" "WARN"
                            Write-DebugLog $signResult.Message "WARN"
                            # Note: We don't throw here because the exe was built successfully
                            # Signing failure is non-critical (exe still works)
                        }
                    }
                    catch {
                        Write-DebugLog "Error during code signing: $($_.Exception.Message)" "WARN"
                        # Non-critical error, exe still built successfully
                    }
                } else {
                    Write-DebugLog "Code signing enabled but no certificate selected" "WARN"
                }
            } else {
                Write-DebugLog "Code signing is disabled, skipping signature"
            }

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