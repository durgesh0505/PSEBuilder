# Simple test script for PowerShell Executor
param(
    [string]$Message = "Hello from PowerShell Executor!",
    [string]$Target = "World"
)

Write-Host "PowerShell Executor Test Script" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

Write-Host "Message: $Message" -ForegroundColor Cyan
Write-Host "Target: $Target" -ForegroundColor Cyan

Write-Host ""
Write-Host "System Information:" -ForegroundColor Yellow
Write-Host "OS Version: $($PSVersionTable.PSVersion)" -ForegroundColor Gray
Write-Host "Execution Policy: $(Get-ExecutionPolicy)" -ForegroundColor Gray
Write-Host "Current User: $($env:USERNAME)" -ForegroundColor Gray
Write-Host "Is Admin: $((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))" -ForegroundColor Gray

Write-Host ""
Write-Host "PowerShell script executed successfully!" -ForegroundColor Green

# Return some data
$result = @{
    Status = "Success"
    Message = $Message
    Target = $Target
    Timestamp = Get-Date
}

return $result