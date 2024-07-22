# Define the path to the Sysmon executable
$sysmonExePath = "C:\Windows\Sysmon64.exe"

Write-Output "Stopping Sysmon service..."
# Stop the Sysmon service if it's running
try {
    Stop-Process -Name "Sysmon" -Force -ErrorAction SilentlyContinue
    Write-Output "Sysmon service stopped successfully."
} catch {
    Write-Output "Failed to stop Sysmon service or service is not running. $_"
}

Write-Output "Uninstalling Sysmon..."
# Check if Sysmon is installed
if (Test-Path $sysmonExePath) {
    try {
        # Uninstall Sysmon
        Start-Process -FilePath $sysmonExePath -ArgumentList "-u" -NoNewWindow -Wait
        Write-Output "Sysmon uninstalled successfully."
    } catch {
        Write-Output "Failed to uninstall Sysmon. $_"
        exit 1
    }
} else {
    Write-Output "Sysmon is not installed on this machine."
}

Write-Output "Cleaning up Sysmon files..."
# Remove any remaining Sysmon files
try {
    # Remove the Sysmon executable
    if (Test-Path $sysmonExePath) {
        Remove-Item -Path $sysmonExePath -Force
    }

    # Remove any remaining Sysmon configuration files
    $sysmonConfigPath = "C:\Windows\sysmonconfig-export.xml"
    if (Test-Path $sysmonConfigPath) {
        Remove-Item -Path $sysmonConfigPath -Force
    }

    Write-Output "Sysmon files cleaned up successfully."
} catch {
    Write-Output "Failed to clean up Sysmon files. $_"
    exit 1
}

Write-Output "Cleaning up Sysmon event logs..."
# Remove Sysmon event logs
try {
    wevtutil.exe cl Microsoft-Windows-Sysmon/Operational
    Write-Output "Sysmon event logs cleaned up successfully."
} catch {
    Write-Output "Failed to clean up Sysmon event logs. $_"
    exit 1
}

Write-Output "Sysmon removal and cleanup completed successfully."
