# VPS Ubuntu 24.04

## Add User

```
adduser <username>
usermod -aG sudo <username>
```

## Copy over SSH Keys to new user

```
ssh-copy-id -i ~/.ssh/id_ed25519.pub <username>@<your_server_ip>
```


If copying from an existing server

```
rsync --archive --chown=<username>:<username> ~/.ssh /home/<username>
```

## Set Hostname

Edit `/etc/cloud/cloud.cfg`

```
preserve_hostname: true
```

```
hostnamectl set-hostname <hostname>
echo "hostname" > /etc/hostname
```

## Set Timezone

```
dpkg-reconfigure tzdata
```

## SSH Setup

# Edit /etc/ssh/sshd_config

```
#Disable root logins over SSH
PermitRootLogin no

# Enforce login using SSH keys only
PasswordAuthentication no

# Change Port
Port 2222

# Only listen on IPv4
AddressFamily inet
```

`sudo service ssh restart`

## Firewall

Edit `/etc/default/ufw` to enable ipv6

```
IPV6=yes
```

```
# Default rules
sudo ufw default allow outgoing
sudo ufw default deny incoming

# App specific rules
sudo ufw deny openssh
sudo ufw allow 2222
sudo ufw allow http
sudo ufw allow https

#To further protect from brut force attacks you can rate limit specific ports with:
sudo ufw limit ssh

#finaly to enable logging and adjusting the log level:
sudo ufw logging on
sudo ufw logging medium # levels are low, medium, high, full
```

```
sudo ufw enable
sudo ufw status
```

# Fail2Ban

`/etc/fail2ban/jail.local`

```
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
findtime = 10m
bantime = 10m
ignoreip = 127.0.0.1
```

```
sudo systemctl enable fail2ban.service
```
