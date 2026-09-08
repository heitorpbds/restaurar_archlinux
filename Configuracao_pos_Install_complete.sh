cat << 'EOF' > arch_postinstall_complete.sh
#!/usr/bin/env bash
set -euo pipefail

# Variáveis do ambiente
PRINTER_IP="${1:-192.168.5.234}"
USER_NAME="${SUDO_USER:-$USER}"
USER_UID=$(id -u "$USER_NAME")
USER_GID=$(id -g "$USER_NAME")
USER_HOME=$(eval echo "~$USER_NAME")

# UUID da partição NTFS de jogos/arquivos (/dev/sda5)
NTFS_UUID="CE7CB28A7CB26CB9"
NTFS_MOUNT="/mnt/arquivos-games"

echo "=========================================================="
echo " [1/7] Atualização da Base e Ferramentas Essenciais"
echo "=========================================================="
sudo pacman -Syu --needed --noconfirm \
    base-devel git dkms linux-headers pciutils \
    cups hplip python-pyqt5 system-config-printer sane simple-scan \
    avahi nss-mdns firewalld ntfs-3g ntfsprogs \
    docker gnome-shell-extension-appindicator

echo "=========================================================="
echo " [2/7] Garantindo o paru (AUR Helper)"
echo "=========================================================="
if ! command -v paru &> /dev/null; then
    TEMP_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/paru.git "$TEMP_DIR/paru"
    pushd "$TEMP_DIR/paru" > /dev/null
    makepkg -si --noconfirm
    popd > /dev/null
    rm -rf "$TEMP_DIR"
else
    echo "paru já instalado."
fi

echo "=========================================================="
echo " [3/7] Driver NVIDIA 550xx (Pascal / GTX 1050 Ti)"
echo "=========================================================="
# Limpeza de pacotes incompatíveis e cache corrompido
sudo pacman -Rdd --noconfirm nvidia-open-dkms nvidia-dkms nvidia-utils lib32-nvidia-utils egl-gbm 2>/dev/null || true
rm -rf "$USER_HOME/.cache/paru/clone/nvidia-550xx-dkms" "$USER_HOME/.cache/paru/clone/lib32-nvidia-550xx-utils" 2>/dev/null || true

# Instalação dos drivers da branch 550xx
paru -S --needed --noconfirm nvidia-550xx-dkms nvidia-550xx-utils lib32-nvidia-550xx-utils nvidia-prime

# Parâmetros de modprobe (KMS, Dynamic Power Management, Blacklist Nouveau)
sudo tee /etc/modprobe.d/blacklist-nouveau.conf > /dev/null << 'CONFIG'
blacklist nouveau
options nouveau modeset=0
CONFIG

sudo tee /etc/modprobe.d/nvidia.conf > /dev/null << 'CONFIG'
options nvidia_drm modeset=1 fbdev=1
CONFIG

sudo tee /etc/modprobe.d/nvidia-power.conf > /dev/null << 'CONFIG'
options nvidia "NVreg_DynamicPowerManagement=0x02"
CONFIG

# Serviços systemd de gerenciamento de energia NVIDIA
sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-hibernate.service
sudo systemctl enable nvidia-resume.service

# Atualização dos initramfs
sudo mkinitcpio -P

echo "=========================================================="
echo " [4/7] Rede Local, Impressão HP e Firewall"
echo "=========================================================="
# Habilitar mDNS no nsswitch.conf se ausente
if ! grep -q "mdns_minimal" /etc/nsswitch.conf; then
    sudo sed -i 's/^hosts:.*/hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns/' /etc/nsswitch.conf
fi

sudo systemctl enable --now cups.service
sudo systemctl enable --now avahi-daemon.service
sudo systemctl enable --now firewalld.service

# Abertura de portas para CUPS/HPLIP e mDNS
sudo firewall-cmd --permanent --add-service=ipp || true
sudo firewall-cmd --permanent --add-service=ipp-client || true
sudo firewall-cmd --permanent --add-service=mdns || true
sudo firewall-cmd --permanent --add-service=slp || true
sudo firewall-cmd --permanent --add-port=9100/tcp || true
sudo firewall-cmd --reload

