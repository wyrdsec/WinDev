# WinDev

A quick Powershell script to install development tools on a fresh VM

## Setup.ps1

Run the following oneliner **from an admin powershell env** to start the setup:

```
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/wyrdsec/WinDev/main/setup.ps1'))
```

---

If running powershell functions directly from a string downloaded over the
internet wigs you out (understandable), you can follow the following steps:

Download the 'setup.ps1' file:
```
Invoke-WebRequest -Uri https://raw.githubusercontent.com/wyrdsec/WinDev/main/setup.ps1 -OutFile $env:USERPROFILE'\Downloads\setup.ps1'
```

Review the downloaded file and then run the script with:
```
Get-Content $env:USERPROFILE'\Downloads\setup.ps1' -Raw | IEX
```

## PatchAmsi.ps1

Patches amsi so that it can be disabled or enabled quickly.  
Credit to [Pavel Tsakalidis](https://www.pavel.gr/) and his great [blog post](https://www.pavel.gr/blog/neutralising-amsi-system-wide-as-an-admin) on this.

Download and execute the script (automatic dll download):
```
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/wyrdsec/WinDev/main/patchamsi.ps1'))
```

---

Download and review:
```
Invoke-WebRequest -Uri https://raw.githubusercontent.com/wyrdsec/WinDev/main/patchamsi.ps1 -OutFile $env:USERPROFILE'\Downloads\patchamsi.ps1'
```

Launch script:
```
Get-Content $env:USERPROFILE'\Downloads\patchamsi.ps1' -Raw | IEX
```

Download `amsi.dll` directly:
```
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/wyrdsec/WinDev/main/lib/amsi.dll" -OutFile $env:USERPROFILE'\Downloads\amsi.dll'
```

Current amsi.dll SHA256 sum:  
e88443a94846eb83e331c98db5c9de0785d4b40b56416d6c28466c3b1a89ced3

Code for amsi.dll is in `lib/amsi_dllmain.cpp`
