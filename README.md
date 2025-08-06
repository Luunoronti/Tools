# Tools
Open scripts and such



# Hyper-V toolset on Alpine Linux VM:

 1. Get script:
    ```
    wget https://raw.githubusercontent.com/Luunoronti/Tools/master/alpine-vm-setup-hyperv.sh
    ```
3. Make it executable:
    ```
    chmod +x alpine-vm-setup-hyperv.sh
    ```
4. Execute
    ```
    ./alpine-vm-setup-hyperv.sh
    ```

# Microsoft Edit on Ubuntu:

1. Download
   ```
   wget https://github.com/microsoft/edit/releases/download/v1.2.0/edit-1.2.0-x86_64-linux-gnu.tar.zst
   ```
2. Unpack (may require tgz support)
   ```
   sudo apt install zstd
   tar --zstd -xvf edit-1.2.0-x86_64-linux-gnu.tar.zst
   ```
3. Make it executable
   ```
   chmod +x edit
   ```
4. Move to bin
   ```
   sudo mv edit /usr/local/bin/
   ```
5. (optional) change nano to run edit
   ```
   sudo mv /bin/nano /bin/nano.original
   sudo ln -s /usr/local/bin/edit /bin/nano
   ```

Full Script:
   ```
   wget https://github.com/microsoft/edit/releases/download/v1.2.0/edit-1.2.0-x86_64-linux-gnu.tar.zst
   sudo apt install zstd
   tar --zstd -xvf edit-1.2.0-x86_64-linux-gnu.tar.zst
   chmod +x edit
   sudo mv edit /usr/local/bin/
   sudo mv /bin/nano /bin/nano.original
   sudo ln -s /usr/local/bin/edit /bin/nano
   ```
   

# Change Ubuntu MotD (Message of the Day):
1. Edit file
   ```
   edit /etc/update-motd.d/10-help-text
   ```


# WinDirStat using winget:
```
winget install -e --id WinDirStat.WinDirStat
```



# Windows 11 PowerShell 7, SSH

``` powershell
Invoke-WebRequest -Uri https://github.com/PowerShell/PowerShell/releases/latest/download/PowerShell-7.4.2-win-x64.msi -OutFile $env:TEMP\PowerShell7.msi
Start-Process msiexec.exe -ArgumentList "/i `"$env:TEMP\PowerShell7.msi`" /qn" -Wait
Remove-Item $env:TEMP\PowerShell7.msi

Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

Copy-Item "$env:ProgramData\ssh\sshd_config" "$env:ProgramData\ssh\sshd_config.bak" -Force
(Get-Content "$env:ProgramData\ssh\sshd_config" | Where-Object { $_ -notmatch "^ForceCommand" }) + 'ForceCommand "C:\Program Files\PowerShell\7\pwsh.exe"' | Set-Content "$env:ProgramData\ssh\sshd_config"
Restart-Service sshd

```


# Global build number in TeamCity

This solution works for me:

1. Create Build Configuration.
Let say "GenerateBuildNumber", do not attach template. Do not specify any build steps. Click Save.

2. Edit configuration for your project.
Go to "Build Configuration Settings->Dependencies". Click "Add new snapshot dependecy".
Select previously created "GenerateBuildNumber" in "Depend on" section. Uncheck option "Do not run new build if there is a suitable one". Click Save.

3. Go to "General Settings", clear "Build number format:", click the button on the left side with 3 lines. Select "%dep.YouProjName_GenerateBuildNumber.env.BUILD_NUMBER%". Click Save.
 
4. Run your project build. Firstly it should start "GenerateBuildNumber" project then your project with a generated number. Do the steps 2-4 for every project you want to have unique generated number. Profit!
