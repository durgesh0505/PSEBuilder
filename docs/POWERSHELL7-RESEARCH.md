# PowerShell 7+ Support Research Report

**Research Date**: 2025-10-18
**Project**: PSEBuilder - PowerShell Executable Builder
**Objective**: Investigate implementation requirements for PowerShell 7+ (Core) support

---

## Executive Summary

This research document analyzes the feasibility and implementation strategies for adding PowerShell 7+ support to PSEBuilder. Two primary approaches have been identified:

1. **Hybrid Approach (Recommended)**: Maintain current .NET Framework architecture but add pwsh.exe launch capability
2. **Full Rewrite**: Complete migration to .NET Core compilation with dotnet CLI

**Recommendation**: Implement Hybrid Approach for v1.1, plan Full Rewrite for v2.0

---

## 1. Current Architecture Analysis

### PSEBuilder Current Implementation

**Compilation Process**:
- Uses .NET Framework 4.0+ compiler (csc.exe)
- Location: `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe`
- Direct invocation without Add-Type (prevents file locking)
- Generates .NET Framework 4.x binaries (~500KB)

**Runtime Architecture**:
```
PSEBuilder.exe (WPF GUI)
  ↓
csc.exe (compile C# wrapper)
  ↓
GeneratedWrapper.exe (.NET Framework 4.x)
  ↓
powershell.exe (Windows PowerShell 5.1)
  ↓
User's PowerShell Script
```

**Key Limitations for PS7+**:
- Hardcoded to launch `powershell.exe` instead of `pwsh.exe`
- Compiled for .NET Framework, not .NET Core
- No script version detection or #Requires parsing
- Windows PowerShell 5.1 only

---

## 2. PowerShell 7+ vs 5.1 Differences

### Runtime Foundation

| Aspect | Windows PowerShell 5.1 | PowerShell 7+ |
|--------|------------------------|---------------|
| .NET Runtime | .NET Framework 4.5+ | .NET Core 2.0+ / .NET 6+ |
| Platform Support | Windows only | Windows, Linux, macOS |
| Executable Name | `powershell.exe` | `pwsh.exe` |
| Installation | Built into Windows | Separate installation |
| Default Location | `C:\Windows\System32\WindowsPowerShell\v1.0\` | `C:\Program Files\PowerShell\7\` |

### Performance & Compatibility

**Performance**:
- PowerShell 7 can be **57x faster** in some operations
- Improved performance with large data collections
- Better memory management

**Module Compatibility**:
- .NET Standard 2.0 allows loading many PS 5.1 modules
- Windows PowerShell Compatibility feature for full framework modules
- Some cmdlets missing (Windows Workflow, WMI v1)

**Side-by-Side Installation**:
- PS 7 and PS 5.1 can coexist on same system
- Different installation paths and executables
- No conflicts between versions

---

## 3. .NET Core Compilation Requirements

### Key Differences from .NET Framework

**csc.exe Availability**:
- ❌ .NET Framework: `csc.exe` directly available in Windows
- ❌ .NET Core/.NET 6+: No standalone `csc.exe`
- ✅ .NET Core: `csc.dll` invoked via `dotnet` CLI

**Compilation Methods**:

1. **dotnet CLI with project file**:
   ```powershell
   # Requires .csproj file
   dotnet build MyProject.csproj
   dotnet publish -c Release -r win-x64 --self-contained
   ```

2. **Direct csc.dll invocation**:
   ```powershell
   # More complex, manual reference management
   dotnet exec "path\to\csc.dll" /target:exe /out:output.exe source.cs
   ```

**Dependencies Required**:
- .NET SDK (not just runtime) must be installed on build machine
- SDK size: 200-500MB depending on version
- Current PSEBuilder has ZERO dependencies (only uses Windows built-ins)

### Single-File Deployment Options

**.NET Core 3.0+ supports single-file executables**:

**Self-Contained Deployment**:
```powershell
dotnet publish -r win-x64 -p:PublishSingleFile=true -p:SelfContained=true
```
- ✅ Includes entire .NET runtime
- ✅ No .NET installation needed on target
- ❌ **HUGE file size**: 70-150MB per executable
- ❌ Current PSEBuilder generates ~500KB exes

**Framework-Dependent Deployment**:
```powershell
dotnet publish -r win-x64 -p:PublishSingleFile=true -p:SelfContained=false
```
- ✅ Smaller size: 1-5MB
- ❌ Requires .NET runtime on target machine
- ❌ Version mismatch potential issues

**Runtime Identifiers (RID)**:
- `win-x64`: Windows 64-bit
- `win-x86`: Windows 32-bit
- `linux-x64`: Linux
- `osx-x64`: macOS

---

## 4. WPF Support in PowerShell 7+

### Good News: WPF is Supported

**.NET Core 3.1+ Added WPF Support**:
- PowerShell 7.0+ (released 2020) restored WPF functionality
- PowerShell 7.5 (latest, Jan 2025) runs on .NET 9.0
- Full WPF functionality available in PS7

**PowerShell Studio 2025**:
- June 2025 update added WPF project templates for PS7
- XAML file support confirmed working

### Platform Limitations

**Important**: WPF is Windows-only even in .NET Core
- No cross-platform GUI support
- Linux/macOS cannot run WPF applications
- This is by design - no plans to make WPF cross-platform

**Implications for PSEBuilder**:
- ✅ PSEBuilder GUI can use WPF with PS7
- ✅ Generated executables with WPF scripts work in PS7
- ❌ Cross-platform GUI apps not possible with WPF
- ✅ This is acceptable - PSEBuilder is already Windows-only

---

## 5. PowerShell Version Detection

### #Requires Statement

PowerShell scripts can specify version requirements:

```powershell
#Requires -Version 7.0
#Requires -Modules Az
#Requires -PSSnapin ActiveDirectory
```

**Behavior**:
- Prevents script execution if requirements not met
- Applied globally before any script code runs
- Can be placed anywhere but typically at top
- Multiple #Requires statements allowed

**Detection Strategy for PSEBuilder**:
1. Parse script for `#Requires -Version X.X` statement
2. Compare version with 6.0 threshold
3. If >= 6.0 → use pwsh.exe
4. If <= 5.1 → use powershell.exe

