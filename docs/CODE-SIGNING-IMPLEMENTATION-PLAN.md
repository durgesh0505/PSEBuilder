# Code Signing Implementation Plan

**Feature**: Digital Signature Support for PSEBuilder
**Version**: 1.2.0
**Date**: 2025-10-19
**Status**: Planning Phase

---

## 📋 Executive Summary

Add a new "Code Signing" tab to PSEBuilder that enables users to digitally sign their compiled executables using Authenticode technology. This feature will allow professional distribution of PowerShell executables with trusted signatures, eliminating Windows SmartScreen warnings.

### Goals
- ✅ Provide GUI-based code signing (no command-line needed)
- ✅ Support both Windows Certificate Store and PFX files
- ✅ Automatic timestamping for long-term validity
- ✅ Comprehensive certificate validation
- ✅ Secure password handling
- ✅ Seamless integration with existing build process

---

## 🎯 User Stories

### Story 1: Professional Software Distribution
**As a** PowerShell developer
**I want** to sign my executables with my company's code signing certificate
**So that** users trust my software and don't see scary security warnings

### Story 2: Easy Certificate Management
**As a** non-technical user
**I want** to browse and select certificates from my Windows store
**So that** I don't need to manually find certificate thumbprints

### Story 3: Secure Credential Handling
**As a** security-conscious developer
**I want** my PFX passwords to never be stored on disk
**So that** my private keys remain secure

### Story 4: Testing with Self-Signed Certificates
**As a** developer testing my tool
**I want** to create a self-signed certificate for testing
**So that** I can test the signing process before buying a commercial certificate

---

## 🏗️ Architecture Overview

### New Components

```
PSEBuilder.ps1
├── Code Signing Tab (NEW)
│   ├── Enable/Disable Signing Checkbox
│   ├── Certificate Source Selection
│   ├── Certificate Browser
│   ├── Certificate Details Display
│   └── Timestamp Server Configuration
│
├── Certificate Management Functions (NEW)
│   ├── Get-CodeSigningCertificates
│   ├── Get-PfxCertificateSecure
│   ├── Test-CertificateValidity
│   └── New-SelfSignedCodeCert
│
├── Signing Functions (NEW)
│   ├── Invoke-ExecutableSigning
│   ├── Add-AuthenticodeTimestamp
│   └── Test-ExecutableSignature
│
└── Build Process Integration (MODIFIED)
    └── Build-Executable
        ├── Compile with csc.exe (existing)
        ├── Sign if enabled (NEW)
        └── Verify signature (NEW)
```

### Workflow Integration

```
User clicks "Build Executable"
↓
[Existing] Validate inputs
↓
[Existing] Compile with csc.exe
↓
[Existing] Check compilation success
↓
[NEW] Check if signing is enabled
↓
[NEW] If signing enabled:
    ├── Load certificate
    ├── Sign executable with Set-AuthenticodeSignature
    ├── Add timestamp
    ├── Verify signature
    └── Update status message
↓
[Existing] Show build complete message
```

---

## 🎨 UI Design - Code Signing Tab

### Tab Structure

