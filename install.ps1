$wingetPackages = @(
    'git.git',
    'Microsoft.VisualStudioCode',
    'Google.Chrome'
)

# Check for winget
if (-not(Get-Module -ListAvailable -Name Microsoft.Winget.Client)) {
    try {
        Find-PackageProvider -Name NuGet -ForceBootstrap -IncludeDependencies
        Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery -AllowClobber | Out-Null
      } catch {
        throw "Microsoft.Winget.Client was not installed successfully"
      } finally {
        # Check to be sure it acutally installed
        if (-not(Get-Module -ListAvailable -Name Microsoft.Winget.Client)) {
          throw "Microsoft.Winget.Client was not found. Check that the Windows Package Manager PowerShell module was installed correctly."
        }
        Write-Output "Microsoft.Winget.Client was installed successfully"
        Repair-WinGetPackageManager
    }
} else {
    Write-Output "Microsoft.Winget.Client is already installed"
    Import-Module -Name Microsoft.Winget.Client
}

# Install winget packages
foreach ($package in $wingetPackages) {
    Write-Output "Installing package: $package"
    $packageExists = Get-WinGetPackage -Id $package -Exact
    if ($packageExists) {
        Write-Output "Package $package is already installed"
        continue
    }
    else {
        Write-Output("test")
        Install-WingetPackage -Id $package
    }
    
}