### pwsh.exe Location Discovery

**Standard Installation Paths**:
- Default: `C:\Program Files\PowerShell\7\pwsh.exe`
- Version-specific: `C:\Program Files\PowerShell\<version>\pwsh.exe`

**Discovery Methods**:
1. Check PATH environment variable
2. Use `where.exe pwsh` command
3. Check registry: `HKLM\SOFTWARE\Microsoft\PowerShell\7`
4. Search standard installation directory

**Implementation Example**:
```csharp
string FindPwsh()
{
    // Check PATH first
    var pathPwsh = FindInPath("pwsh.exe");
    if (pathPwsh != null) return pathPwsh;

    // Check standard location
    var standardPath = @"C:\Program Files\PowerShell\7\pwsh.exe";
    if (File.Exists(standardPath)) return standardPath;

    // Check latest version in install dir
    var psDir = @"C:\Program Files\PowerShell";
    // Find highest version number...

    return "powershell.exe"; // Fallback to PS 5.1
}
```

---

## 6. Existing Tool Analysis: PS2EXE

### PS2EXE Current Approach

**Limitations** (identical to PSEBuilder):
- Uses .NET Framework compiler (csc.exe)
- Generates .NET 4.x binaries only
- Designed for Windows PowerShell 5.1
- Cannot natively compile for PowerShell 7

### Their "PowerShell 7 Support"

**Version 1.0.6+ (2020)**:
- Added "limited support for PowerShell Core"
- Starts Windows PowerShell in background
- Uses workaround approach

**Workaround Mechanism**:
```powershell
# Compiled exe runs PS 5.1
# Script detects PS7 requirement
# Re-invokes itself via pwsh.exe
# Passes output and exit code through
```

**Key Insight**:
- Even the most popular tool (15K+ GitHub stars) doesn't have true PS7 support
- They use a workaround: .NET Framework wrapper → pwsh.exe
- Suggests full .NET Core compilation is complex and perhaps unnecessary

---

## 7. Implementation Options

### Option 1: Hybrid Approach (Recommended)