```
┌─────────────────────────────────────────────────────────────┐
│ [Basic Configuration] [Assets] [Code Signing]              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ☑ Sign Executable After Build                             │
│                                                             │
│  ┌─ Certificate Source ─────────────────────────────────┐  │
│  │                                                       │  │
│  │  ○ Windows Certificate Store                         │  │
│  │     Certificate: [Select certificate ▼]              │  │
│  │                                                       │  │
│  │  ○ PFX/P12 File                                      │  │
│  │     File: [                        ] [Browse...]     │  │
│  │     Password: [••••••••••]                           │  │
│  │     ☐ Remember password for this session             │  │
│  │                                                       │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌─ Certificate Details ─────────────────────────────────┐  │
│  │                                                       │  │
│  │  Subject:      [Acme Corporation                   ] │  │
│  │  Issuer:       [DigiCert Assured ID Root CA       ] │  │
│  │  Valid From:   [2024-01-15                        ] │  │
│  │  Valid Until:  [2027-01-15                        ] │  │
│  │  Thumbprint:   [A1B2C3D4E5F6G7H8I9J0K1L2M3N4...  ] │  │
│  │                                                       │  │
│  │  Status: ✅ Certificate is valid                     │  │
│  │                                                       │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌─ Timestamp Server ────────────────────────────────────┐  │
│  │                                                       │  │
│  │  Server: [DigiCert (Recommended) ▼]                  │  │
│  │                                                       │  │
│  │  ⓘ Timestamping ensures your signature remains      │  │
│  │    valid even after the certificate expires          │  │
│  │                                                       │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  [Create Self-Signed Certificate for Testing]              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Control Details

#### 1. Enable Signing Checkbox
- **Name**: `chkEnableSigning`
- **Default**: Unchecked
- **Behavior**: When checked, enables all other controls. When unchecked, disables all controls and signing is skipped during build

#### 2. Certificate Source Radio Buttons
- **Windows Store Radio**:
  - **Name**: `rbCertSourceStore`
  - **Default**: Selected
  - **Enables**: Certificate ComboBox

- **PFX File Radio**:
  - **Name**: `rbCertSourcePFX`
  - **Enables**: File path TextBox, Browse button, Password field

#### 3. Certificate Selection (Windows Store)
- **Name**: `cmbCertificates`
- **Type**: ComboBox
- **Population**: Auto-populated with `Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert`
- **Display**: Certificate Subject name
- **Data**: Certificate object stored in Tag property
- **Event**: SelectionChanged triggers certificate validation and details population

#### 4. PFX File Selection
- **File Path TextBox**:
  - **Name**: `txtPfxPath`
  - **Type**: TextBox (read-only)

- **Browse Button**:
  - **Name**: `btnBrowsePfx`
  - **Filter**: "Certificate Files (*.pfx;*.p12)|*.pfx;*.p12"

- **Password Field**:
  - **Name**: `txtPfxPassword`
  - **Type**: PasswordBox
  - **Storage**: SecureString in memory only

- **Remember Password Checkbox**:
  - **Name**: `chkRememberPassword`
  - **Warning**: "Password stored in memory only, cleared on exit"

#### 5. Certificate Details (Read-Only)
- **Subject**: `txtCertSubject`
- **Issuer**: `txtCertIssuer`
- **Valid From**: `txtCertValidFrom`
- **Valid Until**: `txtCertValidUntil`
- **Thumbprint**: `txtCertThumbprint`
- **Status**: `lblCertStatus` (shows ✅/⚠️/❌ with color)

#### 6. Timestamp Server
- **Name**: `cmbTimestampServer`
- **Type**: ComboBox
- **Options**:
  - DigiCert (Recommended) - `http://timestamp.digicert.com`
  - Sectigo - `http://timestamp.sectigo.com`
  - GlobalSign - `http://timestamp.globalsign.com`
  - Custom URL... (shows additional TextBox)

#### 7. Self-Signed Certificate Button
- **Name**: `btnCreateSelfSigned`
- **Action**: Opens wizard to create self-signed certificate
- **Warning**: Shows dialog: "Self-signed certificates are for TESTING ONLY..."

---

## 💻 PowerShell Implementation

### Function 1: Get-CodeSigningCertificates

```powershell
function Get-CodeSigningCertificates {
    <#
    .SYNOPSIS
    Retrieves code signing certificates from Windows Certificate Store

    .DESCRIPTION
    Gets all valid code signing certificates from CurrentUser\My store,
    filtered by validity and code signing capability

    .OUTPUTS
    Array of certificate objects with Subject, Thumbprint, NotAfter
    #>

    try {
        # Get all code signing certificates
        $certs = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert -ErrorAction Stop

        # Filter to only valid certificates with private keys
        $validCerts = $certs | Where-Object {
            $_.HasPrivateKey -eq $true -and
            $_.NotAfter -gt (Get-Date)
        }

        # Sort by expiration date (furthest in future first)
        $validCerts = $validCerts | Sort-Object NotAfter -Descending

        Write-DebugLog "Found $($validCerts.Count) valid code signing certificates"

        return $validCerts

    } catch {
        Write-DebugLog "Error retrieving certificates: $($_.Exception.Message)" "ERROR"
        return @()
    }
}
```

