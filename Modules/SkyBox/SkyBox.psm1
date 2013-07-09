Clear-Host

$logo = @'
 _____ _         ______           
/  ___| |        | ___ \          
\ `--.| | ___   _| |_/ / _____  __
 `--. \ |/ / | | | ___ \/ _ \ \/ /
/\__/ /   <| |_| | |_/ / (_) >  < 
\____/|_|\_\\__, \____/ \___/_/\_\
             __/ |                
            |___/                 
'@

Write-Host -ForegroundColor Cyan $logo

# Verify Setup
if($SkyBox -eq $null) {
	throw "Invalid SkyBox object provided to Verify.ps1"
}

if(!(Test-Path $SkyBox.Core)) {
	throw "SkyBox Core is invalid. TODO: Auto fix?"
}

if(!(Test-Path $SkyBox.Repo)) {
	Write-Warning "You don't have a personal SkyBox Repo configured. Use New-SkyBoxRepo command to configure it."
}

function InstallChocolatey {
	Write-Host -Foreground Yellow "**** Configuring Chocolatey ****"
	[Environment]::SetEnvironmentVariable("ChocolateyInstall", $SkyBox.Apps, [System.EnvironmentVariableTarget]::User)
	$script = (New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1")
	Invoke-Expression $script
	Write-Host -Foreground Green "**** Configured Chocolatey ****"
}

# Check for installed tools
if(!(Test-Path $SkyBox.Apps)) {
	InstallChocolatey
}

if(!(Get-Command -ErrorAction SilentlyContinue chocolatey)) {
	$choc = Join-Path $SkyBox.Apps "bin\chocolatey.bat"
	if(Test-Path $choc) {
		Write-Host -Foreground Yellow "**** Placing Chocolatey in PATH ****"
		$bindir = Join-Path $SkyBox.Apps bin
		$oldPath = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
		[Environment]::SetEnvironmentVariable("PATH", "$oldPath;$bindir", [System.EnvironmentVariableTarget]::User);
		$env:PATH = "$env:PATH;$bindir"
		Write-Host -Foreground Green "**** Placed Chocolatey in PATH ****"
	} else {
		InstallChocolatey
	}
}

# Install Git, since it's a core package
if(!(Get-Command -ErrorAction SilentlyContinue git)) {
	Write-Host -ForegroundColor Yellow "**** Installing 'git' ****"
	cinstm git.commandline
	Write-Host -ForegroundColor Green "**** Installed 'git' ****"
}

# Load Public Functions
Get-ChildItem (Join-Path $PsScriptRoot "Functions") | ForEach-Object {
	$name = [IO.Path]::GetFileNameWithoutExtension($_.FullName)
	. $_.FullName
	Export-ModuleMember -Function $name
}