**Architecture**:
```
PSEBuilder.exe (WPF GUI - .NET Framework)
  ↓
csc.exe (compile C# wrapper - .NET Framework)
  ↓
GeneratedWrapper.exe (.NET Framework 4.x)
  ↓
[NEW] PowerShell Version Selection
  ├─→ powershell.exe (PS 5.1) OR
  └─→ pwsh.exe (PS 7+)
  ↓
User's PowerShell Script
```

**Changes Required**:

1. **UI Additions**:
   - Add "PowerShell Version" dropdown to Basic Configuration tab
   - Options: "Windows PowerShell 5.1" / "PowerShell 7+"
   - Auto-detect button based on #Requires parsing

2. **Script Parsing**:
   ```powershell
   function Get-RequiredPSVersion($scriptPath) {
       $content = Get-Content $scriptPath -Raw
       if ($content -match '#Requires\s+-Version\s+(\d+\.\d+)') {
           return [version]$Matches[1]
       }
       return $null
   }
   ```

3. **C# Wrapper Modification**:
   ```csharp
   // Current
   string psExecutable = "powershell.exe";

   // Modified
   string psExecutable = usePowerShell7 ?
       FindPwshExecutable() : "powershell.exe";
   ```

4. **pwsh.exe Discovery**:
   - Implement path discovery logic
   - Fallback to PATH environment variable
   - Validate pwsh.exe exists before build

**Pros**:
- ✅ **Minimal code changes** (~200 lines)
- ✅ **No new dependencies** (.NET SDK not required)
- ✅ **Maintains small exe size** (~500KB)
- ✅ **Quick implementation** (1-2 weeks)
- ✅ **Backwards compatible** (existing PS 5.1 support unchanged)
- ✅ **Proven approach** (PS2EXE uses similar method)
- ✅ **Works with existing architecture**

**Cons**:
- ❌ Still requires .NET Framework on target machine
- ❌ Not "true" .NET Core executables
- ❌ Cannot create Linux/Mac executables
- ❌ Wrapper is .NET Framework calling .NET Core PowerShell
- ❌ Two runtime dependencies (.NET Framework + PowerShell 7)

**Implementation Complexity**: ⭐⭐☆☆☆ (2/5)

---

### Option 2: Full .NET Core Rewrite (Future v2.0)

**Architecture**:
```
PSEBuilder.exe (WPF GUI - .NET 6+)
  ↓
dotnet CLI (with generated .csproj)
  ↓
GeneratedWrapper.exe (.NET 6+ single-file)
  ↓
[Runtime-determined]
  ├─→ powershell.exe (PS 5.1) OR
  └─→ pwsh.exe (PS 7+)
  ↓
User's PowerShell Script
```

**Changes Required**:

1. **Rewrite GUI for .NET 6+**:
   - Migrate PSEBuilder.ps1 WPF code to .NET 6
   - Could keep as PowerShell 7 script using WPF
   - Or convert to C# WPF application

2. **Replace csc.exe with dotnet CLI**:
   ```csharp
   // Generate .csproj file dynamically
   string csproj = GenerateProjectFile(settings);
   File.WriteAllText("temp.csproj", csproj);

   // Use dotnet publish
   string args = "publish temp.csproj -c Release -r win-x64 " +
                 "-p:PublishSingleFile=true " +
                 "-p:SelfContained=false";
   Process.Start("dotnet", args);
   ```

3. **Multi-Runtime Support**:
   - Target both .NET Framework (PS 5.1) and .NET 6+ (PS 7)
   - Or commit to .NET 6+ only
   - Handle runtime identifier selection

4. **Cross-Platform Considerations**:
   - Could support Linux/macOS executable generation
   - WPF scripts still Windows-only
   - Terminal scripts could be cross-platform

**Pros**:
- ✅ **True .NET Core executables**
- ✅ **Future-proof architecture**
- ✅ **Could support cross-platform** (Linux/Mac)
- ✅ **Better alignment with modern .NET**
- ✅ **Cleaner separation of PS versions**
- ✅ **Could leverage .NET 6+ features**

**Cons**:
- ❌ **Major rewrite required** (2-3 months development)
- ❌ **Requires .NET SDK** on build machine (200-500MB)
- ❌ **Self-contained exes are huge** (70-150MB vs current 500KB)
- ❌ **Framework-dependent requires .NET runtime** on target
- ❌ **Complex dependency management**
- ❌ **Breaking change** for existing users
- ❌ **WPF still Windows-only** anyway
- ❌ **Learning curve** for contributors

