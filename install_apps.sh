#!/usr/bin/env bash

# Configurações iniciais
# set -e
rm /tmp/setup-arch.log  # Remove log antigo, se existir
LOG_FILE="/tmp/setup-arch.log"

# Função para registrar logs
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Função para verificar se o comando anterior foi bem-sucedido
check_error() {
    if [ $? -ne 0 ]; then
        log "AVISO: Falha em '$1'. Continuando com o script."
    fi
}

# Função para verificar hardware NVIDIA
check_nvidia() {
    log "Verificando suporte a NVIDIA..."
    if lspci | grep -i nvidia > /dev/null; then
        log "Hardware NVIDIA detectado."
        return 0
    else
        log "Nenhum hardware NVIDIA detectado. Ignorando drivers NVIDIA."
        return 1
    fi
}

# Função para atualizar o sistema
update_system() {
    log "Atualizando sistema..."
    pacman -Syu --needed --noconfirm
    check_error "Falha ao atualizar o sistema."
}

# Função para configurar o sistema básico
setup_system() {
    log "Configurando hostname, fuso horário e locale..."
    hostnamectl hostname arch-acer
    check_error "Falha ao configurar hostname."

    timedatectl set-timezone America/Sao_Paulo
    check_error "Falha ao configurar fuso horário."

    timedatectl set-ntp true
    check_error "Falha ao configurar NTP."

    log "Configurando locale..."
    sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
    locale-gen
    check_error "Falha ao gerar locales."
    echo LANG="en_US.UTF-8" > /etc/locale.conf
    localectl set-keymap us
    check_error "Falha ao configurar layout de teclado."
}

# Função para criar usuário
create_user() {
    log "Criando usuário heitorpbds..."
    if id heitorpbds &>/dev/null; then
        log "Usuário heitorpbds já existe. Pulando criação."
    else
        useradd -m -G wheel heitorpbds
        check_error "Falha ao criar usuário heitorpbds."
        log "Defina a senha para heitorpbds:"
        passwd heitorpbds
        check_error "Falha ao definir senha para heitorpbds."
    fi
}

# Função para instalar pacotes básicos
install_base_packages() {
    log "Instalando pacotes básicos..."
    pacman -S --needed --noconfirm \
        reflector sudo vim
    check_error "Falha ao instalar pacotes básicos."

    log "Configurando mirrors com Reflector..."
    reflector -c Brazil -a 6 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    check_error "Falha ao configurar mirrors com Reflector."

    update_system
}

# Função para instalar pacotes adicionais
install_additional_packages() {
    log "Instalando pacotes adicionais..."
    local packages=(
        xdg-user-dirs fastfetch git base-devel curl wget nano vim networkmanager
        zip unzip ffmpeg ntfs-3g docker docker-compose hplip
        print-manager system-config-printer ffmpegthumbs steam bitwarden dosfstools
        gnome-builder linux-headers gnome-control-center
        gnome-tweaks cups cups-pdf btop gparted 
    )

    # Adicionar drivers NVIDIA apenas se o hardware for compatível
    if check_nvidia; then
        packages+=(nvidia nvidia-prime xorg-xrandr)
    fi

    pacman -S --needed --noconfirm "${packages[@]}" libreoffice-fresh
    check_error "Falha ao instalar pacotes adicionais."
}

# Função para configurar Flatpak e Flathub
setup_flatpak() {
    log "Instalando Flatpak..."
    pacman -S --needed --noconfirm flatpak
    check_error "Falha ao instalar Flatpak."

    log "Adicionando o repositório Flathub..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    check_error "Falha ao adicionar o repositório Flathub."

    log "Instalando aplicativos Flatpak..."
    local flatpak_apps=(
        me.iepure.devtoolbox
        com.heroicgameslauncher.hgl
        md.obsidian.Obsidian
        de.haeckerfelix.Shortwave
    )
    flatpak install --system --or-update --assumeyes flathub "${flatpak_apps[@]}"
    check_error "Falha ao instalar aplicativos Flatpak."

    log "Flatpak e Flathub configurados com sucesso."

    # cat ~/.ssh/id_rsa.pub visualizar a chave.
}

# Função para instalar Paru
install_paru() {
    log "Instalando Paru..."
    if command -v paru &>/dev/null; then
        log "Paru já está instalado. Pulando instalação."
        return
    fi

    pacman -S --needed --noconfirm git base-devel
    check_error "Falha ao instalar dependências para Paru."

    log "Clonando repositório do Paru..."
    cd /tmp
    runuser -u heitorpbds -- git clone https://aur.archlinux.org/paru.git
    check_error "Falha ao clonar repositório do Paru."

    cd paru
    log "Compilando e instalando Paru..."
    runuser -u heitorpbds -- makepkg -si --noconfirm
    check_error "Falha ao instalar Paru."
}

