param (
    [ValidateSet("dev-laptop", "laptop", "dev-desktop", "desktop")]
    [string]$ComputerType = "dev-laptop"
)

$wingetPackages = @(
    'Git.Git',
    'Microsoft.VisualStudioCode',
    'OpenJS.NodeJS.LTS',
    'Mozilla.Firefox',
    '7zip.7zip',
    'JanDeDobbeleer.OhMyPosh',
    'Microsoft.PowerToys',
    'Microsoft.WindowsTerminal',
    'Mozilla.Firefox',
    'Notepad++.Notepad++',
    'VideoLAN.VLC',
    'WinDirStat.WinDirStat',
    'WinSCP.WinSCP',
    'Discord.Discord',
    'Valve.Steam',
    'ShareX.ShareX',
    'CodecGuide.K-LiteCodecPack.Full',
    'th-ch.YouTubeMusic',
    'GNU.Nano',
    'Python.Python.3.12',
    'GitHub.cli',
    'SyncTrayzor.SyncTrayzor',
    'Microsoft.Office',
    'PuTTY.PuTTY',
    'tailscale.tailscale'
)

$wingetPackagesDevDesktop = @(
    'SyncTrayzor.SyncTrayzor',
    'Microsoft.VisualStudio.2022.Community.Preview'
)

$dots_repo = "mrkal666/dots"

$provider = Get-PackageProvider NuGet -ErrorAction Ignore
if (-not $provider) {
	Write-Host "Installing provider NuGet"
        Find-PackageProvider -Name NuGet -ForceBootstrap -IncludeDependencies
}

# Update App Installer
winget install "9nblggh4nns1" -s msstore --force

# Check for winget
if (-not(Get-Module -ListAvailable -Name Microsoft.Winget.Client)) {
    try {
        Install-Module -Name Microsoft.WinGet.Client -Force -AllowClobber
      } catch {
        throw "Microsoft.Winget.Client was not installed successfully"
      } finally {
        # Check to be sure it acutally installed
        if (-not(Get-Module -ListAvailable -Name Microsoft.Winget.Client)) {
          throw "Microsoft.Winget.Client was not found. Check that the Windows Package Manager PowerShell module was installed correctly."
        }
        Write-Output "Microsoft.Winget.Client was installed successfully"
        Import-Module -Name Microsoft.Winget.Client
        Repair-WinGetPackageManager
    }
} else {
    Write-Output "Microsoft.Winget.Client is already installed"
    Import-Module -Name Microsoft.Winget.Client
    Repair-WinGetPackageManager
}

try {
    Import-Module DISM -UseWindowsPowerShell
} catch {
    throw "Cannot import DISM module"
}

Write-Output $ComputerType

# We have to execute winget once to accept the EULA
winget

# Install Github CLI
Write-Output "Installing package: GitHub.cli"
    
$listAppGitHub = winget list --exact --id "GitHub.cli"
if (![String]::Join("", $listAppGitHub).Contains("GitHub.cli")) {
    Write-host "Installing: GitHub.cli"
    $status = Install-WinGetPackage -Id "GitHub.cli"
    if ($status.Status -ne "Ok") {
        Write-Host "Failed to install package: GitHub.cli"
    }
}
else {
    Write-host "Skipping: GitHub.cli (already installed)"
}

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Auth to GitHub
gh auth login

# Install winget packages
foreach ($package in $wingetPackages) {
    Write-Output "Installing package: $package"
    
    $listApp = winget list --exact --id $package
    if (![String]::Join("", $listApp).Contains($package)) {
        Write-host "Installing: " $package
        $status = Install-WinGetPackage -Id $package
        if ($status.Status -ne "Ok") {
            Write-Host "Failed to install package: " $package
        }
    }
    else {
        Write-host "Skipping: " $package " (already installed)"
    }
}

if($ComputerType -eq 'dev-desktop' -or $ComputerType -eq 'desktop') {
    foreach ($package in $wingetPackagesDevDesktop) {
        Write-Output "Installing package: $package"
        
        $listApp = winget list --exact --id $package
        if (![String]::Join("", $listApp).Contains($package)) {
            Write-host "Installing: " $package
            $status = Install-WinGetPackage -Filter "--accept-source-agreements --accept-package-agreements" -Id $package
            if ($status.Status -ne "Ok") {
                Write-Host "Failed to install package: " $package
            }
        }
        else {
            Write-host "Skipping: " $package " (already installed)"
        }
    }
}


# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install Dots
if (Test-Path "$env:USERPROFILE/dots") {
    Write-Output "User profile/dots directory exists"
    
    if(-not(Test-Path $profile -PathType Leaf)) {
        Write-Output "Creating Profile"
        New-Item $profile
    }
    if ($null -eq (Select-String -Path $profile -Pattern "oh-my-posh"))
    {
        Get-Content $env:USERPROFILE/dots/profile.ps1 >> $profile
    }
    
} else {
    Write-Output "User profile/dots directory does not exist"
    gh repo clone $dots_repo $env:USERPROFILE/dots
    if(-not(Test-Path $profile -PathType Leaf)) {
        New-Item $profile
    }
    if ($null -eq (Select-String -Path $profile -Pattern "oh-my-posh"))
    {
        Get-Content $env:USERPROFILE/dots/profile.ps1 >> $profile
    }
}

# Install WSL
Write-Output "Installing WSL"
if($ComputerType -eq "dev-laptop" -or $ComputerType -eq "dev-desktop") {
    wsl.exe --update
    wsl.exe --install -d ubuntu --no-launch
}

# Install Features
Write-Output "Installing Features"
if($ComputerType -eq "dev-desktop") {
    Write-Output "Installing Hyper-V"
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart
    Write-Output "Installing HypervisorPlatform"
    Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -NoRestart
}

# Set computer to dark mode
# New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force; New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force
# Stop-Process -Name "explorer"
# Start-Process -FilePath "explorer.exe"

# Change theme based on computer type
if($ComputerType -eq "dev-desktop" -or $ComputerType -eq "desktop") {
    Write-Output "Changing theme"
    Start-Process -FilePath "C:\Windows\Resources\Themes\themeB.theme"
    Start-Sleep 2
    Stop-Process -Name "systemsettings"
}

if($ComputerType -eq "dev-laptop" -or $ComputerType -eq "laptop") {
    Write-Output "Changing theme"
    Start-Process -FilePath "C:\Windows\Resources\Themes\dark.theme"
    Start-Sleep 2
    Stop-Process -Name "systemsettings"
}

# Reboot the computer
Write-Output "Rebooting the computer"
Restart-Computer -Force

