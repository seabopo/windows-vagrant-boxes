
ECHO Installing Microsoft Edge ...

if not exist "C:\Windows\Temp\MicrosoftEdgeEnterpriseX64.msi" (
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/b3b57e5f-4415-4d9c-a1f6-3707529eb431/MicrosoftEdgeEnterpriseX64.msi', 'C:\Windows\Temp\MicrosoftEdgeEnterpriseX64.msi')" <NUL
)

if exist "C:\Windows\Temp\MicrosoftEdgeEnterpriseX64.msi" (
  C:\Windows\System32\MsiExec.exe /i C:\Windows\Temp\MicrosoftEdgeEnterpriseX64.msi /qn
)

cmd /c C:\Windows\System32\reg.exe ADD HKCU\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice /v ProgId /t REG_SZ /d "MSEdgeHTM" /f
cmd /c C:\Windows\System32\reg.exe ADD HKCU\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice /v ProgId /t REG_SZ /d "MSEdgeHTM" /f

cmd /c C:\windows\System32\reg.exe ADD HKLM\SOFTWARE\Policies\Microsoft\Edge /v HideFirstRunExperience /t REG_DWORD /d 1 /f
