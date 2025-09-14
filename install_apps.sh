#!/usr/bin/env bash

echo " "
echo "---------------------"
echo "Atualizando sistema..."

useradd -m -G wheel heitorpbds
passwd heitorpbds

pacman -Suy

hostnamectl hostname arch-acer
timedatectl set-timezone America/Sao_Paulo

timedatectl set-ntp TRUE
echo LANG="en_US.UTF-8" >> /etc/locale.conf
localectl set-keymap us

pacman -S reflector sudo vim
reflector -c Brazil -a 6 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Suy


echo " "
echo "---------------------"
echo "Instalando os apps..."
pacman -S --needed \
  xdg-user-dirs \
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
  gnome-builder \
  linux-headers \ 
  gnome-shell \
  gnome-terminal \
  gnome-control-center \
  gnome-tweaks \
  gnome-backgrounds \
  nautilus \
  gdm \
  nvidia \
  nvidia-prime \
  xorg-xrandr \
  libreoffice-fresh

  
  
echo " "
echo "-----------------"
echo "Instalando Paru..."
cd ~ && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si

echo " "
echo "----------------------"
echo "Instalando apps paru..."
paru -S --needed --noconfirm \
    google-chrome \
    webapp-manager \
    youtube-music-bin \
    visual-studio-code-bin \
    extension-manager
    
echo " "
echo "----------------------------------------"
echo "Instalando oh-my-zsh..." 
cd ~
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


echo "Iniciar o Gnome"
su heitorpbds
sudo  systemctl enable --now gdm