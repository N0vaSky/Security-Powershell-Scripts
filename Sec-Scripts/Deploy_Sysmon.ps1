# Define URLs and Paths
$sysmonUrl = "https://download.sysinternals.com/files/Sysmon.zip"
$sysmonConfigUrl = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml"
$sysmonZip = "$env:TEMP\Sysmon.zip"
$sysmonFolder = "$env:TEMP\Sysmon"
$sysmonConfigPath = "$env:TEMP\sysmonconfig-export.xml"
$sysmonExePath = "C:\Windows\Sysmon.exe"

Write-Output "Checking if Sysmon is already installed..."
# Check if Sysmon is already installed
if (-Not (Test-Path $sysmonExePath)) {
    Write-Output "Sysmon is not installed. Downloading and installing..."

    Write-Output "Downloading Sysmon from $sysmonUrl..."
    # Download Sysmon
    try {
        Invoke-WebRequest -Uri $sysmonUrl -OutFile $sysmonZip
        Write-Output "Sysmon downloaded successfully."
    } catch {
        Write-Output "Failed to download Sysmon. $_"
        exit 1
    }

    Write-Output "Extracting Sysmon..."
    # Extract Sysmon
    try {
        Expand-Archive -Path $sysmonZip -DestinationPath $sysmonFolder -Force
        Write-Output "Sysmon extracted successfully."
    } catch {
        Write-Output "Failed to extract Sysmon. $_"
        exit 1
    }

    $sysmonExe = "$sysmonFolder\Sysmon.exe"
} else {
    Write-Output "Sysmon is already installed."
    $sysmonExe = $sysmonExePath
}

Write-Output "Downloading Sysmon configuration from $sysmonConfigUrl..."
# Download Sysmon configuration file
try {
    Invoke-WebRequest -Uri $sysmonConfigUrl -OutFile $sysmonConfigPath
    Write-Output "Sysmon configuration downloaded successfully."
} catch {
    Write-Output "Failed to download Sysmon configuration. $_"
    exit 1
}

Write-Output "Uninstalling Sysmon to deregister driver..."
# Uninstall Sysmon to deregister driver
try {
    Start-Process -FilePath $sysmonExe -ArgumentList "-u force" -NoNewWindow -Wait
    Write-Output "Sysmon uninstalled successfully."
} catch {
    Write-Output "Failed to uninstall Sysmon. $_"
    exit 1
}

Write-Output "Reinstalling Sysmon and applying configuration..."
# Reinstall Sysmon and apply configuration
try {
    Start-Process -FilePath $sysmonExe -ArgumentList "-accepteula -i $sysmonConfigPath" -NoNewWindow -Wait
    Write-Output "Sysmon reinstalled and configuration applied successfully."
} catch {
    Write-Output "Failed to reinstall Sysmon or apply configuration. $_"
    exit 1
}

Write-Output "Ensuring Sysmon service is running and setting recovery options..."
# Ensure Sysmon service is running and set recovery options
try {
    Start-Sleep -Seconds 5 # Give it a few seconds to start
    $service = Get-Service -Name Sysmon -ErrorAction SilentlyContinue
    if ($service -eq $null) {
        Write-Output "Sysmon service not found. Trying to start the service again..."
        Start-Process -FilePath $sysmonExe -ArgumentList "-accepteula -i $sysmonConfigPath" -NoNewWindow -Wait
        Start-Sleep -Seconds 5 # Give it a few seconds to start
        $service = Get-Service -Name Sysmon -ErrorAction SilentlyContinue
    }
    if ($service.Status -ne 'Running') {
        Start-Service -Name Sysmon
        Write-Output "Sysmon service started successfully."
    } else {
        Write-Output "Sysmon service is already running."
    }
    
    # Set service recovery options
    sc.exe failure Sysmon reset= 0 actions= restart/5000/restart/5000/restart/5000
    sc.exe config Sysmon start= auto

    Write-Output "Sysmon service recovery options set successfully."
} catch {
    Write-Output "Failed to ensure Sysmon service is running or set recovery options. $_"
    exit 1
}

Write-Output "Setting Sysmon event log size limit to 900 MB and configuring retention policy..."
# Set the Sysmon event log size limit and retention policy
try {
    wevtutil sl Microsoft-Windows-Sysmon/Operational /ms:943718400
    wevtutil sl Microsoft-Windows-Sysmon/Operational /rt:true
    Write-Output "Sysmon event log size limit set and retention policy configured successfully."
} catch {
    Write-Output "Failed to set Sysmon event log size limit or configure retention policy. $_"
    exit 1
}

Write-Output "Sysmon configuration and service check completed successfully."
