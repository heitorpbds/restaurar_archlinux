#!/usr/bin/env bash

# =============================================================================
# Script de Recuperação Rápida - Arch Linux
# Máquina de trabalho (Manjaro → Arch)
# =============================================================================

set -euo pipefail  # Para em erro, undefined vars, e pipe failures

LOG_FILE="/tmp/setup-arch.log"
USERNAME="heitorpbds"
HOSTNAME="arch-acer"
TIMEZONE="America/Sao_Paulo"
KEYBOARD="us"
LOCALE="en_US.UTF-8"

# =============================================================================
# Funções utilitárias
# =============================================================================

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

die() {
    log "ERRO CRÍTICO: $1"
    exit 1
}

check_nvidia() {
    log "Verificando hardware NVIDIA..."
    if lspci -k -d ::03xx | grep -i nvidia > /dev/null 2>&1; then
        log "Hardware NVIDIA detectado."
        return 0
    else
        log "Nenhum hardware NVIDIA detectado."
        return 1
    fi
}

get_nvidia_gpu_family() {
    # Retorna família da GPU para decidir driver (Turing+ usa nvidia-open)
    # Pascal e anteriores precisam de nvidia-580xx-dkms (AUR)
    local gpu_info
    gpu_info=$(lspci -k -d ::03xx | grep -i nvidia | head -1)
    
    # GPUs RTX 20xx (Turing), 30xx (Ampere), 40xx (Ada) suportam nvidia-open
    if echo "$gpu_info" | grep -qiE "rtx.*(20|30|40)|quadro.*(rtx|t4|a4|a10|a16|a40|a100)"; then
        echo "open"
    else
        echo "legacy"
    fi
}

# =============================================================================
# Configuração básica do sistema
# =============================================================================

update_system() {
    # Habilitar repositório multilib se estiver comentado
    sed -i "/\[multilib\]/{n;s/^#//g}; s/^#\[multilib\]/[multilib]/" /etc/pacman.conf
    pacman -Syy --needed --noconfirm || die "Falha ao atualizar banco de dados de pacotes"
    log "Atualizando banco de dados de pacotes e sistema..."
    pacman -Syu --needed --noconfirm || die "Falha ao atualizar sistema"
}

setup_system() {
    log "Configurando hostname, fuso horário e locale..."
    
    hostnamectl hostname "$HOSTNAME" || die "Falha ao configurar hostname"
    
    timedatectl set-timezone "$TIMEZONE" || die "Falha ao configurar fuso horário"
    timedatectl set-ntp true || die "Falha ao configurar NTP"
    
    log "Configurando locale..."
    sed -i "s/#${LOCALE}/${LOCALE}/" /etc/locale.gen
    locale-gen || die "Falha ao gerar locales"
    echo "LANG=${LOCALE}" > /etc/locale.conf
    
    localectl set-keymap "$KEYBOARD" || die "Falha ao configurar teclado"
}

create_user() {
    log "Criando usuário ${USERNAME}..."
    
    if id "${USERNAME}" &>/dev/null; then
        log "Usuário ${USERNAME} já existe."
    else
        useradd -m -G wheel,audio,video,optical,storage "${USERNAME}" || die "Falha ao criar usuário"
        log "Defina a senha para ${USERNAME}:"
        passwd "${USERNAME}" || die "Falha ao definir senha"
    fi
}

# =============================================================================
# Pacotes básicos e mirrors
# =============================================================================

install_base_packages() {
    log "Instalando pacotes básicos..."
    pacman -S --needed --noconfirm \
        reflector sudo vim base-devel git curl wget || die "Falha ao instalar pacotes básicos"
    
    log "Configurando mirrors com Reflector..."
    reflector -c Brazil -a 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist || \
        die "Falha ao configurar mirrors"
    
    update_system
}

# =============================================================================
# Drivers NVIDIA (CRÍTICO)
# =============================================================================

