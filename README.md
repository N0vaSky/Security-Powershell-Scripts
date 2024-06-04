# Security-Powershell-Scripts
A Complication of PowerShell scripts to set security configurations (with rollback scripts). These are meant to be deployed with an RMM across an environment. Some of these scripts are made for Domain Controllers only. 

## This repository contains a collection of PowerShell scripts designed to enhance the security of Windows environments. Each script addresses specific security concerns, such as disabling insecure features, enforcing robust security policies, and mitigating potential vulnerabilities.

## Included Scripts
### Disable PowerShell 2.0
- Disables Windows PowerShell 2.0 to mitigate downgrade attacks.

### Disable LLMNR and NBT-NS
- Disables LLMNR and NBT-NS to prevent attackers from intercepting login credentials.
### Enforce SMB Signing / Disable SMBv1
- Enforces SMB signing and disables SMBv1 to protect against man-in-the-middle attacks and other SMB vulnerabilities.

### Fix Unquoted Service Paths: All credit to NetSecJedi: https://github.com/NetSecJedi/FixUnquotedPaths/blob/master/FixUnquotedPaths.ps1
- Corrects unquoted service paths to prevent exploitation.

### Set Password Policy
- Configures domain password policies for enhanced security.
- Run this on the Domain Controller

### Disable WPAD
- Disables WPAD to prevent unauthorized proxy configuration.

### Mark Domain Admin Accounts as Sensitive and Not to Be Delegated
- Ensures domain admin accounts are marked as sensitive and not to be delegated.
- Run this on the Domain Controller

## Roll-back Scripts
Included roll-back scripts allow you to revert changes if necessary.

## Usage
Each script includes detailed comments and usage instructions. Execute these scripts in a PowerShell window with appropriate privileges.

## Disclaimer
Use these scripts at your own risk. Always test in a controlled environment before deploying to production.