# Função para instalar pacotes do AUR
install_aur_packages() {
    log "Instalando pacotes do AUR com Paru..."
    local aur_packages=(
        google-chrome webapp-manager youtube-music-bin visual-studio-code-bin
        extension-manager hplip-plugin brave-browser rustdesk-bin oversteer tilix SublimeText
    )

    log "Revisando PKGBUILDs antes da instalação..."
    for pkg in "${aur_packages[@]}"; do
        log "Verificando PKGBUILD para $pkg..."
        runuser -u heitorpbds -- paru -G "$pkg"
        check_error "Falha ao baixar PKGBUILD para $pkg."
        log "Por favor, revise o PKGBUILD em /home/heitorpbds/$pkg antes de continuar."
        read -p "Continuar com a instalação de $pkg? (s/n): " answer
        if [[ "$answer" != "s" ]]; then
            log "Pulando instalação de $pkg."
            continue
        fi
        runuser -u heitorpbds -- paru -S --needed --noconfirm "$pkg"
        check_error "Falha ao instalar $pkg."
    done
}

# Função para configurar Oh My Zsh
setup_oh_my_zsh() {
    log "Instalando Oh My Zsh para heitorpbds..."
    if [ -d /home/heitorpbds/.oh-my-zsh ]; then
        log "Oh My Zsh já está instalado para heitorpbds. Pulando."
        return
    fi

    log "Baixando script de instalação do Oh My Zsh..."
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o /tmp/install-ohmyzsh.sh
    check_error "Falha ao baixar script do Oh My Zsh."

    log "Executando instalação do Oh My Zsh..."
    runuser -u heitorpbds -- sh /tmp/install-ohmyzsh.sh
    check_error "Falha ao instalar Oh My Zsh."

    log "Configurando Zsh como shell padrão para heitorpbds..."
    chsh -s /bin/zsh heitorpbds
    check_error "Falha ao configurar Zsh como shell padrão."
}

# Função para instalar mise
install_mise() {
    log "Instalando mise (gerenciador de versões)..."

    if command -v mise &>/dev/null; then
        log "mise já está instalado. Pulando."
        return
    fi

    pacman -S --needed --noconfirm mise
    check_error "Falha ao instalar mise."

    log "Configurando ambiente para mise no .zshrc..."
    ZSHRC_PATH="/home/heitorpbds/.zshrc"
    if ! grep -Fq 'eval "$(mise activate zsh)"' "$ZSHRC_PATH" 2>/dev/null; then
        runuser -u heitorpbds -- tee -a "$ZSHRC_PATH" >/dev/null <<'EOF'

# Configuração do mise
eval "$(mise activate zsh)"
EOF
        check_error "Falha ao configurar .zshrc para mise."
    fi

    log "mise instalado com sucesso. Use 'mise use <ferramenta>@<versao>' para configurar versões."
}

# Função para iniciar o GNOME
start_gnome() {
    log "Habilitando e iniciando o GNOME Display Manager (GDM)..."
    systemctl enable --now gdm
    check_error "Falha ao habilitar/iniciar o GDM."
    systemctl status gdm --no-pager
}

configureSSH() {
    if [ -f /home/heitorpbds/.ssh/id_rsa ]; then
        log "Chave SSH já existe em /home/heitorpbds/.ssh/id_rsa. Pulando."
        return
    else
        log "Gerando SSH."
        ssh-keygen -t rsa -b 4096 -C "heitor.santos@gmail.com"
        # cat ~/.ssh/id_rsa.pub visualizar a chave.
        check_error "Falha ao gerar chave SSH."
    fi
}

habilitandoImpressora() {
    log " Habilitando impressora."
    sudo usermod -aG lp $USER
    sudo systemctl enable cups
    sudo systemctl start cups
}

install_ollama() {
    if command -v ollama &>/dev/null; then
        log "Ollama já está instalado. Pulando instalação."
        return
    else
        log "Instalando Ollama..."
        curl -fsSL https://ollama.com/install.sh | sh
        check_error "Falha ao instalar Ollama."
    fi
}

# Fluxo principal
log "Iniciando configuração do sistema Arch Linux..."
update_system
setup_system
create_user
install_base_packages
install_additional_packages
setup_flatpak
install_paru
install_aur_packages
setup_oh_my_zsh
install_mise
install_ollama
start_gnome
configureSSH
habilitandoImpressora

# Criar diretórios de usuário
log "Criando diretórios de usuário (ex: .themes)..."
runuser -u heitorpbds -- mkdir -p /home/heitorpbds/.themes
check_error "Falha ao criar diretório .themes."

if [ -d /home/heitorpbds/.themes ]; then
    log "Diretório .themes já existe. Pulando criação."
else
    log "Criando diretório .themes no home do usuário heitorpbds..."
    mkdir -p ~/.themes
fi


log "Configuração concluída com sucesso!"


# Aplicativo para instalar e configurar 
# perifericos Logitech: https://openlogi.org/ - https://github.com/AprilNEA/OpenLogi

# RomM: Organizador de jogos - https://www.youtube.com/watch?v=mzJsvLgVoRQ - https://docs.romm.app/latest/getting-started/quick-start/
