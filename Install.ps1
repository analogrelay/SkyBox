Write-Host -ForegroundColor Cyan "**** Installing SkyBox ****"

Write-Debug "Determining SkyBox Root Folder"
$SkyBoxRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

# Write a script to boot SkyBox in to the PowerShell Profile
Write-Debug "Reading Old Profile"
$OldProfile = ""

$script = Convert-Path (Join-Path (Join-Path $SkyBoxRoot "Core") "Start.ps1")
if(Test-Path $Profile) {
	Write-Host -ForegroundColor Yellow "You already have a profile script. I'm not going to mess with it. Add the below line to it in order to launch SkyBox:"
	Write-Host -ForegroundColor Cyan "& $script"
} else {
	$parent = Split-Path -Parent $Profile
	if(!(Test-Path $parent)) {
		Write-Debug "Creating Profile Directory: $parent"
		mkdir $parent | Out-Null
	}
	"& $script" | Out-File -Encoding ASCII -FilePath $Profile
}

Write-Debug "Setting Execution Policy to RemoteSigned"
if(([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
	Set-ExecutionPolicy RemoteSigned
} else {
	Write-Host -ForegroundColor Yellow "Launching Admin PowerShell to Set Execution Policy ..."
	$elevate = (Join-Path $SkyBoxRoot "Core\Elevate\$env:PROCESSOR_ARCHITECTURE\Release\elevate.exe")
	& $elevate powershell -NoLogo -NoProfile -Command "Set-ExecutionPolicy RemoteSigned"
}

Write-Host -ForegroundColor Green "Starting SkyBox..."
& $script