# Disabling the Windows PowerShell 2.0 mitigates against a downgrade attack that evades the Windows PowerShell 5.0 script block logging feature. 
# This command should disable both "MicrosoftWindowsPowerShellV2Root" and "MicrosoftWindowsPowerShellV2" which correspond to "Windows PowerShell 2.0" and "Windows PowerShell 2.0 Engine" respectively in "Turn Windows features on or off".

Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root
