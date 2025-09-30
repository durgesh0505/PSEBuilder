# Changelog

All notable changes to PowerShell Executable Builder will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2025-01-XX

### Added
- **Modern WPF GUI** - Complete graphical interface for building executables
- **Multi-Resource Embedding** - Support for embedding multiple files (images, configs, certificates, etc.)
- **Automatic Image Conversion** - Built-in JPG/PNG → ICO conversion for icons
- **Professional Assembly Metadata** - Full support for version, company, copyright, description
- **Security Hardening**:
  - Resource size validation (100MB limit per file)
  - Path traversal prevention
  - Timeout range validation (1-1440 minutes)
  - Comprehensive string escaping (injection-proof)
  - Resource key validation
- **Memory Safety**:
  - Try-finally disposal patterns for all IDisposable objects
  - Proper cleanup of temporary files
  - Triple garbage collection for complete resource release
- **No File Locking** - Direct csc.exe compilation prevents assembly loading issues
- **Get-ResourcePath Helper** - Automatically available in user scripts for resource access
- **Debug Logging** - Comprehensive debug logs saved to Downloads folder
- **Retry Logic** - Exponential backoff for file deletion operations

### Changed
- **Compilation Method** - Switched from Add-Type to direct csc.exe execution
  - Eliminates file locking issues
  - Faster compilation
  - Better error reporting
- **File Extension Logic** - Improved detection using Path.GetExtension() instead of Contains(".")
- **FileStream Handling** - Proper disposal with nested try-finally blocks

### Fixed
- **File Lock Issue** - Executables can now be deleted immediately after build
- **Memory Leaks** - All GDI+ objects (Bitmap, Graphics, Streams) properly disposed
- **Race Conditions** - Retry loop with exponential backoff for file operations
- **C# Injection Vulnerability** - Comprehensive escaping of all special characters
- **FileStream Leaks** - Guaranteed disposal even on exceptions

### Removed
- **Taskbar Icon Customization** - Removed Set-AppIcon helper and app-icon.ico embedding
  - Architectural limitation: C# wrapper launches PowerShell.exe child process
  - Taskbar shows PowerShell.exe icon (unavoidable)
  - File icon still works correctly via /win32icon compiler option
  - Documented limitation and workaround (Windows shortcuts) in README

### Security
- Added input validation for all user-provided data
- Implemented resource size limits to prevent OutOfMemory errors
- Validated filenames to prevent path traversal attacks
- Hardened C# code generation against injection attacks
- Added timeout bounds checking

### Performance
- Direct csc.exe compilation (~20% faster than Add-Type)
- Optimized string escaping using StringBuilder (O(n) instead of O(n²))
- Triple GC collection pattern for thorough cleanup
- Efficient resource encoding and embedding

---

## [0.9.0] - Previous Development Versions

### Changed
- Multiple iterations on resource embedding
- Various approaches to icon handling
- Testing different compilation methods
- GUI refinements and simplifications

### Known Issues (Resolved in 1.0.0)
- ❌ File locking after compilation → **FIXED**: Using csc.exe directly
- ❌ Memory leaks in image conversion → **FIXED**: Try-finally disposal patterns
- ❌ Race conditions in file deletion → **FIXED**: Retry loop with exponential backoff
- ❌ Taskbar icon not customizable → **DOCUMENTED**: Architectural limitation

---

## Future Releases

### [1.1.0] - Planned
- Configuration save/load (JSON presets)
- Recent files menu
- Build history
- Drag-and-drop file support
- Enhanced error messages with suggestions

### [2.0.0] - Future
- PowerShell 7+ (Core) support
- Linux/.NET Core compatibility
- Command-line mode for scriptable builds
- Template system for common scenarios
- Plugin architecture for extensibility
- Digital signature validation
- AES encryption for sensitive resources

---

## Credits

This version incorporates fixes and improvements inspired by:
- PS2EXE (https://github.com/MScholtes/PS2EXE) - Original concept
- PowerChell (https://github.com/scrt/PowerChell) - Alternative approaches
- itm4n's articles and tools - Security best practices
- PowerShell community feedback

---

For detailed technical changes, see git commit history.