install_nvidia_drivers() {
    log "Verificando hardware NVIDIA..."
    if ! lspci -k -d ::03xx | grep -i nvidia > /dev/null 2>&1; then
        log "Nenhum hardware NVIDIA detectado. Pulando drivers NVIDIA."
        return 0
    fi
    
    log "Hardware NVIDIA detectado."
    
    # Detectar se é Pascal ou mais antigo (GTX 10xx, 9xx, etc.)
    local gpu_info
    gpu_info=$(lspci -nn -d ::03xx | grep -i nvidia)
    
    # GTX 1050 Ti = GP107 [10de:1c8c] - Pascal
    if echo "$gpu_info" | grep -qE "10de:1c8[0-9]|10de:1b8[0-9]|GTX.*(9|10)[0-9][0-9]|Pascal"; then
        log "⚠️  GPU Pascal detectada (GTX 9xx/10xx series)."
        log "⚠️  Drivers NVIDIA 590+ NÃO são compatíveis com esta GPU."
        log "⚠️  Instalando driver legacy 580xx do AUR..."
        
        # Headers primeiro (obrigatório para DKMS)
        log "Instalando linux-headers..."
        pacman -S --needed --noconfirm linux-headers || die "Falha ao instalar linux-headers"
        
        # Instalar driver legacy 580xx (último com suporte a Pascal)
        log "Instalando nvidia-580xx-dkms..."
        pacman -S --needed --noconfirm \
            nvidia-580xx-dkms \
            nvidia-580xx-utils \
            nvidia-580xx-settings \
            lib32-nvidia-580xx-utils || die "Falha ao instalar drivers NVIDIA 580xx"
        
        # Blacklist nouveau
        log "Blacklist do driver nouveau..."
        cat > /etc/modprobe.d/nvidia.conf <<'EOF'
blacklist nouveau
options nouveau modeset=0
EOF
        
        # Regenerar initramfs
        log "Regenerando initramfs..."
        mkinitcpio -P || die "Falha ao regenerar initramfs"
        
        log "✅  Drivers NVIDIA 580xx instalados com sucesso."
        log "NOTA: Esta é a última versão com suporte para GPUs Pascal."
        
    else
        # GPUs mais novas (Turing, Ampere, Ada, Blackwell)
        log "GPU moderna detectada. Instalando nvidia-open-dkms..."
        
        pacman -S --needed --noconfirm linux-headers || die "Falha ao instalar linux-headers"
        
        pacman -S --needed --noconfirm \
            nvidia-open-dkms \
            nvidia-utils \
            nvidia-settings \
            lib32-nvidia-utils || die "Falha ao instalar drivers NVIDIA"
        
        cat > /etc/modprobe.d/nvidia.conf <<'EOF'
blacklist nouveau
options nouveau modeset=0
EOF
        
        mkinitcpio -P || die "Falha ao regenerar initramfs"
        
        log "Drivers NVIDIA instalados com sucesso."
    fi
}

# =============================================================================
# Pacotes adicionais
# =============================================================================

install_additional_packages() {
    log "Instalando pacotes adicionais..."
    
    local packages=(
        xdg-user-dirs fastfetch base-devel curl wget nano vim networkmanager
        zip unzip ffmpeg ntfs-3g docker docker-compose hplip zsh
        print-manager system-config-printer ffmpegthumbs steam bitwarden dosfstools
        gnome-builder linux-headers gnome-control-center
        gnome-tweaks cups cups-pdf btop gparted
        xorg-xrandr xorg-server xorg-apps
    )
    
    pacman -S --needed --noconfirm "${packages[@]}" libreoffice-fresh || \
        die "Falha ao instalar pacotes adicionais"
    
    # Habilitar NetworkManager
    systemctl enable NetworkManager || die "Falha ao habilitar NetworkManager"
}

# =============================================================================
# Flatpak
# =============================================================================

setup_flatpak() {
    log "Instalando Flatpak..."
    pacman -S --needed --noconfirm flatpak || die "Falha ao instalar Flatpak"
    
    log "Adicionando repositório Flathub..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || \
        die "Falha ao adicionar Flathub"
    
    log "Instalando aplicativos Flatpak..."
    local flatpak_apps=(
        me.iepure.devtoolbox
        com.heroicgameslauncher.hgl
        md.obsidian.Obsidian
        de.haeckerfelix.Shortwave
    )
    flatpak install --system --or-update --assumeyes flathub "${flatpak_apps[@]}" || \
        log "Aviso: Falha ao instalar alguns aplicativos Flatpak"
}

# =============================================================================
# Paru (AUR helper)
# =============================================================================

configure_aur_sudo() {
    cat > /etc/sudoers.d/99-arch-setup-aur <<EOF
${USERNAME} ALL=(root) NOPASSWD: /usr/bin/pacman
EOF
    chmod 440 /etc/sudoers.d/99-arch-setup-aur
    visudo -cf /etc/sudoers.d/99-arch-setup-aur >/dev/null || \
        die "Falha ao validar permissões temporárias do Paru"
    trap cleanup_aur_sudo EXIT
}

