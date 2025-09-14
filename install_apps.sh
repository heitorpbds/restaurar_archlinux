#!/usr/bin/env bash

set -e # Para o script se houver erro

echo "---------------------"
echo "Atualizando sistema..."

# Cria usuário com senha pré-definida
useradd -m -G wheel heitorpbds
echo "heitorpbds:senha123" | chpasswd

pacman -Suy --noconfirm

hostnamectl hostname arch-acer
timedatectl set-timezone America/Sao_Paulo
timedatectl set-ntp true
echo LANG="en_US.UTF-8" >> /etc/locale.conf
localectl set-keymap us

pacman -S --noconfirm reflector sudo vim
reflector -c Brazil -a 6 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Suy --noconfirm

echo "---------------------"
echo "Instalando os apps..."
pacman -S --needed --noconfirm \
  xdg-user-dirs fastfetch git base-devel curl wget nano vim networkmanager \
  zsh zip unzip ffmpeg ntfs-3g docker docker-compose kdenlive audacity hplip \
  print-manager system-config-printer ffmpegthumbs steam bitwarden dosfstools \
  gnome-builder linux-headers gnome-shell gnome-terminal gnome-control-center \
  gnome-tweaks gnome-backgrounds nautilus gdm nvidia nvidia-prime xorg-xrandr \
  libreoffice-fresh

echo "-----------------"
echo "Instalando Paru..."
cd /tmp
git clone https://aur.archlinux.org/paru.git || exit 1
cd paru
makepkg -si --noconfirm || exit 1

echo "----------------------"
echo "Instalando apps paru..."
paru -S --needed --noconfirm \
    google-chrome webapp-manager youtube-music-bin visual-studio-code-bin \
    extension-manager zoom

echo "----------------------------------------"
echo "Instalando oh-my-zsh para heitorpbds..."
runuser -u heitorpbds -- sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s /bin/zsh heitorpbds

echo "Iniciar o Gnome"
systemctl enable --now gdm