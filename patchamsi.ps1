function Test-CommandExists {
	Param ($command)

	$oldPreference = $ErrorActionPreference
	$ErrorActionPreference = 'stop'
	try {if(Get-Command $command){ $true }}
	Catch { $false }
	Finally {$ErrorActionPreference=$oldPreference}

}

#current role
if (!(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Write-Error "Needs to be run from elevated shell"
	return
}

if( -not (Test-CommandExists "takeown") -and -not (Test-CommandExists "movefile") ) {
    Write-Error "Please install Sysinternals Suite before running this script"
    return
}

if( -not (Test-Path -Path $env:USERPROFILE'\Downloads\amsi.dll' -PathType Leaf)) {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/wyrdsec/WinDev/main/lib/amsi.dll" -OutFile $env:USERPROFILE'\Downloads\amsi.dll'
}

Write-Output "Taking ownership of 'C:\Windows\System32\amsi.dll'"
takeown /f C:\Windows\System32\amsi.dll /a

Write-Output "Granting full access to administrators"
icacls.exe C:\Windows\System32\amsi.dll /grant administrators:F

Write-Output "Renaming asmi.dll to amsi_legit.dll"
ren C:\Windows\System32\amsi.dll amsi_legit.dll

Write-Output "Schedule move file to system folder"
movefile /nobanner $env:USERPROFILE'\Downloads\amsi.dll' C:\Windows\System32\amsi.dll

Write-Output "Creating file to disable amsi '$null > C:\.disableamsi'"
Write-Output "Delete this file to enable amsi again"
$null > C:\.disableamsi

Write-Output "System restart needed for file to be moved."
$restart = Read-Host -Prompt "Restart now?: Y/N"

if ( ($restart -eq 'y') -or ($restart -eq 'Y') ) {
    Restart-Computer
}