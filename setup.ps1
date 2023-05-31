#
# Functions
#
# Source: https://github.com/jamestharpe/windows-development-environment

function Update-Environment-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function Install-Program {	
	param (
		[Parameter(Mandatory)]
		[string]$ProgramName,
		[string]$OverrideParams
	)

	if (!$PSBoundParameters.ContainsKey('OverrideParams')) {
		winget install --id $ProgramName --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
	}
	else {
		winget install --id $ProgramName --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --override $OverrideParams
	}
}

function Test-CommandExists {
	Param ($command)

	$oldPreference = $ErrorActionPreference
	$ErrorActionPreference = ‘stop’
	try {if(Get-Command $command){ $true }}
	Catch { $false }
	Finally {$ErrorActionPreference=$oldPreference}

}

#current role
if (!(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Write-Error "Needs to be run from elevated shell"
	return
}

# Apparently progress bars drastically slow WebRequest downloads
$ProgressPreference = 'SilentlyContinue'

# 
# Dependencies
#
# Source: https://github.com/microsoft/winget-cli/issues/1861

# Get 'Desktop Installer'
Write-Output "Installing dependency 'Microsoft Desktop Installer'"
Add-AppxPackage -Path https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx

# Get Microsoft.UI.Xaml
# Note: nuget is not owned by Microsoft, but is funded by microsoft.:shrug:
Write-Output "Installing dependency 'Microsoft UI Xaml 2.7'"
Invoke-WebRequest -Uri https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.3 -OutFile $env:USERPROFILE'\Downloads\microsoft.ui.xaml.2.7.3.zip'
Expand-Archive -Path $env:USERPROFILE'\Downloads\microsoft.ui.xaml.2.7.3.zip' -DestinationPath $env:USERPROFILE'\Downloads\microsoft.ui.xaml.2.7.3'
Add-AppxPackage $env:USERPROFILE'\Downloads\microsoft.ui.xaml.2.7.3\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.appx'

Remove-Item $env:USERPROFILE'\Downloads\microsoft.ui.xaml.2.7.3.zip'
Remove-Item $env:USERPROFILE'\Downloads\microsoft.ui.xaml.2.7.3' -Recurse

#
# Winget
#
# Source: https://stackoverflow.com/questions/74166150/install-winget-by-the-command-line-powershell

# get latest download url
Write-Output "Installing winget"
$URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
$URL = (Invoke-WebRequest -UseBasicParsing -Uri $URL).Content | ConvertFrom-Json |
        Select-Object -ExpandProperty "assets" |
        Where-Object "browser_download_url" -Match '.msixbundle' |
        Select-Object -ExpandProperty "browser_download_url"

# download
Invoke-WebRequest -Uri $URL -OutFile $env:USERPROFILE'\Downloads\Setup.msix' -UseBasicParsing

# install
Add-AppxPackage -Path $env:USERPROFILE'\Downloads\Setup.msix'

# delete file
Remove-Item $env:USERPROFILE'\Downloads\Setup.msix'

Update-Environment-Path

# winget programs
Install-Program -ProgramName Mozilla.firefox
Install-Program -ProgramName Git.Git
Install-Program -ProgramName Microsoft.VisualStudioCode -OverrideParams '/SILENT /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders"'
Install-Program -ProgramName Python.Python.3.9
Install-Program -ProgramName 7zip.7Zip
Install-Program -ProgramName WinSCP.WinSCP
Install-Program -ProgramName ojdkbuild.ojdkbuild
Install-Program -ProgramName ojdkbuild.openjdk.11.jdk
Install-Program -ProgramName Notepad++.Notepad++
Install-Program -ProgramName WiresharkFoundation.Wireshark

# MS STORE id's
# Windbg: 9PGJGD53TN86
# Sysinternals: 9P7KNL5RWT25
Install-Program -ProgramName 9PGJGD53TN86
Install-Program -ProgramName 9P7KNL5RWT25

Update-Environment-Path

# Other programs not on winget

$URL = "https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest"
$URL = (Invoke-WebRequest -UseBasicParsing -Uri $URL).Content | ConvertFrom-Json |
		Select-Object -ExpandProperty "assets" |
		Where-Object "browser_download_url" -Match '.zip' |
		Select-Object -ExpandProperty "browser_download_url"

Invoke-WebRequest -Uri $URL -OutFile $env:USERPROFILE'\Downloads\ghidra.zip' -UseBasicParsing
Expand-Archive -Path $env:USERPROFILE'\Downloads\ghidra.zip' -DestinationPath $env:USERPROFILE'\Documents\ghidra'
Remove-Item $env:USERPROFILE'\Downloads\ghidra.zip'


$URL = "https://api.github.com/repos/trailofbits/winchecksec/releases/latest"
$URL = (Invoke-WebRequest -UseBasicParsing -Uri $URL).Content | ConvertFrom-Json |
		Select-Object -ExpandProperty "assets" |
		Where-Object "browser_download_url" -Match 'windows.x64.Release.zip' |
		Select-Object -ExpandProperty "browser_download_url"

Invoke-WebRequest -Uri $URL -OutFile $env:USERPROFILE'\Downloads\winchecksec.zip' -UseBasicParsing
Expand-Archive -Path $env:USERPROFILE'\Downloads\winchecksec.zip' -DestinationPath $env:USERPROFILE'\Documents\winchecksec'
Remove-Item $env:USERPROFILE'\Downloads\winchecksec.zip'


$URL = 'https://sourceforge.net/projects/regshot/files/latest/download'
Invoke-WebRequest -UseBasicParsing -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox -Uri $URL -OutFile $env:USERPROFILE'\Downloads\regshot.zip'
Expand-Archive -Path $env:USERPROFILE'\Downloads\regshot.zip' -DestinationPath $env:USERPROFILE'\Documents\regshot'
Remove-Item $env:USERPROFILE'\Downloads\regshot.zip'

$URL = 'https://repo.msys2.org/distrib/msys2-x86_64-latest.exe'
Invoke-WebRequest -UseBasicParsing -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox -Uri $URL -OutFile $env:USERPROFILE'\Downloads\msys2-x86_64-latest.exe'
Start-Process -FilePath $env:USERPROFILE'\Downloads\msys2-x86_64-latest.exe' -ArgumentList 'install','--root C:\MSYS2','--confirm-command'
Remove-Item $env:USERPROFILE'\Downloads\msys2-x86_64-latest.exe'
C:\MSYS2\msys2.exe bash -l -c 'yes | pacman -Syu'
C:\MSYS2\msys2.exe bash -l -c 'yes | pacman -S base-devel gcc'

# Pip programs
pip install frida

# Restore Progress bars to session
$ProgressPreference = 'Continue'

# Post install things
Update-Environment-Path

# Log all system services
Get-Service | Out-File $env:USERPROFILE'\Documents\Services.txt'
pipelist.exe | Out-File $env:USERPROFILE'\Documents\Pipes.txt'

# Enable unsinged drivers
# Will fail if secure boot is enabled
bcdedit /set nointegritychecks off

# Create low priv user
New-LocalUser -Name "lowpriv" -Description "Low privileged user" -NoPassword
Add-LocalGroupMember -Group "Users" -Member "lowpriv"
