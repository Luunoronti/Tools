# Tools
Open scripts and such


# Unlock Inte 520 NICs:

1. Download file:
```
curl -L -o intel https://gist.githubusercontent.com/jeffangelion/e7736a0802d4782d5e3d4d2e08e8306b/raw/b2e6710c22922c27b1b23ff4d8d7c1f88c265469/intel_x520_patcher-sh
```
3. Make it executable
```
chmod +x intel
```
5. List NICs
```
ip link show
```
6. Run on 10G NIC
```
sudo ./intel <nic name, like eth0>
```



# Install commands

Install packs using winget (PowerShell 7, WinDirStat, 7zip, Visual Studio 2022 Build Tools (Desktop development with C++), Windows SDK, .NET 6 SDK)
```
winget install --id Microsoft.Powershell --source winget --accept-package-agreements --accept-source-agreements
winget install -e --id WinDirStat.WinDirStat
winget install --id 7zip.7zip --source winget --accept-package-agreements --accept-source-agreements

$override = @(
        "--quiet",
        "--wait",
        "--norestart",
        "--nocache",
        "--installPath", "C:\BuildTools",
        "--add", "Microsoft.VisualStudio.Workload.NativeDesktop;includeRecommended",
        "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",                # MSVC v143
        "--add", "Microsoft.VisualStudio.Component.VC.ATL",                           # ATL
        "--add", "Microsoft.VisualStudio.Component.VC.CMake.Project",                 # CMake support
        "--add", "Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset",             # (opcjonalne) narzędzia LLVM/Clang
        "--add", "Microsoft.VisualStudio.Component.VC.Runtimes.x64.Spectre",          # Spectre
        "--add", "Microsoft.VisualStudio.Component.VC.Redist.14.Latest",              # Redistry
        "--add", "Microsoft.VisualStudio.Component.Static.Analysis.Tools",            # Analyzers
        "--add", "Microsoft.Component.MSBuild",
        "--add", "Microsoft.VisualStudio.Component.NuGet",                            # NuGet
        "--add", "Microsoft.VisualStudio.Component.Windows10SDK.19041"                # Win10 SDK headers/libs
    )
$overrideStr = $override -join " "

winget install --id Microsoft.VisualStudio.2022.BuildTools -e --source winget `
      --accept-package-agreements --accept-source-agreements `
      --override $overrideStr

winget install --id Microsoft.WindowsSDK -e --source winget --accept-package-agreements --accept-source-agreements
winget install --id Microsoft.DotNet.SDK.6 -e --source winget --accept-package-agreements --accept-source-agreements
```

Set terminal to use PowerShell 7 as a default, restart Terminal.

windows update modules
```
Install-Module -Name PSWindowsUpdate -Force
```

SSH Server
```
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
(Get-Content "$env:ProgramData\ssh\sshd_config" | Where-Object { $_ -notmatch "^ForceCommand" }) + 'ForceCommand "C:\Program Files\PowerShell\7\pwsh.exe"' | Set-Content "$env:ProgramData\ssh\sshd_config"
Restart-Service sshd
```

Set user rights for SSHD
```
function Grant-Right($account, $right) {
    $sid = (New-Object System.Security.Principal.NTAccount($account)).Translate([System.Security.Principal.SecurityIdentifier]).Value
    $tmp = "$env:TEMP\secpol.inf"
    $db  = "$env:TEMP\secpol.sdb"

    secedit /export /cfg $tmp
    (Get-Content $tmp) -replace "($right = .*)", "`$1,$sid" | Set-Content $tmp
    secedit /import /db $db /cfg $tmp
    secedit /configure /db $db /cfg $tmp /areas USER_RIGHTS
    Remove-Item $tmp,$db -Force -ErrorAction SilentlyContinue
}

$user = "$env:USERDOMAIN\$env:USERNAME"

Grant-Right $user "SeServiceLogonRight"
Grant-Right $user "SeAssignPrimaryTokenPrivilege"
Grant-Right $user "SeIncreaseQuotaPrivilege"
Grant-Right $user "SeChangeNotifyPrivilege"
Grant-Right $user "SeTcbPrivilege"
```

Reconfigure sshd service to run as current user
``` 
Stop-Service sshd
$svc = Get-WmiObject Win32_Service -Filter "Name='sshd'"
$svc.Change($null,$null,$null,$null,$null,$null,$user,$env:UserPassword)  # requires password
Set-Service sshd -StartupType Automatic
Start-Service sshd
```

Install Visual C++ Redistributables
```
$vcUrl = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$vcExe = "$env:TEMP\vc_redist.x64.exe"
Invoke-WebRequest $vcUrl -OutFile $vcExe
Start-Process $vcExe -ArgumentList "/install /quiet /norestart" -Wait
```


.NET Framework 4.8 Developer Pack (SDK)
```
$url = "https://download.microsoft.com/download/8/1/8/81877d8b-a9b2-4153-9ad2-63a6441d11dd/NDP481-DevPack-ENU.exe"
$exe = "$env:TEMP\dotnet48sdk.exe"
Invoke-WebRequest $url -OutFile $exe
Start-Process $exe -ArgumentList "/quiet /norestart" -Wait
```


Copying btop4win from $src to $dst
```
$src = "\\dysk\Software\Tools\btop4win"
$dst = "C:\tools\btop4win"
New-Item -ItemType Directory -Path $dst -Force | Out-Null
Copy-Item -Path $src\* -Destination $dst -Recurse -Force
```






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
# Rename via PS:
```
Rename-Computer -NewName "NewComputerName" -Force -Restart
```


# Windows Updates via PS:
``` powershell
Install-Module -Name PSWindowsUpdate -Force
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
Import-Module PSWindowsUpdate
Get-WindowsUpdate
Install-WindowsUpdate -AcceptAll -AutoReboot

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
Invoke-WebRequest -Uri https://github.com/PowerShell/PowerShell/releases/download/v7.5.2/PowerShell-7.5.2-win-x64.msi -OutFile $env:TEMP\PowerShell7.msi
Start-Process msiexec.exe -ArgumentList "/i $env:TEMP\PowerShell7.msi /qn" -Wait
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