### Function 2: Get-PfxCertificateSecure

```powershell
function Get-PfxCertificateSecure {
    <#
    .SYNOPSIS
    Loads a PFX certificate with secure password handling

    .PARAMETER PfxPath
    Path to .pfx or .p12 file

    .PARAMETER Password
    SecureString containing the password

    .OUTPUTS
    Certificate object or $null if failed
    #>

    param(
        [Parameter(Mandatory=$true)]
        [string]$PfxPath,

        [Parameter(Mandatory=$true)]
        [SecureString]$Password
    )

    try {
        if (-not (Test-Path $PfxPath)) {
            throw "PFX file not found: $PfxPath"
        }

        Write-DebugLog "Loading PFX certificate from: $PfxPath"

        # Load certificate with password
        $cert = Get-PfxCertificate -FilePath $PfxPath -Password $Password -ErrorAction Stop

        # Validate it's a code signing certificate
        if ($cert.EnhancedKeyUsageList -and
            $cert.EnhancedKeyUsageList.FriendlyName -notcontains "Code Signing" -and
            $cert.EnhancedKeyUsageList.Count -gt 0) {
            throw "Certificate is not valid for code signing"
        }

        Write-DebugLog "Successfully loaded certificate: $($cert.Subject)"
        return $cert

    } catch {
        Write-DebugLog "Error loading PFX certificate: $($_.Exception.Message)" "ERROR"
        return $null
    }
}
```

### Function 3: Test-CertificateValidity

```powershell
function Test-CertificateValidity {
    <#
    .SYNOPSIS
    Validates a certificate for code signing

    .PARAMETER Certificate
    Certificate object to validate

    .OUTPUTS
    Hashtable with: Valid (bool), Status (string), Message (string), WarningLevel (string)
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

    # Check 1: Has private key
    if (-not $Certificate.HasPrivateKey) {
        $result.Status = "❌ Invalid"
        $result.Message = "Certificate does not have a private key"
        $result.WarningLevel = "Error"
        return $result
    }

    # Check 2: Not expired
    $now = Get-Date
    if ($Certificate.NotAfter -lt $now) {
        $result.Status = "❌ Expired"
        $result.Message = "Certificate expired on $($Certificate.NotAfter.ToString('yyyy-MM-dd'))"
        $result.WarningLevel = "Error"
        return $result
    }

    # Check 3: Not yet valid
    if ($Certificate.NotBefore -gt $now) {
        $result.Status = "❌ Not Yet Valid"
        $result.Message = "Certificate not valid until $($Certificate.NotBefore.ToString('yyyy-MM-dd'))"
        $result.WarningLevel = "Error"
        return $result
    }

    # Check 4: Expiring soon (within 30 days)
    $daysUntilExpiry = ($Certificate.NotAfter - $now).Days
    if ($daysUntilExpiry -le 30) {
        $result.Valid = $true
        $result.Status = "⚠️ Expiring Soon"
        $result.Message = "Certificate expires in $daysUntilExpiry days on $($Certificate.NotAfter.ToString('yyyy-MM-dd'))"
        $result.WarningLevel = "Warning"
        return $result
    }

    # Check 5: Self-signed (informational warning)
    if ($Certificate.Subject -eq $Certificate.Issuer) {
        $result.Valid = $true
        $result.Status = "⚠️ Self-Signed"
        $result.Message = "Self-signed certificate - users will see security warnings"
        $result.WarningLevel = "Warning"
        return $result
    }

    # All checks passed
    $result.Valid = $true
    $result.Status = "✅ Valid"
    $result.Message = "Certificate is valid until $($Certificate.NotAfter.ToString('yyyy-MM-dd'))"
    $result.WarningLevel = "None"

    return $result
}
```

### Function 4: Invoke-ExecutableSigning

