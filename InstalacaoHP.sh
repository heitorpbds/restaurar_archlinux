cat << 'EOF' > setup_arch_postinstall.sh
#!/usr/bin/env bash
set -euo pipefail

# Endereço IP padrão da HP Smart Tank 510 na rede local
PRINTER_IP="${1:-192.168.5.234}"

echo "========================================================="
echo "   [1/6] Atualização da Base e Pacotes Essenciais"
echo "========================================================="
sudo pacman -Syu --needed --noconfirm \
    base-devel git dkms linux-headers pciutils nvidia-prime \
    cups hplip python-pyqt5 system-config-printer sane simple-scan \
    avahi nss-mdns firewalld

echo "========================================================="
echo "   [2/6] Garantindo o paru (AUR Helper)"
echo "========================================================="
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

echo "========================================================="
echo "   [3/6] Driver NVIDIA 550xx (Pascal / GTX 1050 Ti)"
echo "========================================================="
# Remove pacotes open ou 6xx incompatíveis e caches problemáticos
sudo pacman -Rdd --noconfirm nvidia-open-dkms nvidia-dkms nvidia-utils lib32-nvidia-utils egl-gbm 2>/dev/null || true
rm -rf ~/.cache/paru/clone/nvidia-550xx-dkms ~/.cache/paru/clone/lib32-nvidia-550xx-utils 2>/dev/null || true

# Instalação dos pacotes fechados da branch 550xx
paru -S --needed --noconfirm nvidia-550xx-dkms nvidia-550xx-utils lib32-nvidia-550xx-utils

# Modprobe: Blacklist Nouveau, Early KMS e Gerenciamento Dinâmico de Energia (RTD3)
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

# Serviços systemd para suspensão correta no laptop
sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-hibernate.service
sudo systemctl enable nvidia-resume.service

# Atualiza initramfs
sudo mkinitcpio -P

echo "========================================================="
echo "   [4/6] Resolução de Rede Local e Serviços (mDNS/CUPS)"
echo "========================================================="
# Configura resolução .local no nsswitch se não estiver presente
if ! grep -q "mdns_minimal" /etc/nsswitch.conf; then
    sudo sed -i 's/^hosts:.*/hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns/' /etc/nsswitch.conf
fi

sudo systemctl enable --now cups.service
sudo systemctl enable --now avahi-daemon.service
sudo systemctl enable --now firewalld.service

echo "========================================================="
echo "   [5/6] Regras Persistentes no firewalld"
echo "========================================================="
sudo firewall-cmd --permanent --add-service=ipp || true
sudo firewall-cmd --permanent --add-service=ipp-client || true
sudo firewall-cmd --permanent --add-service=mdns || true
sudo firewall-cmd --permanent --add-service=slp || true
sudo firewall-cmd --permanent --add-port=9100/tcp || true
sudo firewall-cmd --reload

echo "========================================================="
echo "   [6/6] Configuração da Fila de Impressão HP"
echo "========================================================="
echo "Registrando dispositivo no IP: ${PRINTER_IP}..."
hp-setup -i "${PRINTER_IP}"

# Define como impressora padrão se encontrada
PRINTER_NAME=$(lpstat -p 2>/dev/null | awk '{print $2}' | grep -i "smart_tank" | head -n 1 || true)
if [[ -n "${PRINTER_NAME}" ]]; then
    lpoptions -d "${PRINTER_NAME}"
    echo "Fila padrão definida para: ${PRINTER_NAME}"
fi

echo ""
echo "========================================================="
echo " Configuração geral finalizada!"
echo " Para aplicar as alterações de kernel e barramento PCI:"
echo "   sudo reboot"
echo "========================================================="
EOF

chmod +x setup_arch_postinstall.sh