**Implementation Complexity**: ⭐⭐⭐⭐⭐ (5/5)

---

## 8. Recommended Implementation Strategy

### Phase 1: v1.1 - Hybrid Approach (3-4 weeks)

**Week 1: UI & Detection**
- Add "PowerShell Version" dropdown to GUI
- Implement #Requires statement parser
- Add auto-detect functionality
- Update UI to show detected version

**Week 2: Wrapper Modification**
- Modify C# wrapper template to accept version parameter
- Implement pwsh.exe discovery logic
- Add error handling for missing pwsh.exe
- Update resource embedding for new parameter

**Week 3: Testing**
- Test PS 5.1 scripts (ensure no regression)
- Test PS 7 scripts with new functionality
- Test #Requires auto-detection
- Test missing pwsh.exe error handling

**Week 4: Documentation & Polish**
- Update README with PS7 support
- Add PS7 examples
- Update screenshot
- Create migration guide for PS 5.1 → PS 7 scripts

**Deliverables**:
- ✅ PS7 support via pwsh.exe launch
- ✅ Auto-detection of version requirements
- ✅ Backwards compatible with PS 5.1
- ✅ Updated documentation
- ✅ Small exe size maintained (~500KB)

---

### Phase 2: v2.0 - Full .NET Core Rewrite (Future)

**Prerequisites**:
- Phase 1 adopted by users
- User feedback on PS7 usage patterns
- .NET 8 or later stable
- Clear demand for cross-platform support

**Scope**:
- Complete rewrite of compilation engine
- Migration to .NET 8+ runtime
- Cross-platform executable support
- Modern C# codebase (if converting from PowerShell)

**Timeline**: 3-6 months

**Decision Criteria**:
- User demand for cross-platform
- File size concerns (self-contained vs framework-dependent)
- .NET Framework deprecation timeline
- Community feedback

---

## 9. Technical Specifications

### Hybrid Approach Implementation Details

#### UI Changes (PSEBuilder.ps1)

**New ComboBox in Basic Configuration Tab**:
```xml
<Label Grid.Row="X" Grid.Column="0">PowerShell Version:</Label>
<ComboBox Name="cmbPowerShellVersion" Grid.Row="X" Grid.Column="1">
    <ComboBoxItem Content="Windows PowerShell 5.1" IsSelected="True"/>
    <ComboBoxItem Content="PowerShell 7+" />
</ComboBox>
<Button Name="btnAutoDetectVersion" Grid.Row="X" Grid.Column="2"
        Content="Auto-Detect" ToolTip="Detect from #Requires statement"/>
```

**Auto-Detection Function**:
```powershell
function Get-RequiredPowerShellVersion {
    param([string]$ScriptPath)

    if (-not (Test-Path $ScriptPath)) {
        return $null
    }

    $content = Get-Content $ScriptPath -Raw

    # Look for #Requires -Version X.X
    if ($content -match '(?m)^\s*#Requires\s+-Version\s+(\d+(\.\d+)?)') {
        $version = [version]$Matches[1]

        if ($version.Major -ge 6) {
            return "7+"
        } else {
            return "5.1"
        }
    }

    return $null # No #Requires found
}

# Button click handler
$btnAutoDetectVersion.Add_Click({
    $scriptPath = $txtMainScript.Text
    $detectedVersion = Get-RequiredPowerShellVersion -ScriptPath $scriptPath

    if ($detectedVersion) {
        if ($detectedVersion -eq "7+") {
            $cmbPowerShellVersion.SelectedIndex = 1
        } else {
            $cmbPowerShellVersion.SelectedIndex = 0
        }
        [System.Windows.MessageBox]::Show(
            "Detected PowerShell $detectedVersion requirement",
            "Auto-Detection",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Information
        )
    } else {
        [System.Windows.MessageBox]::Show(
            "No #Requires -Version statement found`nDefaulting to Windows PowerShell 5.1",
            "Auto-Detection",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Warning
        )
    }
})
```

#### C# Wrapper Modifications

**Current C# Wrapper Template** (simplified):
```csharp
class Program {
    static int Main(string[] args) {
        // Extract resources...

        ProcessStartInfo psi = new ProcessStartInfo {
            FileName = "powershell.exe",
            Arguments = $"-ExecutionPolicy {policy} -File \"{scriptPath}\"",
            // ...
        };

        Process process = Process.Start(psi);
        return process.ExitCode;
    }
}
```

**Modified C# Wrapper Template**:
```csharp
class Program {
    // Embedded at compile time
    const bool UsePowerShell7 = {USE_POWERSHELL_7};

