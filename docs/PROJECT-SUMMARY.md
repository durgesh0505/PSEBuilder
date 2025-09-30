# PowerShell Executor Builder - Project Summary

## Overview

A complete GUI application for creating standalone Windows executables from PowerShell scripts with embedded resources (scripts, images, certificates, config files).

## Key Features

- **Modern WPF/XAML GUI** - Tabbed interface with file management
- **Resource Embedding** - Embed any files as base64 in executable
- **No Dependencies** - Uses built-in .NET compiler (no Visual Studio)
- **Self-Contained Executables** - Scripts run with embedded resources
- **Comprehensive Logging** - Debug logs saved to Downloads folder
- **File Lock Detection** - Automatically detects and handles locked output files

## Project Files

### Main Application
- **PSEBuilder-XAML-Fixed2.ps1** - GUI builder application (1400+ lines)
  - Integrated exe builder (no external scripts needed)
  - WPF/XAML interface with 5 tabs
  - Comprehensive logging
  - File lock detection

### Test Application
- **examples/test-gui-app.ps1** - Demo app with resource loading
  - Reads embedded text files
  - Displays embedded images
  - Shows resource detection in action

### Utilities
- **Close-TestGUI.bat** - Force-close running test executables
- **USAGE-GUIDE.md** - Complete usage instructions
- **COMPREHENSIVE-DOCUMENTATION.md** - Full technical documentation

### Example Resources
- **examples/test.txt** - Sample text file
- **examples/image.png** - Sample image (400x300)
- **examples/test-gui-config.json** - Example configuration

## Technical Architecture

### Build Process
1. GUI collects configuration
2. Files embedded as base64 strings
3. C# code generated dynamically
4. Add-Type compiles with csc.exe
5. Standalone .exe created

### Runtime Process
1. Executable extracts resources to temp folder
2. Sets PS_RESOURCE_DIR environment variable
3. Executes PowerShell with main script
4. Resources available in temp directory
5. Cleanup on exit

### Resource Detection Pattern
```powershell
# Scripts check this environment variable first
if ($env:PS_RESOURCE_DIR) {
    $resourcePath = Join-Path $env:PS_RESOURCE_DIR $fileName
    if (Test-Path $resourcePath) {
        # Use embedded resource
    }
}
```

## Key Components

### GUI Tabs

1. **Basic Configuration**
   - Main script selection
   - Executable metadata
   - Execution options
   - Output file location

2. **Scripts**
   - Add multiple PowerShell scripts
   - Set execution order
   - Mark default script

3. **Certificates**
   - Embed .pfx, .cer, .crt files
   - Certificate deployment scenarios

4. **Assets**
   - Images, text, config files
   - Any binary files

5. **Preview**
   - JSON configuration view
   - Save/Load configurations
   - Validation

### Build Function

Located in PSEBuilder-XAML-Fixed2.ps1 (lines 1063-1362):
- Validates all files exist
- Embeds resources as base64
- Generates C# runtime code
- Compiles executable
- Returns success/failure

### C# Runtime Code

Generated dynamically:
- Dictionary of embedded resources
- Resource extraction logic
- PowerShell process execution
- Timeout handling
- Admin elevation support
- Cleanup operations

## Problem Solving History

### Issue 1: DataGrid Binding Errors
**Problem**: Empty ObservableCollection binding during ShowDialog()
**Solution**: Set ItemsSource only when first item added

### Issue 2: Browse Buttons Not Working
**Problem**: Windows Forms dialogs caused cross-framework issues
**Solution**: Use Microsoft.Win32.OpenFileDialog (WPF native)

### Issue 3: Resources Not Found
**Problem**: Scripts couldn't find embedded resources
**Solution**: Set PS_RESOURCE_DIR environment variable

### Issue 4: File Locked Errors
**Problem**: Can't rebuild while exe is running
**Solution**: Check file lock, prompt user, retry mechanism

### Issue 5: Unreachable Code Warning
**Problem**: Code after Process.Start() with redirection
**Solution**: Conditional output redirection based on window visibility

## Current Status

### Working Features
- Full GUI with all tabs functional
- Browse buttons for all file types
- Multiple file selection
- Resource embedding (scripts, certs, assets)
- Configuration preview
- Save/Load configurations
- Build executable directly in GUI
- Comprehensive logging
- File lock detection
- Test application with resource loading

### Tested Scenarios
- Building simple executables
- Embedding text files and images
- Running as standalone executable
- Resource extraction and access
- File lock detection and retry

## Usage

### Quick Start
```powershell
# Launch GUI
powershell.exe -File PSEBuilder-XAML-Fixed2.ps1

# Select main script
# Add assets (optional)
# Click "Build Executable"
```

### For Test GUI
```powershell
# Launch GUI
# Main Script: examples/test-gui-app.ps1
# Assets: test.txt, image.png
# Output: testgui.exe
# Build and run!
```

## Logs

All logs saved to: `%USERPROFILE%\Downloads\`
- PSEBuilder-Debug-YYYYMMDD-HHMMSS.log

## Requirements

- Windows 10/11 or Server 2016+
- PowerShell 5.1+
- .NET Framework 4.5+ (built-in)
- No Visual Studio
- No external packages

## Advantages Over PS2EXE

1. **GUI Interface** - Visual configuration vs command-line
2. **Integrated Builder** - No separate scripts needed
3. **Resource Management** - Visual file management
4. **Comprehensive Logging** - Detailed debug information
5. **File Lock Detection** - Automatic conflict resolution
6. **Configuration Save/Load** - Reusable project configs

## Future Enhancements (Optional)

- Digital signature support
- Multiple output formats
- Script obfuscation
- Custom icon from image files
- Resource compression
- Build profiles
- Command-line mode

## File Structure

```
Project Root/
├── PSEBuilder-XAML-Fixed2.ps1    # Main GUI application
├── Close-TestGUI.bat             # Utility to close test apps
├── USAGE-GUIDE.md                # User documentation
├── COMPREHENSIVE-DOCUMENTATION.md # Technical documentation
├── PROJECT-SUMMARY.md            # This file
├── examples/
│   ├── test-gui-app.ps1          # Demo application
│   ├── test.txt                  # Sample text resource
│   ├── image.png                 # Sample image resource
│   └── test-gui-config.json      # Example configuration
└── Downloads/ (user folder)
    └── PSEBuilder-Debug-*.log    # Build logs
```

## Credits

Built using:
- Windows Presentation Foundation (WPF)
- PowerShell Add-Type with csc.exe
- .NET Framework CodeDom compiler
- XAML for modern UI

## Version

Current Version: 1.0
Date: 2025-09-29

## Notes

- All special characters/Unicode symbols removed for compatibility
- Exe builder integrated into GUI (no external PSEBuilder.ps1 needed)
- Environment variable approach for resource detection
- File lock detection with user-friendly retry prompts
- Comprehensive logging for troubleshooting