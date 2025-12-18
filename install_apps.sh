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
    #reflector -c Brazil -a 6 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    #check_error "Falha ao configurar mirrors com Reflector."

    update_system
}

# Função para instalar pacotes adicionais
install_additional_packages() {
    log "Instalando pacotes adicionais..."
    local packages=(
        xdg-user-dirs fastfetch git base-devel curl wget nano vim networkmanager
        zsh zip unzip ffmpeg ntfs-3g docker docker-compose kdenlive audacity hplip
        print-manager system-config-printer ffmpegthumbs steam bitwarden dosfstools
        gnome-builder linux-headers gnome-shell gnome-terminal gnome-control-center
        gnome-tweaks gnome-backgrounds nautilus gdm firefox gnome-software
        cups cups-pdf system-config-printer sane xsane simple-scan
        gnome-shell-extensions btop gparted 
    )

    # Adicionar drivers NVIDIA apenas se o hardware for compatível
    if check_nvidia; then
        packages+=(nvidia nvidia-prime xorg-xrandr)
    fi

    pacman -S --needed --noconfirm "${packages[@]}" libreoffice-fresh
    check_error "Falha ao instalar pacotes adicionais."
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
        extension-manager zoom hplip-plugin brave-browser tilix
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
# Função para instalar Pyenv
install_pyenv() {
    log "Instalando Pyenv e suas dependências..."
    pacman -S --needed --noconfirm base-devel openssl zlib xz sqlite bzip2 readline ncurses tk libffi llvm git
    check_error "Falha ao instalar dependências do Pyenv."

    if [ -d /home/heitorpbds/.pyenv ]; then
        log "Pyenv já está instalado. Pulando."
        return
    fi

    log "Clonando repositório do Pyenv para o usuário heitorpbds..."
    runuser -u heitorpbds -- git clone https://github.com/pyenv/pyenv.git /home/heitorpbds/.pyenv
    check_error "Falha ao clonar repositório do Pyenv."

    log "Configurando ambiente para Pyenv no .zshrc..."
    ZSHRC_PATH="/home/heitorpbds/.zshrc"
    runuser -u heitorpbds -- tee -a "$ZSHRC_PATH" >/dev/null <<'EOF'

# Configuração do Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
EOF

    check_error "Falha ao configurar .zshrc para Pyenv."

    log "Instalando plugin pyenv-virtualenv..."
    runuser -u heitorpbds -- git clone https://github.com/pyenv/pyenv-virtualenv.git /home/heitorpbds/.pyenv/plugins/pyenv-virtualenv
    check_error "Falha ao instalar pyenv-virtualenv."

    log "Configurando pyenv-virtualenv no .zshrc..."
    runuser -u heitorpbds -- tee -a "$ZSHRC_PATH" >/dev/null <<'EOF'

eval "$(pyenv virtualenv-init -)"
EOF
    check_error "Falha ao configurar .zshrc para pyenv-virtualenv."

    log "Pyenv instalado com sucesso."
}

# Função para iniciar o GNOME
start_gnome() {
    log "Habilitando e iniciando o GNOME Display Manager (GDM)..."
    systemctl enable --now gdm
    check_error "Falha ao habilitar/iniciar o GDM."
    systemctl status gdm --no-pager
}

configureSSH() {
    if [ -d /home/heitorpbds/.pyenv ]; then
        log "SSH já criado."
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
install_paru
install_aur_packages
setup_oh_my_zsh
install_pyenv
install_ollama
start_gnome
configureSSH
habilitandoImpressora


if [ -d /home/heitorpbds/.themes ]; then
    log "Diretório .themes já existe. Pulando criação."
else
    log "Criando diretório .themes no home do usuário heitorpbds..."
    mkdir -p ~/.themes
fi


log "Configuração concluída com sucesso!"
