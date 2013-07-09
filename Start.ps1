$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$core = Join-Path $root "Core"

# Initial Variables
$Global:SkyBox = New-Object PSCustomObject
Add-Member -InputObject $SkyBox -NotePropertyMembers @{
	"Root" = $root;
	"Core" = $core;
	"Apps" = Join-Path $root "Apps";
	"Repo" = Join-Path $root "Repo";
	"Modules" = Join-Path $core "Modules";
}

$repoFile = Join-Path $SkyBox.Root ".repo"
if(Test-Path $repoFile) {
	$SkyBox.Repo = [IO.File]::ReadAllText($repoFile).Trim()
}

# Import Module
$env:PSModulePath = "$($env:PSModulePath);$($SkyBox.Modules)"
Import-Module SkyBox