#!/usr/bin/env bash

echo " "
echo "---------------------"
echo "Atualizando sistema..."

sudo pacman -Suy

echo " "
echo "---------------------"
echo "Instalando os apps..."
sudo pacman -S --needed \
  fastfetch \
  git \
  base-devel \
  curl \
  wget \
  nano \
  vim \
  networkmanager \
  zsh \
  zip \
  unzip \
  ffmpeg \
  ntfs-3g \
  docker \
  docker-compose \
  kdenlive \
  audacity \
  hplip \
  print-manager \
  system-config-printer \
#  kdeconnect \
  ffmpegthumbs \
  steam \
  bitwarden \
  dosfstools \
  gnome-builder
  
  
  
echo " "
echo "-----------------"
echo "Instalando Paru..."
cd ~ && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si

echo " "
echo "----------------------"
echo "Instalando apps YAY..."
paru -S --needed --noconfirm \
    google-chrome \
    webapp-manager \
    youtube-music-bin \
    visual-studio-code-bin
    
echo " "
echo "----------------------------------------"
echo "Instalando oh-my-zsh..." 
cd ~
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
