# PowerShell Executor Builder - Usage Guide

## Quick Start

### 1. Launch the GUI Builder
```powershell
powershell.exe -File PSEBuilder-XAML-Fixed2.ps1
```

### 2. Configure Your Executable

#### Basic Configuration Tab
- **Main Script**: Browse and select your primary PowerShell script (.ps1)
- **Executable Information**: Set name, version, description, company, copyright
- **Icon File**: Optional .ico file for your executable
- **Execution Options**:
  - Require Administrator: Check if elevation is needed
  - Show PowerShell Window: Check to show console output
  - Timeout: Maximum execution time in minutes
  - Execution Policy: Bypass, Unrestricted, RemoteSigned, or AllSigned
  - Working Directory: Where the script will run
- **Output File**: Choose where to save the .exe

#### Scripts Tab
- Add additional PowerShell scripts that will be embedded
- Move scripts up/down to change execution order
- Edit script names and descriptions

#### Certificates Tab
- Add certificate files (.pfx, .cer, .crt) for secure deployment
- Useful for certificate installation scripts

#### Assets Tab
- Add any additional files (images, text, config files, etc.)
- These files will be embedded and extracted at runtime

#### Preview Tab
- View the generated JSON configuration
- Save/Load configurations for reuse
- Validate configuration before building

### 3. Build the Executable

Click **"Build Executable"** button. The build process will:
1. Validate all files exist
2. Embed all resources as base64
3. Generate C# runtime code
4. Compile using built-in .NET compiler
5. Create standalone .exe file

**Build logs** are automatically saved to your Downloads folder.

## Troubleshooting

### Error: "File is locked" or "Cannot access file"

**Problem**: The output .exe is still running or locked by another process.

**Solutions**:
1. Close any running instances of your executable
2. Run `Close-TestGUI.bat` to force-close test executables
3. Click "Yes" when prompted to retry after waiting
4. Manually delete the old .exe and rebuild

### Resources Not Found in Executable

**Problem**: Embedded assets (test.txt, image.png) not found when running .exe

**Solution**: Ensure your PowerShell script uses the resource detection pattern:

```powershell
function Get-ResourcePath {
    param([string]$FileName)

    # Check environment variable set by executable runtime
    if ($env:PS_RESOURCE_DIR) {
        $resourcePath = Join-Path $env:PS_RESOURCE_DIR $FileName
        if (Test-Path $resourcePath) {
            return $resourcePath
        }
    }

    # Fallback to script directory (when running as .ps1)
    $scriptDir = $PSScriptRoot
    if (-not $scriptDir) { $scriptDir = Get-Location }
    $localPath = Join-Path $scriptDir $FileName
    if (Test-Path $localPath) {
        return $localPath
    }

    return $null
}

# Use it like this:
$textFilePath = Get-ResourcePath "test.txt"
if ($textFilePath) {
    $content = Get-Content $textFilePath
}
```

### Build Fails with Compilation Errors

**Check the build log** in your Downloads folder (PSEBuilder-Debug-YYYYMMDD-HHMMSS.log)

Common issues:
- **Missing files**: Verify all scripts/assets exist at specified paths
- **Invalid paths**: Use absolute paths or paths relative to GUI location
- **PowerShell syntax errors**: Test your .ps1 scripts before embedding
- **Large files**: Very large embedded resources may cause memory issues

### GUI Browse Buttons Not Working

**Problem**: File selection dialogs don't open

**Solution**:
- Run as administrator if needed
- Check Windows Defender/Antivirus isn't blocking
- Verify PowerShell execution policy: `Get-ExecutionPolicy`

## How It Works

### The Build Process

1. **Resource Embedding**:
   - All files are read as binary
   - Converted to base64 strings
   - Embedded directly in C# code

2. **Runtime Extraction**:
   - Executable creates temp directory: `%TEMP%\PSExecutor_{GUID}`
   - Extracts all embedded resources to temp folder
   - Sets `PS_RESOURCE_DIR` environment variable
   - Executes PowerShell script with resources available

3. **Cleanup**:
   - Temp directory is deleted after execution
   - Exit code is propagated from PowerShell script

### Architecture

```
PSEBuilder-XAML-Fixed2.ps1 (GUI)
    |
    +--> Build-Executable Function
         |
         +--> Embed Resources (base64)
         |
         +--> Generate C# Code
         |
         +--> Compile with Add-Type
         |
         +--> Output .exe

Your .exe File
    |
    +--> Extract resources to temp folder
    |
    +--> Set PS_RESOURCE_DIR environment variable
    |
    +--> Execute PowerShell.exe with your script
    |
    +--> Cleanup temp folder
```

## Example: Creating Test GUI Executable

1. **Prepare Files**:
   - `examples/test-gui-app.ps1` - Your main GUI script
   - `examples/test.txt` - Text file to embed
   - `examples/image.png` - Image file to embed

2. **Launch Builder**:
   ```powershell
   powershell.exe -File PSEBuilder-XAML-Fixed2.ps1
   ```

3. **Configure**:
   - Main Script: Browse to `test-gui-app.ps1`
   - Assets Tab: Add `test.txt` and `image.png`
   - Output: `C:\Users\YourName\Downloads\testgui.exe`
   - Check "Show PowerShell Window" to see debug output

4. **Build**: Click "Build Executable"

5. **Test**: Run `testgui.exe` - it will:
   - Show startup information
   - Display resource directory path
   - Load embedded test.txt and image.png
   - Work standalone without the original files

## Advanced Usage

### Multiple Scripts

Add scripts in the **Scripts Tab** to include libraries or modules:

```
Main Script: myapp.ps1
Additional Scripts:
  - utils.ps1 (helper functions)
  - config.ps1 (configuration)
  - logger.ps1 (logging module)
```

All scripts are extracted and available in `$env:PS_RESOURCE_DIR`.

### Certificate Installation

Use the **Certificates Tab** for certificate deployment:

1. Add .pfx or .cer files
2. In your main script:
```powershell
$certPath = Get-ResourcePath "mycert.pfx"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certPath, $password)
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", "LocalMachine")
$store.Open("ReadWrite")
$store.Add($cert)
$store.Close()
```

### Configuration Files

Embed JSON/XML/INI config files as assets:

```powershell
$configPath = Get-ResourcePath "app-config.json"
$config = Get-Content $configPath | ConvertFrom-Json
```

## Log Files

### GUI Debug Log
- Location: `%USERPROFILE%\Downloads\PSEBuilder-Debug-YYYYMMDD-HHMMSS.log`
- Contains: GUI operations, control loading, event handling

### Build Log
- Location: Same as GUI log (appended)
- Contains: Build process, resource embedding, compilation details

## Best Practices

1. **Test scripts first**: Run your .ps1 files normally before building
2. **Use relative paths**: In your scripts, use `Get-ResourcePath` function
3. **Check file sizes**: Very large embedded resources increase .exe size
4. **Version your configs**: Save/Load configurations from Preview tab
5. **Read the logs**: Check Downloads folder logs when troubleshooting
6. **Close before rebuild**: Always close running executables before rebuilding

## Requirements

- Windows 10/11 or Windows Server 2016+
- PowerShell 5.1 or later
- .NET Framework 4.5+ (pre-installed on modern Windows)
- No Visual Studio required
- No external dependencies

## Support

Check the comprehensive documentation: `COMPREHENSIVE-DOCUMENTATION.md`

For issues, review the debug logs in your Downloads folder.