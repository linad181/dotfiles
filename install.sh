#!/bin/bash

# Find all dot files then if the original file exists, create a backup
# Once backed up to {file}.dtbak symlink the new dotfile in place
for file in $(find . -maxdepth 1 -name ".*" -type f  -printf "%f\n" ); do
    if [ -e ~/$file ]; then
        mv -f ~/$file{,.dtbak}
    fi
    ln -s $PWD/$file ~/$file
done

# Check if vim-addon installed, if not, install it automatically
if hash vim-addon  2>/dev/null; then
    echo "vim-addon (vim-scripts)  installed"
else
    echo "vim-addon (vim-scripts) not installed, installing"
    sudo apt update && sudo apt -y install vim-scripts
fi

echo "Installing additional programs..."
sudo apt update && sudo apt -y install neofetch apt-clone curl cockpit

echo "Installing 45Drives Navigator plugin for Cockpit..."

curl -sSL https://repo.45drives.com/setup -o setup-repo.sh
bash setup-repo.sh
apt update && apt install cockpit-navigator -y

addDocker () {
    wget https://github.com/mrevjd/cockpit-docker/releases/download/v2.0.3/cockpit-docker.tar.gz
    sudo mv cockpit-docker.tar.gz /usr/share/cockpit
    sudo tar xf /usr/share/cockpit/cockpit-docker.tar.gz -C /usr/share/cockpit/
    sudo rm /usr/share/cockpit/cockpit-docker.tar.gz
}

read -n1 -p "Do you want to add Docker support to Cockpit? [Y,n]" doit 
case $doit in  
  y|Y) addDocker ;; 
  n|N) echo no ;; 
esac

echo "Installing SSH keys..."
mkdir ~/.ssh
curl https://github.com/linad181.keys -o ~/.ssh/authorized_keys

echo "Install finished."
