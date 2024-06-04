# SMB signing can be exploited when it's disabled or improperly configured, allowing attackers to perform man-in-the-middle attacks to intercept and manipulate SMB traffic. This could lead to unauthorized access, data leakage, or execution of malicious commands within a network. NTLM Relay is used to relay hashes through a network if SMB Signing is disabled.
# How it is exploited: https://warroom.rsmus.com/how-to-perform-ntlm-relay/ 
# May have a minor impact on SMB file share performance. Monitor and use roll-back script to disable SMB Signing if needed.

#Enforce SMB Signing
Set-SmbServerConfiguration -RequireSecuritySignature $true -Force
#Disable SMBv1 
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
