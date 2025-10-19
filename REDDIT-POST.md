# PSEBuilder Reddit Post

---

## Copy & Paste Below:

---

Hey everyone! 👋

I'm relatively new to PowerShell development and wanted to share a project I've been working on - **PSEBuilder** (PowerShell Script to EXE Builder).

### What is it?

A modern GUI-based PowerShell executable builder that creates standalone Windows executables from PowerShell scripts. Inspired by PS2EXE, but with a professional interface, multi-resource support, and automatic PowerShell 7+ detection!

### Key Features:

- **Modern Dark Theme Interface** - Professional WPF GUI with Microsoft Fluent Design colors (dark mode built-in!)
- **PowerShell 7+ Support** - Automatically detects and uses pwsh.exe (PowerShell 7+) with intelligent fallback to powershell.exe (5.1)
- **Multi-Resource Embedding** - Easily embed images, configs, JSON files, certificates, and any data files directly into your EXE
- **Automatic Icon Conversion** - Drop in PNG/JPG images and they're automatically converted to .ico format
- **Direct csc.exe Compilation** - No file locking issues, memory-safe with proper disposal patterns
- **Security Hardened** - Input validation, resource size limits, injection-proof string escaping
- **Zero Dependencies** - Works on any Windows machine with PowerShell 3.0+ and .NET Framework 4.0+ (already built-in!)
- **Professional Metadata** - Company, version, copyright, description embedded in exe properties

### Why I built it:

I wanted a tool that combined the ease of PS2EXE with modern features like resource management, automatic PS7+ support, and a beautiful dark-themed GUI. No more command-line parameter lookups or separate resource management!

### Tech Stack:

- PowerShell WPF (XAML) with dark theme
- Direct csc.exe compilation (no Add-Type)
- C# wrapper with automatic PowerShell version detection
- Base64 resource embedding system

### Links:

- **GitHub**: https://github.com/durgesh0505/PSEBuilder
- **Documentation**: Comprehensive guides included in the repo

### What's Next:

Planning to add configuration save/load presets, drag-and-drop file support, and build history in future versions.

Would love to hear your feedback or suggestions! This is one of my first projects in the PowerShell community, so any constructive criticism is welcome. 😊

---

**Note:** Upload `docs/screenshot.png` with your post for visual appeal!
