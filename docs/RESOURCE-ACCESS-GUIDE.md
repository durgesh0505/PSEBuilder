# Resource Access Guide

Complete guide for accessing embedded resources in PowerShell executables created with PSEBuilder.

## Table of Contents

- [Overview](#overview)
- [How Resource Embedding Works](#how-resource-embedding-works)
- [The Get-ResourcePath Function](#the-get-resourcepath-function)
- [Usage Examples](#usage-examples)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

When you build a PowerShell executable with PSEBuilder, all files added in the **Assets** tab are embedded directly into the executable. At runtime, these files are automatically extracted to a temporary directory, making them accessible to your PowerShell script.

## How Resource Embedding Works

### Build Time Process

1. **File Selection**: You add files in the Assets tab (images, configs, certificates, text files, etc.)
2. **Base64 Encoding**: Each file is converted to base64 and embedded in the C# wrapper code
3. **Naming Convention**: Files are stored with the prefix `asset_<filename>` and keep their original extensions
4. **Compilation**: The C# code with embedded resources is compiled into a single .exe file

### Runtime Process

1. **Extraction**: When the .exe runs, it creates a temporary directory:
   ```
   %TEMP%\PSExecutor_{GUID}\
   Example: C:\Users\YourName\AppData\Local\Temp\PSExecutor_a1b2c3d4\
   ```

2. **File Creation**: All embedded files are written to this directory with their **original filenames**:
   - `test.txt`
   - `image.png`
   - `config.json`
   - `certificate.pfx`

3. **Environment Variable**: The exe sets `$env:PS_RESOURCE_DIR` to the extraction path

4. **Script Execution**: Your main PowerShell script runs with access to all extracted files

## The Get-ResourcePath Function

This is the recommended function for accessing embedded resources. It handles both exe and development environments.

### Complete Implementation

```powershell
function Get-ResourcePath {
    param([string]$FileName)

    # Method 1: Check PS_RESOURCE_DIR (set by executable)
    if ($env:PS_RESOURCE_DIR) {
        $resourcePath = Join-Path $env:PS_RESOURCE_DIR $FileName
        if (Test-Path $resourcePath) {
            Write-Verbose "Found resource in PS_RESOURCE_DIR: $resourcePath"
            return $resourcePath
        }
    }

    # Method 2: Check script directory (for development)
    if ($PSScriptRoot) {
        $resourcePath = Join-Path $PSScriptRoot $FileName
        if (Test-Path $resourcePath) {
            Write-Verbose "Found resource in script directory: $resourcePath"
            return $resourcePath
        }
    }

    # Method 3: Check working directory (fallback)
    $resourcePath = Join-Path (Get-Location) $FileName
    if (Test-Path $resourcePath) {
        Write-Verbose "Found resource in working directory: $resourcePath"
        return $resourcePath
    }

    # Method 4: Check temp directory (last resort)
    $tempPath = Join-Path $env:TEMP $FileName
    if (Test-Path $tempPath) {
        Write-Verbose "Found resource in temp directory: $tempPath"
        return $tempPath
    }

    Write-Warning "Resource not found: $FileName"
    return $null
}
```

### Why This Function?

- **Works in both exe and development**: Checks multiple locations
- **Safe**: Uses `Test-Path` to verify file exists before returning
- **Flexible**: Falls back to script directory for testing
- **Debuggable**: Returns `$null` if file not found (easy to check)

## Usage Examples

### Example 1: Loading a Text File

```powershell
# Find the text file
$textPath = Get-ResourcePath "config.txt"

if ($textPath) {
    # Load the content
    $content = Get-Content -Path $textPath -Raw
    Write-Host "Configuration loaded:"
    Write-Host $content
} else {
    Write-Error "config.txt not found!"
}
```

### Example 2: Loading a JSON Configuration

```powershell
# Find the JSON config
$configPath = Get-ResourcePath "settings.json"

if ($configPath) {
    # Parse JSON
    $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

    # Access properties
    Write-Host "Server: $($config.server)"
    Write-Host "Port: $($config.port)"
} else {
    Write-Error "settings.json not found!"
}
```

### Example 3: Loading an Image (WPF)

```powershell
Add-Type -AssemblyName PresentationFramework

# Find the image
$imagePath = Get-ResourcePath "logo.png"

if ($imagePath) {
    # Create BitmapImage
    $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
    $bitmap.BeginInit()
    $bitmap.UriSource = New-Object System.Uri($imagePath)
    $bitmap.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
    $bitmap.EndInit()

    # Use in WPF Image control
    $image = New-Object System.Windows.Controls.Image
    $image.Source = $bitmap
} else {
    Write-Error "logo.png not found!"
}
```

### Example 4: Installing a Certificate

```powershell
# Find the certificate
$certPath = Get-ResourcePath "certificate.pfx"

if ($certPath) {
    # Load certificate with password
    $password = ConvertTo-SecureString -String "your-password" -Force -AsPlainText
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(
        $certPath,
        $password,
        [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet
    )

    # Install to store
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store(
        "My",
        "CurrentUser"
    )
    $store.Open("ReadWrite")
    $store.Add($cert)
    $store.Close()

    Write-Host "Certificate installed: $($cert.Subject)"
} else {
    Write-Error "certificate.pfx not found!"
}
```

### Example 5: Loading XML Data

```powershell
# Find the XML file
$xmlPath = Get-ResourcePath "data.xml"

if ($xmlPath) {
    # Load as XML
    [xml]$xmlData = Get-Content -Path $xmlPath

    # Access nodes
    foreach ($item in $xmlData.root.items.item) {
        Write-Host "Item: $($item.name) - $($item.value)"
    }
} else {
    Write-Error "data.xml not found!"
}
```

### Example 6: Loading Binary Data

```powershell
# Find the binary file
$binaryPath = Get-ResourcePath "data.bin"

if ($binaryPath) {
    # Read as bytes
    $bytes = [System.IO.File]::ReadAllBytes($binaryPath)
    Write-Host "Loaded $($bytes.Length) bytes"

    # Process binary data
    # ... your binary processing code ...
} else {
    Write-Error "data.bin not found!"
}
```

### Example 7: Loading Multiple Resources

```powershell
# Define all required resources
$resources = @{
    Config = "config.json"
    Icon = "icon.ico"
    Logo = "logo.png"
    Data = "data.csv"
    Certificate = "cert.pfx"
}

# Load all resources
$loadedResources = @{}
$allFound = $true

foreach ($key in $resources.Keys) {
    $fileName = $resources[$key]
    $path = Get-ResourcePath $fileName

    if ($path) {
        $loadedResources[$key] = $path
        Write-Host "[OK] $fileName found"
    } else {
        Write-Warning "[MISSING] $fileName not found"
        $allFound = $false
    }
}

if ($allFound) {
    Write-Host "All resources loaded successfully!"
    # Proceed with your application logic
} else {
    Write-Error "Some resources are missing. Cannot continue."
    exit 1
}
```

## Best Practices

### 1. Always Check for Null

Never assume a file exists. Always check the return value:

```powershell
$path = Get-ResourcePath "myfile.txt"
if ($path) {
    # Safe to use $path
} else {
    # Handle missing file
}
```

### 2. Use Original Filenames

When adding files to Assets, use descriptive filenames:
- ✅ `app-config.json`, `company-logo.png`, `ssl-certificate.pfx`
- ❌ `file1.txt`, `temp.dat`, `x.bin`

### 3. Verify Resources at Startup

Check all required resources at the beginning of your script:

```powershell
# Check all required files at startup
$requiredFiles = @("config.json", "logo.png", "data.csv")
$missingFiles = @()

foreach ($file in $requiredFiles) {
    if (-not (Get-ResourcePath $file)) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Error "Missing required files: $($missingFiles -join ', ')"
    exit 1
}

Write-Host "All required resources verified!"
```

### 4. Add Logging for Debugging

Include detailed logging to troubleshoot resource issues:

```powershell
function Get-ResourcePath {
    param([string]$FileName)

    Write-Host "Searching for: $FileName" -ForegroundColor Cyan
    Write-Host "  PS_RESOURCE_DIR = $env:PS_RESOURCE_DIR"

    if ($env:PS_RESOURCE_DIR) {
        $path = Join-Path $env:PS_RESOURCE_DIR $FileName
        Write-Host "  Checking: $path"
        if (Test-Path $path) {
            Write-Host "  FOUND!" -ForegroundColor Green
            return $path
        }
    }

    Write-Host "  NOT FOUND" -ForegroundColor Red
    return $null
}
```

### 5. Clean Paths for Display

When showing paths to users, make them readable:

```powershell
$path = Get-ResourcePath "config.json"
if ($path) {
    # Show relative or shortened path to user
    $displayPath = Split-Path -Leaf $path
    Write-Host "Using configuration: $displayPath"
}
```

### 6. Handle File Locks Gracefully

When working with files that might be locked:

```powershell
$path = Get-ResourcePath "data.db"
if ($path) {
    try {
        $stream = [System.IO.File]::Open($path, 'Open', 'Read', 'ReadWrite')
        # Use the file
        $stream.Close()
    } catch {
        Write-Error "File is locked or inaccessible: $_"
    }
}
```

## Troubleshooting

### Problem: "File not found" when running exe

**Symptoms**: `Get-ResourcePath` returns `$null` when running from executable

**Solutions**:
1. Verify the file was added in the Assets tab before building
2. Check the filename matches exactly (case-sensitive on some systems)
3. Check file extension is correct (`.txt`, `.png`, not `.TXT`, `.PNG`)
4. Review build logs for embedding confirmation

**Debug**: Add this to your script to see what's available:

```powershell
Write-Host "PS_RESOURCE_DIR = $env:PS_RESOURCE_DIR"
if ($env:PS_RESOURCE_DIR -and (Test-Path $env:PS_RESOURCE_DIR)) {
    Write-Host "Files in resource directory:"
    Get-ChildItem -Path $env:PS_RESOURCE_DIR | ForEach-Object {
        Write-Host "  - $($_.Name) ($($_.Length) bytes)"
    }
}
```

### Problem: Files have wrong extensions (.dat instead of .txt)

**Cause**: Old version of PSEBuilder with file extension bug

**Solution**:
- Use the latest version of PSEBuilder-XAML-Fixed2.ps1
- The bug was fixed to preserve original file extensions
- Rebuild your executable with the fixed version

### Problem: Certificate won't install

**Symptoms**: Certificate file found but installation fails

**Solutions**:
1. Verify certificate password is correct
2. Check certificate format (.pfx for private key, .cer for public only)
3. Ensure running with appropriate permissions (admin for LocalMachine store)
4. Verify certificate isn't expired or corrupted

```powershell
$certPath = Get-ResourcePath "cert.pfx"
if ($certPath) {
    try {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(
            $certPath,
            $password
        )
        Write-Host "Certificate valid: $($cert.Subject)"
        Write-Host "Expires: $($cert.NotAfter)"
    } catch {
        Write-Error "Certificate error: $_"
    }
}
```

### Problem: Image won't load in WPF

**Symptoms**: Image file found but `BitmapImage` creation fails

**Solutions**:
1. Verify image format is supported (PNG, JPG, BMP, GIF)
2. Check image isn't corrupted
3. Use `CacheOption = OnLoad` to load immediately
4. Verify file exists before creating `BitmapImage`

```powershell
$imagePath = Get-ResourcePath "logo.png"
if ($imagePath -and (Test-Path $imagePath)) {
    try {
        $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
        $bitmap.BeginInit()
        $bitmap.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        $bitmap.UriSource = New-Object System.Uri($imagePath)
        $bitmap.EndInit()
        $bitmap.Freeze()  # Makes it thread-safe
    } catch {
        Write-Error "Failed to load image: $_"
    }
}
```

### Problem: Working in development but not in exe

**Cause**: Script relies on files in script directory instead of using `Get-ResourcePath`

**Solution**: Always use `Get-ResourcePath` for resource access, not hardcoded paths:

```powershell
# ❌ Wrong - hardcoded path
$config = Get-Content "./config.json"

# ✅ Right - uses Get-ResourcePath
$configPath = Get-ResourcePath "config.json"
if ($configPath) {
    $config = Get-Content $configPath
}
```

### Problem: Temp directory fills up

**Cause**: Each exe run creates a new temp directory with GUID

**Solution**: The OS typically cleans temp directories automatically. For manual cleanup:

```powershell
# At script end, optionally clean up
if ($env:PS_RESOURCE_DIR -and (Test-Path $env:PS_RESOURCE_DIR)) {
    try {
        Remove-Item -Path $env:PS_RESOURCE_DIR -Recurse -Force
        Write-Host "Cleaned up temporary resources"
    } catch {
        # Ignore cleanup errors
    }
}
```

## Environment Variables Reference

### PS_RESOURCE_DIR

- **Set by**: The C# executable wrapper
- **Value**: Full path to temporary extraction directory
- **Example**: `C:\Users\YourName\AppData\Local\Temp\PSExecutor_a1b2c3d4\`
- **Lifetime**: Process lifetime (cleared when script exits)
- **Usage**: Primary method for finding embedded resources

### Checking Environment Variables

```powershell
# Display all relevant environment variables
Write-Host "Environment Information:"
Write-Host "  PS_RESOURCE_DIR = $env:PS_RESOURCE_DIR"
Write-Host "  TEMP = $env:TEMP"
Write-Host "  TMP = $env:TMP"
Write-Host "  PSScriptRoot = $PSScriptRoot"
Write-Host "  Working Directory = $(Get-Location)"
```

## Complete Working Example

See `examples/test-gui-app.ps1` for a complete, production-ready implementation that includes:
- Comprehensive `Get-ResourcePath` function with logging
- Resource verification at startup
- File listing for debugging
- Error handling and user feedback
- WPF GUI with image and text loading
- Detailed logging to Downloads folder

This example demonstrates all best practices and is ready to use as a template for your own applications.

## Additional Resources

- **USAGE-GUIDE.md** - Complete guide to using PSEBuilder
- **PROJECT-SUMMARY.md** - Technical architecture overview
- **README.md** - Project introduction and quick start
- **examples/** - Working examples and sample files

---

**Need Help?**

If you encounter issues not covered in this guide, check the build logs saved to your Downloads folder:
- `PSEBuilder-Debug-YYYYMMDD-HHMMSS.log` (build process log)
- `TestGUI-Runtime-YYYYMMDD-HHMMSS.log` (runtime execution log)