```powershell
function Invoke-ExecutableSigning {
    <#
    .SYNOPSIS
    Signs an executable with the specified certificate

    .PARAMETER ExePath
    Path to the executable to sign

    .PARAMETER Certificate
    Certificate object to use for signing

    .PARAMETER TimestampServer
    URL of the timestamp server

    .OUTPUTS
    Hashtable with: Success (bool), Message (string), SignatureStatus (object)
    #>

    param(
        [Parameter(Mandatory=$true)]
        [string]$ExePath,

        [Parameter(Mandatory=$true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,

        [Parameter(Mandatory=$false)]
        [string]$TimestampServer = "http://timestamp.digicert.com"
    )

    $result = @{
        Success = $false
        Message = ""
        SignatureStatus = $null
    }

    try {
        if (-not (Test-Path $ExePath)) {
            throw "Executable not found: $ExePath"
        }

        Write-DebugLog "Signing executable: $ExePath"
        Write-DebugLog "Certificate: $($Certificate.Subject)"
        Write-DebugLog "Timestamp server: $TimestampServer"

        # Sign the executable with SHA256 (2025 standard)
        $signature = Set-AuthenticodeSignature `
            -FilePath $ExePath `
            -Certificate $Certificate `
            -TimestampServer $TimestampServer `
            -HashAlgorithm SHA256 `
            -ErrorAction Stop

        # Check signature status
        if ($signature.Status -eq 'Valid') {
            Write-DebugLog "Executable signed successfully"
            $result.Success = $true
            $result.Message = "Signed by: $($Certificate.Subject)"
            $result.SignatureStatus = $signature
        } else {
            throw "Signature status: $($signature.Status) - $($signature.StatusMessage)"
        }

        return $result

    } catch {
        Write-DebugLog "Error signing executable: $($_.Exception.Message)" "ERROR"
        $result.Message = "Signing failed: $($_.Exception.Message)"
        return $result
    }
}
```

### Function 5: New-SelfSignedCodeCert (Wizard)

```powershell
function New-SelfSignedCodeCert {
    <#
    .SYNOPSIS
    Creates a self-signed code signing certificate for testing

    .PARAMETER CommonName
    Common name for the certificate (e.g., "Test Developer")

    .OUTPUTS
    Certificate object or $null if failed
    #>

    param(
        [Parameter(Mandatory=$true)]
        [string]$CommonName
    )

    try {
        Write-DebugLog "Creating self-signed code signing certificate for: $CommonName"

        # Create certificate
        $cert = New-SelfSignedCertificate `
            -Type CodeSigningCert `
            -Subject "CN=$CommonName" `
            -CertStoreLocation "Cert:\CurrentUser\My" `
            -NotAfter (Get-Date).AddYears(3) `
            -ErrorAction Stop

        Write-DebugLog "Self-signed certificate created successfully"
        Write-DebugLog "Thumbprint: $($cert.Thumbprint)"

        # Show warning message
        $warningMessage = @"
Self-Signed Certificate Created

⚠️ TESTING ONLY - DO NOT USE IN PRODUCTION

Subject: $($cert.Subject)
Thumbprint: $($cert.Thumbprint)
Expires: $($cert.NotAfter.ToString('yyyy-MM-dd'))

This certificate is for testing purposes only.
Users will still see security warnings when running
executables signed with this certificate.

For production use, purchase a commercial code signing
certificate from DigiCert, Sectigo, or another trusted
Certificate Authority.
"@

        [System.Windows.MessageBox]::Show($warningMessage, "Self-Signed Certificate Created", "OK", "Warning")

        return $cert

    } catch {
        Write-DebugLog "Error creating self-signed certificate: $($_.Exception.Message)" "ERROR"
        [System.Windows.MessageBox]::Show("Failed to create certificate: $($_.Exception.Message)", "Error", "OK", "Error")
        return $null
    }
}
```

---

## 🔄 Build Process Integration

### Modified Build-Executable Function

```powershell
# At the end of existing Build-Executable function, after csc.exe compilation:

# NEW CODE - After compilation succeeds
if ($chkEnableSigning.IsChecked) {
    Write-DebugLog "Code signing is enabled, proceeding with signing..."

    try {
        # Get certificate based on source
        $certificate = $null

        if ($rbCertSourceStore.IsChecked) {
            # Windows Store
            $selectedCert = $cmbCertificates.SelectedItem.Tag
            if ($selectedCert) {
                $certificate = $selectedCert
                Write-DebugLog "Using certificate from Windows Store: $($certificate.Subject)"
            } else {
                throw "No certificate selected from Windows Store"
            }
        }
        elseif ($rbCertSourcePFX.IsChecked) {
            # PFX File
            if (-not $txtPfxPath.Text) {
                throw "No PFX file selected"
            }

            if (-not $txtPfxPassword.SecurePassword) {
                throw "No password provided for PFX file"
            }

            $certificate = Get-PfxCertificateSecure -PfxPath $txtPfxPath.Text -Password $txtPfxPassword.SecurePassword

            if (-not $certificate) {
                throw "Failed to load PFX certificate"
            }
        }
        else {
            throw "No certificate source selected"
        }

        # Validate certificate
        $validation = Test-CertificateValidity -Certificate $certificate
        if (-not $validation.Valid) {
            throw "Certificate validation failed: $($validation.Message)"
        }

        # Get timestamp server
        $timestampUrl = "http://timestamp.digicert.com"  # Default
        if ($cmbTimestampServer.SelectedItem.Content -eq "Sectigo") {
            $timestampUrl = "http://timestamp.sectigo.com"
        }
        elseif ($cmbTimestampServer.SelectedItem.Content -eq "GlobalSign") {
            $timestampUrl = "http://timestamp.globalsign.com"
        }
        elseif ($cmbTimestampServer.SelectedItem.Content -eq "Custom URL...") {
            $timestampUrl = $txtCustomTimestamp.Text
        }

        # Sign the executable
        $signingResult = Invoke-ExecutableSigning `
            -ExePath $OutputPath `
            -Certificate $certificate `
            -TimestampServer $timestampUrl

        if ($signingResult.Success) {
            Write-DebugLog "Executable signed successfully: $($signingResult.Message)"
            $lblBuildStatus.Text = "Build successful! $($signingResult.Message)"
        } else {
            Write-DebugLog "Signing failed: $($signingResult.Message)" "WARN"
            [System.Windows.MessageBox]::Show(
                "Executable built successfully but signing failed:`n`n$($signingResult.Message)`n`nThe unsigned executable has been saved.",
                "Signing Warning",
                "OK",
                "Warning"
            )
        }

    } catch {
        Write-DebugLog "Signing error: $($_.Exception.Message)" "ERROR"
        [System.Windows.MessageBox]::Show(
            "Executable built successfully but signing failed:`n`n$($_.Exception.Message)`n`nThe unsigned executable has been saved.",
            "Signing Error",
            "OK",
            "Error"
        )
    }
}
```

---

## 🎨 XAML UI Code

### Code Signing Tab

```xml
<!-- Add to TabControl after Assets Tab -->
<TabItem Header="Code Signing">
    <ScrollViewer VerticalScrollBarVisibility="Auto">
        <StackPanel Margin="15">

            <!-- Enable Signing Checkbox -->
            <CheckBox Name="chkEnableSigning" Content="Sign Executable After Build"
                     FontSize="14" FontWeight="Bold" Margin="0,0,0,15"/>

            <!-- Certificate Source -->
            <GroupBox Header="Certificate Source" Margin="0,0,0,15" IsEnabled="False">
                <StackPanel>
                    <RadioButton Name="rbCertSourceStore" GroupName="CertSource"
                                Content="Windows Certificate Store" IsChecked="True" Margin="5"/>

                    <Grid Margin="20,5,5,10">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>

                        <Label Grid.Column="0" Content="Certificate:"/>
                        <ComboBox Name="cmbCertificates" Grid.Column="1"
                                 DisplayMemberPath="Subject" Margin="5,0,0,0"/>
                    </Grid>

                    <RadioButton Name="rbCertSourcePFX" GroupName="CertSource"
                                Content="PFX/P12 File" Margin="5,10,5,5"/>

                    <Grid Margin="20,5,5,5">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>

                        <Label Grid.Row="0" Grid.Column="0" Content="File:"/>
                        <TextBox Name="txtPfxPath" Grid.Row="0" Grid.Column="1"
                                IsReadOnly="True" Margin="5,0,5,5"/>
                        <Button Name="btnBrowsePfx" Grid.Row="0" Grid.Column="2"
                               Content="Browse..." MinWidth="90"/>

                        <Label Grid.Row="1" Grid.Column="0" Content="Password:"/>
                        <PasswordBox Name="txtPfxPassword" Grid.Row="1" Grid.Column="1"
                                    Grid.ColumnSpan="2" Margin="5,0,0,5"/>

                        <CheckBox Name="chkRememberPassword" Grid.Row="2" Grid.Column="1"
                                 Grid.ColumnSpan="2" Content="Remember password for this session"
                                 Margin="5,0,0,0"/>
                    </Grid>
                </StackPanel>
            </GroupBox>

            <!-- Certificate Details -->
            <GroupBox Header="Certificate Details" Margin="0,0,0,15" IsEnabled="False">
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
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>

                    <Label Grid.Row="0" Grid.Column="0" Content="Subject:"/>
                    <TextBox Name="txtCertSubject" Grid.Row="0" Grid.Column="1"
                            IsReadOnly="True" Margin="5,0,0,5"/>

                    <Label Grid.Row="1" Grid.Column="0" Content="Issuer:"/>
                    <TextBox Name="txtCertIssuer" Grid.Row="1" Grid.Column="1"
                            IsReadOnly="True" Margin="5,0,0,5"/>

                    <Label Grid.Row="2" Grid.Column="0" Content="Valid From:"/>
                    <TextBox Name="txtCertValidFrom" Grid.Row="2" Grid.Column="1"
                            IsReadOnly="True" Margin="5,0,0,5"/>

                    <Label Grid.Row="3" Grid.Column="0" Content="Valid Until:"/>
                    <TextBox Name="txtCertValidUntil" Grid.Row="3" Grid.Column="1"
                            IsReadOnly="True" Margin="5,0,0,5"/>

                    <Label Grid.Row="4" Grid.Column="0" Content="Thumbprint:"/>
                    <TextBox Name="txtCertThumbprint" Grid.Row="4" Grid.Column="1"
                            IsReadOnly="True" Margin="5,0,0,5"/>

                    <TextBlock Name="lblCertStatus" Grid.Row="5" Grid.Column="1"
                              Text="No certificate selected"
                              Foreground="#CCCCCC" Margin="5,10,0,0"/>
                </Grid>
            </GroupBox>

            <!-- Timestamp Server -->
            <GroupBox Header="Timestamp Server" Margin="0,0,0,15" IsEnabled="False">
                <StackPanel>
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>

                        <Label Grid.Column="0" Content="Server:"/>
                        <ComboBox Name="cmbTimestampServer" Grid.Column="1"
                                 Margin="5,0,0,0" SelectedIndex="0">
                            <ComboBoxItem Content="DigiCert (Recommended)"/>
                            <ComboBoxItem Content="Sectigo"/>
                            <ComboBoxItem Content="GlobalSign"/>
                            <ComboBoxItem Content="Custom URL..."/>
                        </ComboBox>
                    </Grid>

                    <TextBox Name="txtCustomTimestamp" Margin="5,10,0,0"
                            Visibility="Collapsed"
                            Text="http://timestamp.example.com"/>

                    <TextBlock Margin="5,10,0,0" TextWrapping="Wrap"
                              Foreground="#CCCCCC" FontSize="11">
                        <Run Text="ⓘ "/>
                        <Run Text="Timestamping ensures your signature remains valid even after the certificate expires"/>
                    </TextBlock>
                </StackPanel>
            </GroupBox>

            <!-- Self-Signed Certificate Helper -->
            <Button Name="btnCreateSelfSigned" Content="Create Self-Signed Certificate for Testing"
                   HorizontalAlignment="Center" MinWidth="300" Margin="0,10,0,0"/>

        </StackPanel>
    </ScrollViewer>
