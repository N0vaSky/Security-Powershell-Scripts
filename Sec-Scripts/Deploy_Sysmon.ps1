# Make sure the script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) {
    Write-Error "You must run this script as an Administrator!"
    exit 1
}

# Set error action preference so that non-terminating errors stop execution in try/catch
$ErrorActionPreference = 'Stop'

# Define URLs
$sysmonUrl       = "https://download.sysinternals.com/files/Sysmon.zip"
$sysmonConfigUrl = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml"

# Define temporary download/extraction paths
$tempPath     = $env:TEMP
$sysmonZip    = Join-Path $tempPath "Sysmon.zip"
$sysmonFolder = Join-Path $tempPath "Sysmon"

# Final desired paths
$configFolder       = "C:\SysmonConfig"
$sysmonConfigPath   = Join-Path $configFolder "sysmonconfig-export.xml"
$sysmonExePath      = "C:\Windows\Sysmon.exe"  # or another path if preferred

# Decide whether to use Sysmon.exe or Sysmon64.exe
# (Sysmon64.exe is recommended on x64 systems)
$is64Bit  = [Environment]::Is64BitOperatingSystem
$exeName  = if ($is64Bit) { "Sysmon64.exe" } else { "Sysmon.exe" }

Write-Host "Checking if Sysmon is already installed at $sysmonExePath..."
if (-not (Test-Path $sysmonExePath)) {
    Write-Host "Sysmon not found. Downloading and installing..."

    # Download Sysmon
    Write-Host "Downloading Sysmon from $sysmonUrl..."
    try {
        Invoke-WebRequest -Uri $sysmonUrl -OutFile $sysmonZip
        Write-Host "Sysmon downloaded successfully to $sysmonZip."
    } catch {
        Write-Error "Failed to download Sysmon. $($_.Exception.Message)"
        exit 1
    }

    # Extract Sysmon zip
    Write-Host "Extracting Sysmon to $sysmonFolder..."
    try {
        # Remove the folder if it already exists (to avoid conflicts)
        if (Test-Path $sysmonFolder) {
            Remove-Item -Path $sysmonFolder -Recurse -Force
        }
        Expand-Archive -Path $sysmonZip -DestinationPath $sysmonFolder -Force
        Write-Host "Sysmon extracted successfully."
    } catch {
        Write-Error "Failed to extract Sysmon. $($_.Exception.Message)"
        exit 1
    }

    # Copy Sysmon exe to C:\Windows (or your preferred path)
    $sourceExe = Join-Path $sysmonFolder $exeName
    if (-not (Test-Path $sourceExe)) {
        Write-Error "Could not find $exeName in the extracted files at $sourceExe."
        exit 1
    }

    Write-Host "Copying $sourceExe to $sysmonExePath..."
    try {
        Copy-Item -Path $sourceExe -Destination $sysmonExePath -Force
        Write-Host "Sysmon copied to $sysmonExePath."
    } catch {
        Write-Error "Failed to copy Sysmon to $sysmonExePath. $($_.Exception.Message)"
        exit 1
    }

} else {
    Write-Host "Sysmon is already installed at $sysmonExePath."
}

# Make sure we use the Sysmon installed at $sysmonExePath
$sysmonExe = $sysmonExePath

# Prepare config folder if needed
if (-not (Test-Path $configFolder)) {
    Write-Host "Creating config folder at $configFolder..."
    New-Item -ItemType Directory -Path $configFolder | Out-Null
}

Write-Host "Downloading Sysmon configuration from $sysmonConfigUrl..."
try {
    Invoke-WebRequest -Uri $sysmonConfigUrl -OutFile $sysmonConfigPath
    Write-Host "Sysmon configuration downloaded to $sysmonConfigPath."
} catch {
    Write-Error "Failed to download Sysmon config file. $($_.Exception.Message)"
    exit 1
}

Write-Host "Uninstalling Sysmon (to re-register driver cleanly)..."
try {
    Start-Process -FilePath $sysmonExe -ArgumentList "-u force" -NoNewWindow -Wait
    Write-Host "Sysmon uninstalled successfully."
} catch {
    Write-Error "Failed to uninstall Sysmon. $($_.Exception.Message)"
    exit 1
}

Write-Host "Reinstalling Sysmon and applying configuration..."
try {
    Start-Process -FilePath $sysmonExe -ArgumentList "-accepteula -i $sysmonConfigPath" -NoNewWindow -Wait
    Write-Host "Sysmon reinstalled and configuration applied successfully."
} catch {
    Write-Error "Failed to reinstall Sysmon or apply configuration. $($_.Exception.Message)"
    exit 1
}

Write-Host "Ensuring Sysmon service is running and setting service recovery options..."
try {
    Start-Sleep -Seconds 5  # Give the service time to initialize
    $service = Get-Service -Name "Sysmon" -ErrorAction SilentlyContinue

    if ($null -eq $service) {
        Write-Host "Sysmon service not found. Attempting to start it again..."
        Start-Process -FilePath $sysmonExe -ArgumentList "-accepteula -i $sysmonConfigPath" -NoNewWindow -Wait
        Start-Sleep -Seconds 5
        $service = Get-Service -Name "Sysmon" -ErrorAction SilentlyContinue
    }

    if ($service -and $service.Status -ne 'Running') {
        Start-Service -Name "Sysmon"
        Write-Host "Sysmon service started successfully."
    } elseif ($service -and $service.Status -eq 'Running') {
        Write-Host "Sysmon service is already running."
    } else {
        Write-Error "Sysmon service could not be found or started."
        exit 1
    }

    # Set service recovery options
    sc.exe failure Sysmon reset= 0 actions= restart/5000/restart/5000/restart/5000 | Out-Null
    sc.exe config Sysmon start= auto | Out-Null

    Write-Host "Sysmon service recovery options set successfully."
} catch {
    Write-Error "Failed to ensure Sysmon service is running or set recovery. $($_.Exception.Message)"
    exit 1
}

Write-Host "`nSysmon installation and configuration completed successfully!"