# Adição da fila de impressão HP
if ping -c 1 -W 1 "${PRINTER_IP}" &> /dev/null; then
    echo "Registrando impressora HP no IP: ${PRINTER_IP}..."
    hp-setup -i "${PRINTER_IP}" || true
    PRINTER_NAME=$(lpstat -p 2>/dev/null | awk '{print $2}' | grep -i "smart_tank" | head -n 1 || true)
    if [[ -n "${PRINTER_NAME}" ]]; then
        lpoptions -d "${PRINTER_NAME}"
        echo "Fila padrão definida para: ${PRINTER_NAME}"
    fi
else
    echo "Impressora não respondeu no IP ${PRINTER_IP}. Pule para rodar 'hp-setup -i <IP>' depois."
fi

echo "=========================================================="
echo " [5/7] Configuração Btrfs: Subvolume Isolado para o Docker"
echo "=========================================================="
sudo systemctl stop docker.socket docker.service 2>/dev/null || true

# Identifica partição raiz e UUID
ROOT_SOURCE=$(findmnt -n -o SOURCE /)
BTRFS_DEV=$(echo "$ROOT_SOURCE" | sed 's/\[.*\]//')
BTRFS_UUID=$(sudo blkid -s UUID -o value "$BTRFS_DEV")

# Criação do subvolume @docker se não existir
sudo mkdir -p /mnt/btrfs-top
sudo mount -o subvolid=5 "$BTRFS_DEV" /mnt/btrfs-top
if ! sudo btrfs subvolume list /mnt/btrfs-top | grep -q '@docker'; then
    sudo btrfs subvolume create /mnt/btrfs-top/@docker
    echo "Subvolume @docker criado."
else
    echo "Subvolume @docker já existe."
fi
sudo umount /mnt/btrfs-top
sudo rmdir /mnt/btrfs-top

# Configuração no /etc/fstab
sudo mkdir -p /var/lib/docker
if ! grep -q "/var/lib/docker" /etc/fstab; then
    echo "UUID=${BTRFS_UUID} /var/lib/docker btrfs subvol=@docker,noatime,compress=zstd,discard=async 0 0" | sudo tee -a /etc/fstab
fi

sudo systemctl daemon-reload
sudo mount -a

# Configuração do daemon do Docker para usar driver nativo btrfs
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null << 'EOF_DOCKER'
{
  "storage-driver": "btrfs",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF_DOCKER

# Permissões de grupo docker sem sudo
sudo usermod -aG docker "$USER_NAME"
sudo systemctl enable --now docker.service

echo "=========================================================="
echo " [6/7] Montagem Automática do Disco NTFS e Visibilidade"
echo "=========================================================="
sudo mkdir -p "$NTFS_MOUNT"

# Limpa dirty journal da partição NTFS
sudo ntfsfix -d "/dev/disk/by-uuid/${NTFS_UUID}" 2>/dev/null || sudo ntfsfix -d /dev/sda5 2>/dev/null || true

# Remove entrada antiga no fstab caso exista e adiciona a completa com x-gvfs-show
sudo sed -i "\|${NTFS_UUID}|d" /etc/fstab
echo "UUID=${NTFS_UUID} ${NTFS_MOUNT} ntfs-3g defaults,x-gvfs-show,x-gvfs-name=Arquivos-Games,noatime,uid=${USER_UID},gid=${USER_GID},umask=022,nofail 0 0" | sudo tee -a /etc/fstab

sudo systemctl daemon-reload
sudo mount -a || sudo mount -o remount "$NTFS_MOUNT" || true

echo "=========================================================="
echo " [7/7] Ajustes do GNOME e Nautilus"
echo "=========================================================="
# Bookmark no Nautilus/GTK
mkdir -p "$USER_HOME/.config/gtk-3.0"
if ! grep -q "${NTFS_MOUNT}" "$USER_HOME/.config/gtk-3.0/bookmarks" 2>/dev/null; then
    echo "file://${NTFS_MOUNT} Arquivos-Games" >> "$USER_HOME/.config/gtk-3.0/bookmarks"
    chown "$USER_NAME:$USER_NAME" "$USER_HOME/.config/gtk-3.0/bookmarks"
fi

# Notifica o Nautilus
nautilus -q 2>/dev/null || true

echo ""
echo "=========================================================="
echo " Sistema pós-instalação configurado com sucesso!"
echo " Para carregar todos os módulos do kernel e o grupo docker:"
echo "   sudo reboot"
echo "=========================================================="
EOF

chmod +x arch_postinstall_complete.sh