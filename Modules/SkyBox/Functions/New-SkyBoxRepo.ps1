function New-SkyBoxRepo {
	param(
		[Parameter(Mandatory=$false)][string]$Location = $SkyBox.Repo,
		[Parameter(Mandatory=$false)][switch]$Clobber)
	Write-Host "Creating SkyBox Repo in $Location"

	if(Test-Path $Location) {
		if($Clobber) {
			del -rec -for $Location
		} else {
			throw "Repo exists at $Location. Pass the -Clobber option to destroy it and create a new one."
			return;
		}
	}

	mkdir $Location | Out-Null
	pushd $Location
	git init
	popd

	# Register the repo
	if($Location -ne $SkyBox.Repo) {
		$Location | Out-File -Encoding ASCII -FilePath (Join-Path $SkyBox.Root ".repo")
	}
}