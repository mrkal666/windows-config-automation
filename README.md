# Windows Automation Stuff
## Usage
Change the `ComputerType` parameter to `dev-laptop`, `laptop`, `dev-desktop` or `desktop` depending on the computer you are running the script on.
### 1. Open Windows store before running script
### 2. Run the script
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/mrkal666/windows-config-automation/main/install.ps1" -OutFile $ENV:temp\install.ps1; .$ENV:temp\install.ps1 -ComputerType 'dev-laptop'
```
### 3. Done

## Notes
This script is made for me personally, but you can use it if you want.
