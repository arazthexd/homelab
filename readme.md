# homelab

Reproducible config for my Home Lab VPS/Setup. Git lives on my local machine only 
and the server never authenticates to GitHub. Instead, this whole folder is 
mirrored to the server over Syncthing, privately, through Tailscale.

## Included


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

### 3. Tailscale
We run tailscale and connect it to an account. We first run the following:
```bash
sudo tailscale up
```

which returns a link. Wherever we are signed into our tailscale account, we can go to that link and
connect the machine to our account. We will then need the IP of the tailscale instance on the machine
which can be gotten like this:
```bash
tailscale ip -4
```

Additionally, we should allow tailscale on firewall.
```bash
sudo ufw allow in on tailscale0
sudo ufw reload
```

Also, we will need to have tailscale installed and logged into on any device that we want to request
connecting to the VPS, etc. which can downloaded from [here](https://tailscale.com/download).

### 4. Syncthing
We want to be able to connect to syncthing so that we can sync several important folders on the
homelab server with our other devices. After installing syncthing on our other devices (check [here](https://syncthing.net/downloads)), we can continue with this step.

By default, syncthing works on port 8384. It can be accessed on each device on `http://localhost:8384`, but we
will need to set it up with tailscale to be accessible from our other devices. To do that:
```bash
sudo systemctl edit syncthing@deploy.service
```
We paste this in the editor that opens, save, exit:
```
[Service]
Environment=STGUIADDRESS=0.0.0.0:8384
```
Then:
```bash
sudo systemctl restart syncthing@deploy.service
```

NOTE: This is a *host* service (not a container), so the `ufw allow in on tailscale0` rule from step 3 genuinely restricts it to the tailnet — unlike Docker-published ports (see next steps), plain host services are fully governed by ufw.

To make sure this works, we should go to `http://<vps-tailscale-ip>:8384` on our other devices with tailscale and see if we can reach syncthing. Suggestions before moving to the next steps:
1. Connect to other devices (pairing)
2. Set username and password for the GUI.