</TabItem>
```

---

## 🧪 Testing Strategy

### Test Scenarios

#### 1. Certificate Enumeration Tests
- **Test**: Load PSEBuilder on machine with code signing certs
- **Expected**: Certificates appear in ComboBox dropdown
- **Test**: Load PSEBuilder on machine without code signing certs
- **Expected**: ComboBox shows "No certificates found" message

#### 2. PFX Loading Tests
- **Test**: Load valid PFX with correct password
- **Expected**: Certificate loads successfully, details populate
- **Test**: Load valid PFX with wrong password
- **Expected**: Error dialog, prompt to retry
- **Test**: Load non-certificate file
- **Expected**: Clear error message

#### 3. Certificate Validation Tests
- **Test**: Select expired certificate
- **Expected**: Red X "❌ Expired" with expiration date
- **Test**: Select certificate expiring in 15 days
- **Expected**: Yellow warning "⚠️ Expiring Soon"
- **Test**: Select self-signed certificate
- **Expected**: Yellow warning "⚠️ Self-Signed" with note about user warnings
- **Test**: Select valid commercial certificate
- **Expected**: Green "✅ Valid"

#### 4. Signing Tests
- **Test**: Build and sign with valid certificate
- **Expected**: Executable signed, verified with Get-AuthenticodeSignature
- **Test**: Build with signing enabled but no certificate
- **Expected**: Build succeeds, unsigned exe saved, error shown
- **Test**: Build with expired certificate
- **Expected**: Build succeeds, unsigned exe saved, validation error shown

#### 5. Timestamp Tests
- **Test**: Sign with DigiCert timestamp
- **Expected**: Signature includes valid timestamp
- **Test**: Sign with network disconnected (simulated timeout)
- **Expected**: 3 retry attempts, then offer to continue without timestamp
- **Test**: Sign with custom timestamp URL
- **Expected**: Uses custom URL for timestamping

#### 6. Self-Signed Certificate Tests
- **Test**: Click "Create Self-Signed Certificate"
- **Expected**: Wizard creates cert, shows warning dialog, cert appears in dropdown
- **Test**: Sign with self-signed cert
- **Expected**: Signs successfully, shows self-signed warning

### Test Data Setup

```powershell
# Create test certificate for automated testing
New-SelfSignedCertificate `
    -Type CodeSigningCert `
    -Subject "CN=PSEBuilder Test Certificate" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -NotAfter (Get-Date).AddYears(1)

