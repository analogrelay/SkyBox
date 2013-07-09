Clear-Host
Write-Host -ForegroundColor Cyan "**** STARTING SkyBox ****"
$env:HOME = Join-Path $env:HOMEDRIVE $env:HOMEPATH
$SkyBoxRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkyBoxHome = Join-Path $env:HOME ".skybox"
$CloudRoot = Split-Path -Parent $SkyBoxRoot

# Get packages
$DownloadsPath = Join-Path $SkyBoxHome Downloads
if(!(Test-Path $DownloadsPath)) {
	mkdir $DownloadsPath | Out-Null
}

function FetchPackage($name, $url, $dest) {
	$uri = New-Object System.Uri $url
	$path = Join-Path $DownloadsPath $dest
	if(!(Test-Path $path)) {
		Write-Host -ForegroundColor Yellow "**** FETCHING $name ****"
		Invoke-WebRequest -Uri $url -OutFile $path
	}
}
FetchPackage ruby "http://dl.bintray.com/oneclick/rubyinstaller/ruby-1.9.3-p448-i386-mingw32.7z?direct" "ruby-1.9.3.7z"
FetchPackage rubydevkit "https://github.com/downloads/oneclick/rubyinstaller/DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe" "rubydevkit-4.5.2.7z"
FetchPackage git "https://msysgit.googlecode.com/files/PortableGit-1.8.3-preview20130601.7z" "git-1.8.3.7z"
del function:\FetchPackage

# Integrity Check
function CheckPackage($name, $ver, $hash) {
	$path = "$SkyBoxHome\Downloads\$name-$ver.7z"
	if(!(Test-Path $path)) {
		throw "Missing package: $name $ver"
	}
	$actual = (Get-FileHash $path -Algorithm SHA256).Hash
	if($actual -ne $hash) {
		throw "Corrupt package: $name $ver"
	}
}
CheckPackage ruby 1.9.3 cse/8yZluaosX2bmNnnKG0pqFnJVeWgdmOlx5ZOspQY=
CheckPackage rubydevkit 4.5.2 bDr1SH2v2laAi6927dJisgILGyWrhqq/lyYp9KalRJE=
CheckPackage git 1.8.3 2JDxyeJ7ICf+yoFtk5ePIrSbahZ/kogJ9ZgjVMWlC2c=
del function:\CheckPackage


if(!(Test-Path $SkyBoxHome)) {
	mkdir $SkyBoxHome | Out-Null
}

function Unpack($packageName, $packageVersion, $subdir) {
	$PackageRoot = Join-Path $SkyBoxHome "Packages\$packageName"
	if(!(Test-Path $PackageRoot)) {
		Write-Host -ForegroundColor Yellow "**** INSTALLING $packageName $packageVersion ****"
		mkdir $PackageRoot | Out-Null
		pushd $PackageRoot | Out-Null
		& "$SkyBoxRoot\7za.exe" x "$SkyBoxHome\Downloads\$packageName-$packageVersion.7z" | Out-Null
		if($subdir) {
			Move-Item $subdir\* .
			rmdir $subdir
		}
		popd | Out-Null
	} else {
		Write-Host -ForegroundColor Green "**** FOUND $packageName ****"
	}
	$PackageRoot
}

# Unpack files
$RubyRoot = Unpack ruby 1.9.3 ruby-1.9.3-p448-i386-mingw32
$RDKRoot = Unpack rubydevkit 4.5.2
$GitRoot = Unpack git 1.8.3
del function:\Unpack

$env:PATH = "$($env:PATH);$RubyRoot\bin;$GitRoot\cmd"

# Set up Ruby DevKit
if(!(Test-Path "$RDKRoot\.installed") -or ((cat "$RDKRoot\.installed") -ne "YES")) {
	Write-Host -ForegroundColor Yellow "**** CONFIGURING rubydevkit ****"
@"
---
- $RubyRoot
"@ | Out-File "config.yml" -Encoding ASCII
	ruby "$RDKRoot\dk.rb" install
	del config.yml
	"YES" > "$RDKRoot\.installed"
}

# Install Chef
function EnsureGem($gem, $version) {
	$result = @(gem list $gem --local | where { ($_.Trim().Length -gt 0) -and ($_ -ne "*** LOCAL GEMS ***") })
	if($result.Length -lt 1) {
		Write-Host -ForegroundColor Yellow "**** INSTALLING $gem (this may take a while) ****"
		if($version) {
			gem install $gem --version $version
		} else {
			gem install $gem
		}
	} else {
		Write-Host -ForegroundColor Green "**** FOUND $gem ****"
	}
}

EnsureGem sys-admin
EnsureGem win32-dir 0.3.7
EnsureGem win32-process 0.6.5
EnsureGem win32-service
EnsureGem win32-security
EnsureGem win32-taskscheduler
EnsureGem puppet
del function:\EnsureGem

Write-Host -ForegroundColor Cyan "*******************"
Write-Host -ForegroundColor Cyan "Welcome to SkyBox!"
Write-Host -ForegroundColor Cyan "*******************"