install_paru() {
    log "Instalando Paru..."

    configure_aur_sudo
    
    if command -v paru &>/dev/null; then
        log "Paru já está instalado."
        return
    fi
    
    local user_uid
    local user_gid
    user_uid=$(id -u "${USERNAME}") || die "Usuário ${USERNAME} não existe"
    user_gid=$(id -g "${USERNAME}") || die "Não foi possível obter o grupo de ${USERNAME}"

    cd /tmp || die "Falha ao acessar /tmp"
    
    if [[ -d paru && -d paru/.git ]]; then
        log "Repositório Paru já existe. Atualizando..."
        chown -R "${user_uid}:${user_gid}" paru
        runuser -u "${USERNAME}" -- git -C paru pull || die "Falha ao atualizar Paru"
    else
        if [[ -e paru ]]; then
            log "Caminho /tmp/paru não é um clone válido. Removendo..."
            rm -rf paru
        fi
        log "Clonando repositório do Paru..."
        runuser -u "${USERNAME}" -- git clone https://aur.archlinux.org/paru.git || die "Falha ao clonar Paru"
    fi
    
    pacman -S --needed --noconfirm rust || die "Falha ao instalar dependência de compilação do Paru"

    log "Compilando e instalando Paru..."
    runuser -u "${USERNAME}" -- bash -c 'cd /tmp/paru && makepkg --noconfirm' || \
        die "Falha ao compilar Paru"
    pacman -U --noconfirm /tmp/paru/*.pkg.tar.* || die "Falha ao instalar pacote do Paru"

    cd /
}

# =============================================================================
# Pacotes AUR
# =============================================================================

install_aur_packages() {
    log "Instalando pacotes do AUR com Paru..."
    
    local aur_packages=(
        google-chrome webapp-manager youtube-music-bin visual-studio-code-bin
        extension-manager hplip-plugin brave-browser rustdesk-bin oversteer tilix
        sublime-text-4
    )
    
    # Instalação em lote (sem prompts individuais para automação)
    runuser -u "${USERNAME}" -- paru -S --needed --noconfirm "${aur_packages[@]}" || \
        log "Aviso: Falha ao instalar alguns pacotes AUR"
}

# =============================================================================
# Oh My Zsh
# =============================================================================

setup_oh_my_zsh() {
    log "Instalando Oh My Zsh para ${USERNAME}..."
    
    if [[ -d /home/${USERNAME}/.oh-my-zsh ]]; then
        log "Oh My Zsh já está instalado."
        return
    fi
    
    log "Baixando script de instalação..."
    if ! curl --http1.1 --connect-timeout 15 --max-time 120 \
        --retry 5 --retry-delay 5 --retry-all-errors -fsSL \
        https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh \
        -o /tmp/install-ohmyzsh.sh; then
        log "Falha no download direto. Tentando obter Oh My Zsh via Git..."
        rm -rf /tmp/ohmyzsh
        runuser -u "${USERNAME}" -- git clone --depth=1 \
            https://github.com/ohmyzsh/ohmyzsh.git /tmp/ohmyzsh || \
            die "Falha ao baixar Oh My Zsh"
        cp /tmp/ohmyzsh/tools/install.sh /tmp/install-ohmyzsh.sh
        chown "${USERNAME}:${USERNAME}" /tmp/install-ohmyzsh.sh
    fi
    
    log "Executando instalação..."
    runuser -u "${USERNAME}" -- sh /tmp/install-ohmyzsh.sh || die "Falha ao instalar Oh My Zsh"
    
    log "Configurando Zsh como shell padrão..."
    chsh -s /bin/zsh "${USERNAME}" || die "Falha ao configurar Zsh"
}

# =============================================================================
# mise (version manager)
# =============================================================================

install_mise() {
    log "Instalando mise..."
    
    if command -v mise &>/dev/null; then
        log "mise já está instalado."
        return
    fi
    
    pacman -S --needed --noconfirm mise || die "Falha ao instalar mise"
    
    local ZSHRC_PATH="/home/${USERNAME}/.zshrc"
    if ! grep -Fq 'eval "$(mise activate zsh)"' "$ZSHRC_PATH" 2>/dev/null; then
        runuser -u "${USERNAME}" -- tee -a "$ZSHRC_PATH" >/dev/null <<'EOF'

# Configuração do mise
eval "$(mise activate zsh)"
EOF
    fi
    
    log "mise instalado com sucesso."
}

# =============================================================================
# Ollama
# =============================================================================

install_ollama() {
    log "Instalando Ollama..."
    
    if command -v ollama &>/dev/null; then
        log "Ollama já está instalado."
        return
    fi
    
    # Método preferencial: usar pacote AUR (mais rastreável que curl | sh)
    if command -v paru &>/dev/null; then
        runuser -u "${USERNAME}" -- paru -S --needed --noconfirm ollama || {
            log "Falha ao instalar Ollama via AUR. Tentando método oficial..."
            curl -fsSL https://ollama.com/install.sh | sh || die "Falha ao instalar Ollama"
        }
    else
        curl -fsSL https://ollama.com/install.sh | sh || die "Falha ao instalar Ollama"
    fi
    
    systemctl enable ollama || log "Aviso: Falha ao habilitar serviço Ollama"
    systemctl start ollama || log "Aviso: Falha ao iniciar serviço Ollama"
}

cleanup_aur_sudo() {
    rm -f /etc/sudoers.d/99-arch-setup-aur
    trap - EXIT
}

# =============================================================================
# SSH
# =============================================================================

configure_ssh() {
    log "Configurando SSH..."
    
    local SSH_DIR="/home/${USERNAME}/.ssh"
    
    if [[ -f "${SSH_DIR}/id_rsa" ]]; then
        log "Chave SSH já existe."
        return
    fi
    
    mkdir -p "${SSH_DIR}"
    chown -R "${USERNAME}:${USERNAME}" "${SSH_DIR}"
    
    log "Gerando chave SSH..."
    runuser -u "${USERNAME}" -- ssh-keygen -t rsa -b 4096 -C "heitor.santos@gmail.com" -N "" || \
        log "Aviso: Falha ao gerar chave SSH"
    
    log "Chave pública gerada em ${SSH_DIR}/id_rsa.pub"
    log "Conteúdo da chave pública:"
    cat "${SSH_DIR}/id_rsa.pub"
}

# =============================================================================
# Impressora
# =============================================================================

setup_printer() {
    log "Configurando impressora..."
    
    usermod -aG lp "${USERNAME}" || log "Aviso: Falha ao adicionar usuário ao grupo lp"
    
    systemctl enable cups || die "Falha ao habilitar CUPS"
    systemctl start cups || die "Falha ao iniciar CUPS"
    
    # Habilitar descoberta de impressora na rede
    systemctl enable cups-browsed || log "Aviso: Falha ao habilitar cups-browsed"
}

# =============================================================================
# GNOME
# =============================================================================

start_gnome() {
    log "Habilitando GNOME Display Manager (GDM)..."
    
    systemctl enable gdm || die "Falha ao habilitar GDM"
    
    log "GDM habilitado. Será iniciado no próximo boot."
}

# =============================================================================
# Diretórios do usuário
# =============================================================================

setup_user_dirs() {
    log "Criando diretórios do usuário..."
    
    runuser -u "${USERNAME}" -- mkdir -p \
        /home/${USERNAME}/.themes \
        /home/${USERNAME}/.icons \
        /home/${USERNAME}/.fonts \
        /home/${USERNAME}/.local/bin || \
        log "Aviso: Falha ao criar alguns diretórios"
}

# =============================================================================
# Fluxo principal
# =============================================================================

main() {
    log "=========================================="
    log "Iniciando configuração do Arch Linux"
    log "=========================================="
    
    update_system
    setup_system
    create_user
    install_base_packages
    install_nvidia_drivers      # CRÍTICO: antes de pacotes gráficos
    install_additional_packages
    setup_flatpak
    install_paru
    install_aur_packages
    setup_oh_my_zsh
    install_mise
    install_ollama
    cleanup_aur_sudo
    configure_ssh
    setup_printer
    setup_user_dirs
    start_gnome
    
    log "=========================================="
    log "Configuração concluída com sucesso!"
    log "=========================================="
    log ""
    log "PRÓXIMOS PASSOS:"
    log "1. Reinicie o sistema: sudo reboot"
    log "2. Após boot, faça login no GNOME"
    log "3. Verifique drivers NVIDIA: nvidia-smi"
    log "4. Configure SSH: copie a chave pública para seus servidores"
    log ""
    log "Log completo em: ${LOG_FILE}"
}

main "$@"