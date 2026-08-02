# homelab

Reproducible config for my Home Lab VPS/Setup. Git lives on my local machine only 
and the server never authenticates to GitHub. Instead, this whole folder is 
mirrored to the server over Syncthing, privately, through Tailscale.

## Setup order

### 1. User
Log into the server either using an already set user or as root and create a specific user for deployment. To make this setup, we first change into the root. At last, we change the password.

```bash
sudo -i
useradd -m -s /bin/bash -G sudo deploy
passwd deploy
```

After this, we can connect to our deployment user and continue from there.

### 2. Setup 
Install basic stuff that are needed for this homelab.

```bash
cd ~
git clone https://github.com/arazthexd/homelab.git
cd homelab
sudo bash scripts/setup.sh
```

This will install Docker, TailScale, and Syncthing. It also sets up the firewall.