#!/bin/bash

# log errors
exec > >(tee -i $HOME/dotfiles_install.log)
exec 2>&1
set -x

# install packages
PACKAGES_NEEDED="\
    silversearcher-ag \
    bat \
    fuse \
    dialog \
    apt-utils \
    libfuse2"

echo "installing packages..."
if ! dpkg -s ${PACKAGES_NEEDED} > /dev/null 2>&1; then
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        sudo apt-get update
    fi
    sudo apt-get -y -q install ${PACKAGES_NEEDED}
fi
echo "finished installing packages\ninstalling neovim..."

# install latest neovim
sudo modprobe fuse
sudo groupadd fuse
sudo usermod -a -G fuse "$(whoami)"
#wget https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
wget https://github.com/github/copilot.vim/releases/download/neovim-nightlies/appimage.zip
unzip appimage.zip
sudo chmod u+x nvim.appimage
sudo mv nvim.appimage /usr/local/bin/nvim

echo "finished installing neovim\ninstalling oh my zsh..."
# install oh my zsh
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
echo "finished installing oh my zsh\nreplacing default config files..."

rm -f $HOME/.zshrc
ln -s $(pwd)/zshrc $HOME/.zshrc
ln -s $(pwd)/bash_profile $HOME/.bash_profile

rm -rf $HOME/.config
mkdir $HOME/.config
ln -s "$(pwd)/config/nvim" "$HOME/.config/nvim"

echo "finished replacing default config files\ninstalling vim plugins..."
nvim +'PackerInstall' +qa

echo "done!"

sudo chsh -s "$(which zsh)" "$(whoami)"
