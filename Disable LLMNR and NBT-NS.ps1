# Disabling LLMNR prevents attackers from intercepting login credentials by spoofing DNS responses, enhancing network security : https://tcm-sec.com/llmnr-poisoning-and-how-to-prevent-it/ 
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -Value 0 -Type DWord
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces\tcpip* -Name NetbiosOptions -Value 2