    static string FindPowerShellExecutable() {
        if (!UsePowerShell7) {
            return "powershell.exe";
        }

        // Try to find pwsh.exe

        // 1. Check PATH
        string pwshFromPath = FindExecutableInPath("pwsh.exe");
        if (pwshFromPath != null) return pwshFromPath;

        // 2. Check standard installation directory
        string standardPath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles),
            "PowerShell", "7", "pwsh.exe"
        );
        if (File.Exists(standardPath)) return standardPath;

        // 3. Find latest version
        string psDir = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles),
            "PowerShell"
        );

        if (Directory.Exists(psDir)) {
            var versions = Directory.GetDirectories(psDir)
                .Select(d => new DirectoryInfo(d).Name)
                .Where(v => Version.TryParse(v, out _))
                .OrderByDescending(v => Version.Parse(v));

            foreach (var version in versions) {
                string pwshPath = Path.Combine(psDir, version, "pwsh.exe");
                if (File.Exists(pwshPath)) return pwshPath;
            }
        }

        // Fallback to Windows PowerShell
        Console.WriteLine("Warning: PowerShell 7+ not found, falling back to Windows PowerShell 5.1");
        return "powershell.exe";
    }

    static string FindExecutableInPath(string executable) {
        string pathEnv = Environment.GetEnvironmentVariable("PATH");
        if (string.IsNullOrEmpty(pathEnv)) return null;

        foreach (string path in pathEnv.Split(';')) {
            string fullPath = Path.Combine(path.Trim(), executable);
            if (File.Exists(fullPath)) return fullPath;
        }

        return null;
    }

    static int Main(string[] args) {
        // Extract resources...

        string psExecutable = FindPowerShellExecutable();

        ProcessStartInfo psi = new ProcessStartInfo {
            FileName = psExecutable,
            Arguments = $"-ExecutionPolicy {policy} -File \"{scriptPath}\"",
            // ...
        };

        Process process = Process.Start(psi);
        return process.ExitCode;
    }
}
```

**PowerShell Build Function Update**:
```powershell
# In Build-Executable function
$usePowerShell7 = $cmbPowerShellVersion.SelectedIndex -eq 1
$csharpCode = $csharpCode -replace '\{USE_POWERSHELL_7\}', $usePowerShell7.ToString().ToLower()
```

---

### Validation & Error Handling

**Pre-Build Validation**:
```powershell
function Test-PowerShellVersionAvailability {
    param([bool]$UsePowerShell7)

    if ($UsePowerShell7) {
        # Check if pwsh.exe exists anywhere
        $pwshInPath = Get-Command pwsh -ErrorAction SilentlyContinue
        $standardPath = "$env:ProgramFiles\PowerShell\7\pwsh.exe"

        if (-not $pwshInPath -and -not (Test-Path $standardPath)) {
            return @{
                Success = $false
                Message = "PowerShell 7 is not installed on this system.`n`n" +
                         "Please install PowerShell 7 from:`n" +
                         "https://github.com/PowerShell/PowerShell/releases`n`n" +
                         "Or change PowerShell Version to 'Windows PowerShell 5.1'"
            }
        }
    }

    return @{ Success = $true }
}

