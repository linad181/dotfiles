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

echo -en '\n\n'
echo "Installing additional programs..."
sudo apt -y install neofetch apt-clone curl
echo -en '\n\n'

addCockpit () {
    echo -en '\n\n'
    echo "Installing cockpit with 45Drives Navigator add-on..."
    sudo apt -y install cockpit

    echo -en '\n\n'
    echo "Installing 45Drives Navigator plugin for Cockpit..."
    curl -sSL https://repo.45drives.com/setup -o setup-repo.sh
    sudo bash setup-repo.sh
    sudo apt update && sudo apt install cockpit-navigator -y

    echo -en '\n\n'
    read -n1 -p "Do you want to add Docker support to Cockpit? [Y/n]" doit 
    case $doit in  
      n|N) echo -en '\n\n' ;; 
      *) addDocker ;; 
    esac
}

addDocker () {
    echo "Installing Docker extension to Cockpit..."
    wget https://github.com/mrevjd/cockpit-docker/releases/download/v2.0.3/cockpit-docker.tar.gz
    sudo mv cockpit-docker.tar.gz /usr/share/cockpit
    sudo tar xf /usr/share/cockpit/cockpit-docker.tar.gz -C /usr/share/cockpit/
    sudo rm /usr/share/cockpit/cockpit-docker.tar.gz
    echo -en '\n\n'
}

if [ "$(dpkg -l | awk '/cockpit/ {print }' | wc -l)" -ge 1 ]; then
    echo "Cockpit installed"
    echo -en '\n\n'
else
    read -n1 -p "Do you want to add Cockpit to this server? [Y/n]" doit
    case $doit in
      n|N) echo -en '\n\n' ;;
      *) addCockpit ;; 
    esac
fi

echo "Installing SSH keys..."
if [ ! -d ~/.ssh ]; then 
    mkdir ~/.ssh
fi
curl https://github.com/linad181.keys -o ~/.ssh/authorized_keys
echo -en '\n\n'

echo "Install finished."
