# Prompt for UAC Permissions
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

function Check-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}
# Remove all text from the current display
Clear-Host

Write-Host "------------------------------------" -ForegroundColor Green
Write-Host "Computer Configurations" -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
# -----------------------------------------------------------------------------
$computerName = Read-Host 'Enter New Computer Name'
Write-Host "Renaming this computer to: " $computerName  -ForegroundColor Yellow
Rename-Computer -NewName $computerName
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Disable Sleep on AC Power..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Powercfg /Change monitor-timeout-ac 20
Powercfg /Change standby-timeout-ac 0
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Disable Windows Search" -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Set-Service Wsearch -StartupType Disabled
Stop-Service Wsearch
# -----------------------------------------------------------------------------

# Set network conection to private
# Get-NetConnectionProfile
# Prompt user for InterfaceIndex Number
# Set-NetConnectionProfile -InterfaceIndex 13 -NetworkCategory Private
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Add 'This PC' Desktop Icon..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
$thisPCIconRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
$thisPCRegValname = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
$item = Get-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -ErrorAction SilentlyContinue
if ($item) {
    Set-ItemProperty  -Path $thisPCIconRegPath -name $thisPCRegValname -Value 0
}
else {
    New-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -Value 0 -PropertyType DWORD | Out-Null
}
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Removing Edge Desktop Icon..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
$edgeLink = $env:USERPROFILE + "\Desktop\Microsoft Edge.lnk"
Remove-Item $edgeLink

# -----------------------------------------------------------------------------
# To list all appx packages:
# Get-AppxPackage | Format-Table -Property Name,Version,PackageFullName
# -----------------------------------------------------------------------------
Write-Host "Removing UWP Rubbish..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
$uwpRubbishApps = @(
    "Microsoft.Messaging",
    "king.com.CandyCrushSaga",
    "Microsoft.BingNews",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.People",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.YourPhone",
    "Microsoft.MicrosoftOfficeHub",
    "Fitbit.FitbitCoach",
    "4DF9E0F8.Netflix")

foreach ($uwpApp in $uwpRubbishApps) {
Write-Host ""
Write-Host "Uninstaslling ${uwpApp}..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
    Get-AppxPackage -Name $uwpApp | Remove-AppxPackage
}

# -----------------------------------------------------------------------------
# Uncomment to enable Remote Desktop
# -----------------------------------------------------------------------------
# Write-Host ""
# Write-Host "Enable Remote Desktop..." -ForegroundColor Green
# Write-Host "------------------------------------" -ForegroundColor Green
# Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name "fDenyTSConnections" -Value 0
# Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\" -Name "UserAuthentication" -Value 1
# Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# -----------------------------------------------------------------------------
# Choco Install Apps
# -----------------------------------------------------------------------------

if (Check-Command -cmdname 'choco') {
    Write-Host "Choco is already installed, skip installation."
}
else {
    Write-Host ""
    Write-Host "Installing Chocolate for Windows..." -ForegroundColor Green
    Write-Host "------------------------------------" -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco feature enable -n allowGlobalConfirmation
}

Write-Host ""
Write-Host "Installing Applications..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

$apps = @(
    # Common Apps
    "googlechrome",
    "7zip.install",
    "bulkrenameutility",
    "powertoys",
    "sumatrapdf.install",

    # Game
    "steam",
    "epicgameslauncher",
    "retroarch",
    "obs-studio",

    # Social
    "discord",
    "slack",

    # Dev
    "vscode",
    "terminus",
    "conemu",

    # Misc
    "spotify",

    # Fonts
    "cascadiacode",

)
foreach ($app in $apps) {
Write-Host ""
Write-Host "Installing ${app}..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
    choco install $app -y
}
Write-Host "------------------------------------" -ForegroundColor Green
Read-Host -Prompt "Setup is done, restart is needed, press [ENTER] to restart computer."
Restart-Computer
