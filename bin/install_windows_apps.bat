# Launch as admin

# Install Chocolatey
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
# Enable confirmation
choco feature enable -n allowGlobalConfirmation

# Install apps
choco install winrar -y
choco install googlechrome -y
choco install vlc -y
choco install putty.install -y
choco install vscode -y
choco install cmder -y
choco install teracopy -y

# Utils
choco install dropbox -y
choco install 1password4 -y

# Windows subsytem
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart