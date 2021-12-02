# VPS Ubuntu 20.04

## Add User

```
adduser <username>
usermod -aG sudo <username>
```

## Copy over SSH Keys to new user

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
sudo ufw disable openssh
sudo ufw allow 2222
sudo ufw allow http
sudo ufw allow https

# 3000 TCP for initial Captain Installation (can be blocked once Captain is attached to a domain)
sudo ufw allow 3000/tcp
# 7946 TCP/UDP for Container Network Discovery
sudo ufw allow 7946/tcp
sudo ufw allow 7946/udp
# 4789 TCP/UDP for Container Overlay Network
sudo ufw allow 4789/tcp
sudo ufw allow 4789/udp
# 2377 TCP/UDP for Docker swarm API
sudo ufw allow 2377/tcp
sudo ufw allow 2377/udp
# 996 TCP for secure HTTPS connections specific to Docker Registry
sudo ufw allow 996/tcp
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
findtime = 300
bantime = 3600
ignoreip = 127.0.0.1
```

```
sudo systemctl enable fail2ban.service
```
