# VPS

## Add User

```
sudo adduser username
sudo usermod -aG sudo username
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

## Firewall

Edit `/etc/default/ufw` to disable ipv6

```
IPV6=no
```

```
sudo systemctl start ufw
sudo systemctl enable ufw
```

Set defaults

```
sudo ufw default allow outgoing
sudo ufw default deny incoming
```

Allow services

```
# change to ssh port
sudo ufw allow 2222
sudo ufw allow http
sudo ufw allow https
```

# Fail2Ban

```
sudo systemctl enable fail2ban.service
```

`/etc/fail2ban/jail.local`

```
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
findtime = 300
bantime = 3600
ignoreip = 127.0.0.1
```
