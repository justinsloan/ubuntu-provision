#!/bin/bash
# +------------------------------------------------------------------------+
# | This provisioning script is specifically designed to work with BASH    |
# | on Ubuntu 25.04, although it may work equally well under any           |
# | Debian-based dristribution.                                            |
# +------------------------------------------------------------------------+
# | This is free and unencumbered software released into the public domain.|
# |                                                                        |
# | Anyone is free to copy, modify, publish, use, compile, sell, or        |
# | distribute this software, either in source code form or as a compiled  |
# | binary, for any purpose, commercial or non-commercial, and by any      |
# | means.                                                                 |
# |                                                                        |
# | In jurisdictions that recognize copyright laws, the author or authors  |
# | of this software dedicate any and all copyright interest in the        |
# | software to the public domain. We make this dedication for the benefit |
# | of the public at large and to the detriment of our heirs and           |
# | successors. We intend this dedication to be an overt act of            |
# | relinquishment in perpetuity of all present and future rights to this  |
# | software under copyright law.                                          |
# |                                                                        |
# | THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        |
# | EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     |
# | MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. |
# | IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR      |
# | OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,  |
# | ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR  |
# | OTHER DEALINGS IN THE SOFTWARE.                                        |
# +------------------------------------------------------------------------+

# Superuser permission required.
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "==> Starting provisioning."

# Check for curl
if exists curl; then 
    echo "==> curl already installed"
else
    sudo apt -y install curl
fi

# Remove Unneeded Snap Packages
sudo snap remove firefox

# Install Additional Repositories
## Microsoft Edge
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge.list'
rm microsoft.gpg

## Microsoft Debian Bulls Eye
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-bookworm-prod bookworm main" > /etc/apt/sources.list.d/microsoft.list'

## Tailscale
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

# Update the System
sudo apt update 
sudo apt -y upgrade
sudo apt -y autoremove

# Install Snap Packages
sudo snap install multipass
sudo snap install wormhole

# Install Apt Packages
sudo apt -y install cabextract
sudo apt -y install net-tools
sudo apt -y install tmux
sudo apt -y install htop 
sudo apt -y install ncdu
sudo apt -y install sc
sudo apt -y install git 
sudo apt -y install gnupg
sudo apt -y install barrier
sudo apt -y install curtail
sudo apt -y install termius-app
sudo apt -y install bind9-dnsutils
sudo apt -y install gnome-sushi
sudo apt -y install gnome-tweaks
#sudo apt -y install gnome-weather
sudo apt -y install python3-pip 
sudo apt -y install twine 
sudo apt -y install nmap
sudo apt -y install remmina
sudo apt -y install inetutils-traceroute
sudo apt -y install traceroute
sudo apt -y install bat
sudo apt -y install imagemagick 
#sudo apt -y install nautilus-image-converter
#sudo apt -y install gnome-tweaks 
sudo apt -y install microsoft-edge-stable
sudo apt -y install fzf
sudo apt -y install figlet
sudo apt -y install flameshot
sudo apt -y install autokey-gtk
sudo apt -y install glances
sudo apt -y install heif-gdk-pixbuf
sudo apt -y install virtualbox
sudo apt -y install virtualbox-guest-additions-iso
sudo apt -y install clamav
sudo apt -y install dict
sudo apt -y install xfce4-dict
sudo apt -y install rclone
sudo apt -y install docker.io
sudo apt -y install docker-compose
sudo apt -y install sshfs
sudo apt -y install lazygit

# Install Python Packages
sudo apt -y install python3-venv

# Install the Micro editor
curl https://getmic.ro | sh
sudo mv micro /usr/bin
micro -plugin install filemanager fzf wc editorconfig runit cheat detectindent manipulator aspell jump

# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh
ollama pull nomic-embed-text
ollama pull gemma3:1b
echo 'Environment="HSA_OVERRIDE_GFX_VERSION=11.0.0"' | sudo tee /etc/systemd/system/ollama.service.d/override.conf
sudo systemctl daemon-reload

# Install Microsoft Fonts
sudo -u $SUDO_USER mkdir /home/$SUDO_USER/.fonts 
sudo -u $SUDO_USER curl https://raw.githubusercontent.com/justinsloan/ubuntu-provision/main/fonts.sh | sudo -u $SUDO_USER bash
wget http://ftp.de.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.6_all.deb -P ~/Downloads
sudo apt -y install ~/Downloads/ttf-mscorefonts-installer_3.6_all.deb
rm ~/Downloads/ttf-mscorefonts-installer_3.6_all.deb