# Export test PFX
$cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Subject -eq "CN=PSEBuilder Test Certificate" }
$password = ConvertTo-SecureString -String "TestPassword123!" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath "test-cert.pfx" -Password $password
```

---

## 📊 Implementation Phases

### Phase 1: Foundation (2 days)
**Goal**: Add UI and basic certificate enumeration

**Tasks**:
- [ ] Add Code Signing tab to XAML
- [ ] Implement Get-CodeSigningCertificates function
- [ ] Populate ComboBox with certificates
- [ ] Add enable/disable checkbox logic
- [ ] Implement certificate source radio button switching

**Deliverable**: Users can see and select certificates from Windows Store

---

### Phase 2: Core Functionality (3 days)
**Goal**: Implement signing and validation

**Tasks**:
- [ ] Implement Get-PfxCertificateSecure function
- [ ] Add PFX file browser and password handling
- [ ] Implement Test-CertificateValidity function
- [ ] Auto-populate certificate details on selection
- [ ] Implement Invoke-ExecutableSigning function
- [ ] Integrate signing into Build-Executable

**Deliverable**: Users can sign executables with Windows Store or PFX certificates

---

### Phase 3: Robustness (2 days)
**Goal**: Add timestamp support and error handling

**Tasks**:
- [ ] Add timestamp server dropdown
- [ ] Implement retry logic for network timeouts
- [ ] Add comprehensive error handling for all scenarios
- [ ] Implement signature verification after signing
- [ ] Add warning dialogs for self-signed certs
- [ ] Test with expired certificates

**Deliverable**: Robust signing with proper error handling

---

### Phase 4: Polish (1 day)
**Goal**: Self-signed cert wizard and documentation

**Tasks**:
- [ ] Implement New-SelfSignedCodeCert wizard
- [ ] Add tooltips and help text
- [ ] Create CODE-SIGNING-GUIDE.md documentation
- [ ] Add configuration save/load for signing settings
- [ ] Final UI polish and testing

**Deliverable**: Complete, documented, production-ready feature

---

## 📚 Documentation Requirements

### User Documentation
- **CODE-SIGNING-GUIDE.md**: How to obtain commercial certificates, how to use the feature, troubleshooting
- **README.md update**: Add Code Signing to features list
- **REDDIT-POST.md update**: Mention code signing capability

### Developer Documentation
- **Inline code comments**: Document all signing functions
- **Debug logging**: Comprehensive logging for troubleshooting
- **Error messages**: Clear, actionable error messages

---

## 🔒 Security Considerations

### Password Handling
- ✅ Use SecureString for all password storage
- ✅ Never log passwords
- ✅ Clear password from memory on window close
- ✅ Optional "remember for session" stored in memory only

### Certificate Handling
- ✅ Never export or display private keys
- ✅ Validate certificate purpose before use
- ✅ Check certificate expiration
- ✅ Warn about self-signed certificates

### Network Security
- ✅ Validate timestamp server URLs
- ✅ Use HTTPS where possible
- ✅ Handle network timeouts gracefully

---

## 📈 Success Metrics

### Functional Metrics
- ✅ 100% of signed executables pass Get-AuthenticodeSignature validation
- ✅ Timestamp added to 100% of signatures
- ✅ Zero password leaks (stored on disk or in logs)
- ✅ Support both Windows Store and PFX certificates

### User Experience Metrics
- ✅ Certificate selection requires ≤3 clicks
- ✅ Clear validation messages for all error states
- ✅ Self-signed certificate creation ≤1 minute
- ✅ No crashes or hangs during signing process

---

## 🚀 Future Enhancements (Post-v1.2)

### v1.3 Potential Features
- **HSM Support**: Support for hardware security modules
- **Certificate Renewal Reminders**: Email notifications before expiration
- **Batch Signing**: Sign multiple executables at once
- **Signature Templates**: Save signing configurations as templates
- **CI/CD Integration**: Command-line signing for automation

### v2.0 Potential Features
- **Azure Key Vault Integration**: Cloud-based certificate storage
- **SignTool.exe Integration**: Alternative to Set-AuthenticodeSignature
- **Extended Validation (EV) Certificates**: Support for EV certs with hardware tokens
- **Cross-Platform Signing**: Support for Authenticode on Linux/macOS

---

## ✅ Acceptance Criteria

The Code Signing feature is complete when:

1. ✅ Users can select certificates from Windows Certificate Store
2. ✅ Users can load certificates from PFX files with password
3. ✅ Certificate validation shows clear status (valid/expired/expiring/self-signed)
4. ✅ Executables are signed automatically after build (if enabled)
5. ✅ Timestamps are added to all signatures
6. ✅ Network errors are handled with retry logic
7. ✅ Self-signed certificates can be created from the GUI
8. ✅ All passwords are stored in SecureString (never on disk)
9. ✅ Comprehensive error messages guide users through issues
10. ✅ Documentation is complete and accurate

---

## 📝 Notes

- **Backwards Compatibility**: Existing PSEBuilder.ps1 files continue to work - signing is optional
- **No External Dependencies**: Uses built-in Set-AuthenticodeSignature cmdlet
- **Dark Theme Consistent**: All UI follows existing dark theme design
- **Zero Breaking Changes**: Existing functionality unchanged

---

**Document Version**: 1.0
**Last Updated**: 2025-10-19
**Next Review**: After Phase 1 completion