# In Build button click handler
$validation = Test-PowerShellVersionAvailability -UsePowerShell7 ($cmbPowerShellVersion.SelectedIndex -eq 1)
if (-not $validation.Success) {
    [System.Windows.MessageBox]::Show(
        $validation.Message,
        "PowerShell Version Not Available",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Error
    )
    return
}
```

---

## 10. Risk Assessment

### Hybrid Approach Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| pwsh.exe not found on target | Medium | High | Fallback to powershell.exe with warning |
| Version mismatch issues | Low | Medium | Clear documentation of requirements |
| Module compatibility | Medium | Medium | Document known incompatibilities |
| User confusion | Low | Low | Clear UI labels and tooltips |
| Regression in PS 5.1 | Low | High | Comprehensive testing suite |

### Full Rewrite Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| File size explosion | High | High | Careful framework-dependent vs self-contained choice |
| .NET SDK dependency | High | Medium | Clear documentation, installation guide |
| Breaking existing workflows | High | High | Maintain v1.x for legacy support |
| Development timeline overrun | Medium | Medium | Phased approach, MVP first |
| Community adoption resistance | Medium | Low | Communicate benefits clearly |

---

## 11. Success Metrics

### Hybrid Approach (v1.1)

**Technical Metrics**:
- ✅ 100% backwards compatibility with PS 5.1 scripts
- ✅ <5% exe size increase (maintain ~500KB)
- ✅ <500ms overhead for version detection
- ✅ 95%+ pwsh.exe detection success rate

**User Metrics**:
- ✅ 50%+ of new builds use PS7 within 3 months
- ✅ <5% user-reported compatibility issues
- ✅ Positive community feedback
- ✅ GitHub stars increase 20%+

### Full Rewrite (v2.0)

**Technical Metrics**:
- ✅ Cross-platform build support (Windows/Linux/macOS)
- ✅ <50MB self-contained exe size (with trimming)
- ✅ <5MB framework-dependent exe size
- ✅ .NET 8+ target framework

**User Metrics**:
- ✅ 30%+ of users migrate from v1.x
- ✅ 10%+ builds target non-Windows platforms
- ✅ Maintained or improved GitHub engagement
- ✅ Professional/enterprise adoption increases

---

## 12. Conclusion & Next Steps

### Key Findings

1. **PowerShell 7 Support is Feasible**:
   - Hybrid approach requires minimal changes
   - Full rewrite possible but complex and time-consuming

2. **WPF is Fully Supported**:
   - Works in PowerShell 7 on Windows
   - No cross-platform GUI with WPF

3. **PS2EXE Uses Workaround**:
   - Validates that hybrid approach is industry-standard
   - No major tool has full .NET Core compilation

4. **File Size is Critical Concern**:
   - Current 500KB exes are a major selling point
   - .NET Core self-contained would be 70-150MB
   - Framework-dependent maintains small size but adds runtime dependency

### Recommended Action Plan

**Immediate (Next Sprint)**:
1. ✅ Review this research document with team/community
2. ✅ Create GitHub issue for PS7 support tracking
3. ✅ Gather community feedback on preferred approach
4. ✅ Create proof-of-concept for hybrid approach

**Short Term (v1.1 - Next 4 weeks)**:
1. ✅ Implement hybrid approach (Option 1)
2. ✅ Add comprehensive tests
3. ✅ Update documentation
4. ✅ Release beta for community testing

**Long Term (v2.0 - Future)**:
1. ⏳ Monitor .NET Core adoption trends
2. ⏳ Evaluate cross-platform demand
3. ⏳ Consider full rewrite if justified
4. ⏳ Maintain v1.x for stable production use

---

## 13. References

### Official Documentation
- [Microsoft Learn: Differences between Windows PowerShell 5.1 and PowerShell 7.x](https://learn.microsoft.com/en-us/powershell/scripting/whats-new/differences-from-windows-powershell)
- [Microsoft Learn: about_Requires](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_requires)
- [Microsoft Learn: .NET Single-File Deployment](https://learn.microsoft.com/en-us/dotnet/core/deploying/single-file/overview)
- [Microsoft Learn: .NET Core 3 Desktop Applications](https://devblogs.microsoft.com/dotnet/net-core-3-and-support-for-windows-desktop-applications/)

### Community Resources
- [PS2EXE GitHub Repository](https://github.com/MScholtes/PS2EXE)
- [PowerShell Gallery: ps2exe](https://www.powershellgallery.com/packages/ps2exe)
- [Stack Overflow: .NET Core Compilation Discussions](https://stackoverflow.com/)

### Research Sources
- Web searches conducted 2025-10-18
- Sequential thinking analysis via MCP
- Industry best practices review

---

**Document Version**: 1.0
**Last Updated**: 2025-10-18
**Next Review**: After v1.1 implementation
