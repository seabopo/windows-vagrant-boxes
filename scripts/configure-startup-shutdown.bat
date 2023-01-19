
REM Disable the Shutdown Tracker
C:\windows\System32\reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" /v ShutdownReasonOn /t REG_DWORD /d 0 /f

REM Enable/Extend Autologon for the Vagrant Account
REM C:\windows\System32\autologon.exe "vagrant" "" "vagrant"
C:\windows\System32\reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoLogonCount /t REG_DWORD /d 9999 /f