# Set permissions for Flameshot
flatpak permission-set screenshot screenshot org.flameshot.Flameshot yes

# Config Git
git config --global user.name  $SUDO_USER
git config --global user.email "my@private.email"

# Add user Home to PATH
PATHA='export PATH=$PATH'
PATHB="/home/$SUDO_USER/.local/bin"
echo " " >> /home/$SUDO_USER/.bashrc
echo "$PATHA:$PATHB" >> /home/$SUDO_USER/.bashrc

# Create some handy bash aliases
echo "alias myip='curl --silent checkip.amazonaws.com | figlet'" >> /home/$SUDO_USER/.bash_aliases
echo "alias mycity='curl --silent ipinfo.io/city | figlet'" >> /home/$SUDO_USER/.bash_aliases
echo "alias myregion='curl --silent ipinfo.io/region | figlet'" >> /home/$SUDO_USER/.bash_aliases
echo "alias myisp='curl --silent ipinfo.io/org'" >> /home/$SUDO_USER/.bash_aliases
echo "alias update='sudo nala update && sudo nala upgrade -y && sudo nala autoremove -y'" >> /home/$SUDO_USER/.bash_aliases
echo "alias whichupdates='sudo nala update && nala list --upgradeable'" >> /home/$SUDO_USER/.bash_aliases
echo "alias calc='bc -l'" >> /home/$SUDO_USER/.bash_aliases
echo "alias size='pwd && find ./ -type f -exec du -Sh {} + | sort -rh | head -n 15'" >> /home/$SUDO_USER/.bash_aliases
echo "alias storage='ncdu'" >> /home/$SUDO_USER/.bash_aliases
echo "alias untar='tar -zxvf '" >> /home/$SUDO_USER/.bash_aliases
echo "alias ports='sudo netstat -tulanp'" >> /home/$SUDO_USER/.bash_aliases
echo "alias clearall='clear && history -c && history -w'" >> /home/$SUDO_USER/.bash_aliases
echo "alias gs='git pull && git push'" >> /home/$SUDO_USER/.bash_aliases
echo "alias ..='cd ..'" >> /home/$SUDO_USER/.bash_aliases
echo "alias ~='cd ~/'" >> /home/$SUDO_USER/.bash_aliases
echo "alias flush-dns='resolvectl flush-caches'" >> /home/$SUDO_USER/.bash_aliases
echo "alias showdns='resolvectl status | grep '\''DNS Server'\'' -A2'" >> /home/$SUDO_USER/.bash_aliases
echo "alias fstop='ps aux | fzf'" >> /home/$SUDO_USER/.bash_aliases
echo "alias showtime='date +%T | figlet'" >> /home/$SUDO_USER/.bash_aliases
echo "alias history='history | fzf'" >> /home/$SUDO_USER/.bash_aliases
echo "alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0'" >> /home/$SUDO_USER/.bash_aliases
echo "alias dict='dict -d wn'" >> /home/$SUDO_USER/.bash_aliases
echo "alias gpumon='amd-smi monitor -g 0 -p -u -t'" >> /home/$SUDO_USER/.bash_aliases
echo "alias cat='batcat'" >> /home/$SUDO_USER/.bash_aliases
echo "alias sheet='sc'" >> /home/$SUDO_USER/.bash_aliases
echo "alias ta='tmux attach -t'" >> /home/$SUDO_USER/.bash_aliases
echo "alias wr='wormhole receive'" >> /home/$SUDO_USER/.bash_aliases
echo "alias ws='wormhole send'" >> /home/$SUDO_USER/.bash_aliases

# Reload the .bashrc file
source /home/$SUDO_USER/.bashrc

# Create a certificate for Barrier
mkdir -p /home/$SUDO_USER/.local/share/barrier/SSL/
openssl req -x509 -nodes -days 365 -subj /CN=Barrier -newkey rsa:2048 -keyout /home/$SUDO_USER/.local/share/barrier/SSL/Barrier.pem -out /home/$SUDO_USER/.local/share/barrier/SSL/Barrier.pem

echo "==> Provisioning of this system is complete."

exit 0
