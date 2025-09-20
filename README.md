# Configuração Inicial e Personalização do Arch Linux

Este guia detalha os passos para configurar um sistema Arch Linux após a instalação, incluindo ajustes de sistema, personalização do ambiente GNOME, configuração de drivers NVIDIA, e instalação de ferramentas essenciais como Oh My Zsh com temas e plugins, além da configuração de impressoras. Ele é projetado para otimizar o sistema, melhorar a estética e aumentar a produtividade.

## 1. Configuração do Sistema Base

Esta seção cobre os passos iniciais para configurar o sistema base, incluindo rede, hostname, gerenciador de pacotes e permissões de usuário.

### 1.1. Login como Root

- Faça login como usuário `root` para realizar configurações administrativas iniciais.

### 1.2. Configurar a Rede

- Use o NetworkManager para configurar a conexão de rede:

  ```bash
  nmtui
  ```
- Siga as instruções para conectar-se à rede Wi-Fi ou Ethernet.

### 1.3. Definir o Hostname

- Configure o nome do host da máquina:

  ```bash
  hostnamectl set-hostname arch-acer
  ```

### 1.4. Otimizar Espelhos do Pacman (Reflector)

- Edite o arquivo de configuração do `reflector` para selecionar espelhos rápidos:

  ```bash
  nano /etc/xdg/reflector/reflector.conf
  ```
- Exemplo de configuração: especifique países (ex.: `--country Brazil,US`) e protocolo HTTPS.

### 1.5. Configurar o Pacman

- Edite o arquivo de configuração do gerenciador de pacotes:

  ```bash
  nano /etc/pacman.conf
  ```
- Realize os seguintes ajustes:
  - Descomente `Color` para ativar cores no terminal.
  - Adicione `ILoveCandy` abaixo de `Color` para estilizar a barra de progresso.
  - Ajuste `ParallelDownloads = 5` para downloads paralelos (aumente para conexões rápidas).

### 1.6. Definir Senha do Usuário

- Configure a senha para o usuário `heitorpbds`:

  ```bash
  passwd heitorpbds
  ```

### 1.7. Configurar Permissões do Sudo

- Edite o arquivo `visudo` para conceder privilégios ao grupo `wheel`:

  ```bash
  EDITOR=vim visudo
  ```
- Descomente a linha:

  ```
  %wheel ALL=(ALL:ALL) ALL
  ```

## 2. Personalização do Ambiente GNOME

Personalize o ambiente GNOME com ferramentas, extensões e fontes que melhoram funcionalidade, estética e produtividade.

### 2.1. Instalação de Ferramentas GNOME Essenciais

- Instale o GNOME Software Center, extensões do GNOME Shell e o GNOME Tweaks:

  ```bash
  sudo pacman -S gnome-software gnome-shell-extensions gnome-tweaks
  ```

### 2.2. Criação de Diretório de Temas

- Crie o diretório `~/.themes` para armazenar temas personalizados:

  ```bash
  mkdir -p ~/.themes
  ```

### 2.3. Extensões Recomendadas

A tabela a seguir descreve cada extensão, suas funcionalidades e links para mais detalhes. As extensões podem ser instaladas via GNOME Extensions (site ou aplicativo) ou pacotes do Arch Linux (ex.: AUR).

| Extensão | Descrição | Link |
| --- | --- | --- |
| **App Indicator (KStatusNotifier)** | Integra ícones de aplicativos legados (KDE/Ubuntu) no painel superior. | [Link](https://extensions.gnome.org/extension/615/appindicator-support/) |
| **App Menu is Back** | Restaura o menu de aplicativos no painel, com opções como "Nova Janela". | [Link](https://extensions.gnome.org/extension/1070/app-menu-is-back/) |
| **Astra Monitor** | Monitora CPU, GPU, RAM e rede em tempo real no painel superior. | [Link](https://extensions.gnome.org/extension/4439/astra-monitor/) |
| **Blur My Shell** | Adiciona efeitos de desfoque ao painel, dash e overview. | [Link](https://extensions.gnome.org/extension/3193/blur-my-shell/) |
| **Burn My Windows** | Efeitos visuais (ex.: chamas) ao abrir/fechar janelas. | [Link](https://extensions.gnome.org/extension/3602/burn-my-windows/) |
| **Caffeine** | Desativa temporariamente a suspensão e protetor de tela. | [Link](https://extensions.gnome.org/extension/517/caffeine/) |
| **Clipboard Indicator** | Gerencia histórico de itens copiados (texto/imagens) no painel. | [Link](https://extensions.gnome.org/extension/4442/clipboard-indicator/) |
| **Compiz-like Magic Lamp Effect** | Adiciona efeito de lâmpada mágica ao minimizar janelas. | [Link](https://extensions.gnome.org/extension/4379/compiz-like-magic-lamp-effect/) |
| **Compiz Windows** | Adiciona efeito wobbly (ondulante) às janelas ao movê-las. | [Link](https://extensions.gnome.org/extension/2960/compiz-windows-effect/) |
| **Customize Clock on Lock Screen** | Personaliza o relógio na tela de bloqueio com texto/formato. | [Link](https://extensions.gnome.org/extension/3920/customize-lock-screen-clock/) |
| **Dash to Dock** | Transforma o dash em um dock fixo com opções de autohide e animações. | [Link](https://extensions.gnome.org/extension/307/dash-to-dock/) |
| **Desktop Cube** | Rotaciona workspaces em um cubo 3D virtual. | [Link](https://extensions.gnome.org/extension/282/desktop-cube/) |
| **Forge** | Gerenciamento avançado de janelas tiling, inspirado no i3. | [Link](https://extensions.gnome.org/extension/4508/forge/) |
| **GNOME Fuzzy App Search** | Melhora busca de apps com algoritmo fuzzy no overview. | [Link](https://extensions.gnome.org/extension/5013/gnome-fuzzy-app-search/) |
| **GSConnect** | Sincroniza dispositivos (notificações, arquivos) via KDE Connect. | [Link](https://extensions.gnome.org/extension/1319/gsconnect/) |
| **Lock Keys** | Exibe status de Num Lock e Caps Lock no painel superior. | [Link](https://extensions.gnome.org/extension/36/lock-keys/) |
| **Logo Menu** | Menu rápido com ícone personalizável no painel superior. | [Link](https://extensions.gnome.org/extension/3731/logo-menu/) |
| **Media Controls** | Controles de mídia com arte de álbuns no painel ou Quick Settings. | [Link](https://extensions.gnome.org/extension/520/media-controls/) |
| **Open Bar** | Tema personalizável para painel, menus e shell com cores e bordas. | [Link](https://extensions.gnome.org/extension/5095/open-bar/) |
| **Places Status Indicator** | Menu para acessar pastas do sistema (Home, Documentos, etc.). | [Link](https://extensions.gnome.org/extension/8/places-status-indicator/) |
| **Quick Settings Tweaker** | Personaliza o painel de Quick Settings com controles extras. | [Link](https://extensions.gnome.org/extension/5446/quick-settings-tweaker/) |
| **Remove World Clock** | Remove relógios mundiais do menu de data/hora. | [Link](https://extensions.gnome.org/extension/1487/remove-world-clock/) |
| **Removable Drive Menu** | Menu para gerenciar dispositivos removíveis (USB, SD cards). | [Link](https://extensions.gnome.org/extension/7/removable-drive-menu/) |
| **Search Light** | Popup flutuante para busca de apps, similar ao Spotlight. | [Link](https://extensions.gnome.org/extension/5042/search-light/) |
| **Systemd Manager** | Gerencia serviços systemd via menu no painel superior. | [Link](https://extensions.gnome.org/extension/4365/systemd-manager/) |
| **Text Clock** | Relógio em texto (ex.: "Duas da tarde") no painel superior. | [Link](https://extensions.gnome.org/extension/1014/text-clock/) |
| **Tiling Shell** | Gerenciamento tiling avançado com layouts e snap dinâmico. | [Link](https://extensions.gnome.org/extension/2524/tiling-shell/) |
| **User Themes** | Carrega temas do shell a partir de `~/.themes`. | [Link](https://extensions.gnome.org/extension/19/user-themes/) |

### 2.4. Recursos Adicionais

- **Fontes**: Instale fontes personalizadas do Google Fonts para complementar temas visuais.
- **Referências de Vídeo**:
  - Personalização GNOME: [https://www.youtube.com/watch?v=viffvWtMTdo&t=35s](https://www.youtube.com/watch?v=viffvWtMTdo&t=35s)
  - Configuração Avançada: [https://www.youtube.com/watch?v=z1tUVX0BpIc](https://www.youtube.com/watch?v=z1tUVX0BpIc)
  - Configuração de Som: [https://www.youtube.com/watch?v=qVTJX299b5I](https://www.youtube.com/watch?v=qVTJX299b5I)

## 3. Configuração de Drivers NVIDIA

Configure os drivers NVIDIA para otimizar o desempenho gráfico, especialmente em sistemas com GPUs NVIDIA.

### 3.1. Criar Arquivo de Configuração Xorg

- Crie o arquivo de configuração para o driver NVIDIA:

  ```bash
  sudo nano /etc/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf
  ```
- Adicione o seguinte conteúdo:

  ```conf
  Section "OutputClass"
      Identifier "NVIDIA"
      MatchDriver "nvidia-drm"
      Driver "nvidia"
      Option "AllowEmptyInitialConfiguration" "true"
      Option "UseSSR" "false"
      Option "AllowExternalGpus" "true"
      Option "MetaModes" "nvidia-auto-select +0+0"
      Option "AllowDithering" "false"
      Option "ProbeAllMonitors" "true"
      Option "SyncToVBlank" "true"
  EndSection
  ```

### 3.2. Verificar Driver NVIDIA

- Confirme o status do driver:

  ```bash
  nvidia-smi
  ```
- Liste dispositivos de vídeo para verificar a GPU:

  ```bash
  lspci | grep -i vga
  ```

## 4. Instalação e Configuração do Oh My Zsh

O Oh My Zsh é um framework para personalizar o terminal Zsh, oferecendo temas e plugins para maior produtividade.

### 4.1. Instalação do Oh My Zsh

- Instale via Curl:

  ```bash
  sh -c "$(curl -fsSL [https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh](https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh))"
  ```
- Após a instalação, configure o terminal usando o arquivo `~/.zshrc` (que substitui `~/.bash_profile`).
- Reinicie o terminal para aplicar as alterações.

### 4.2. Configuração do Tema Spaceship

Spaceship é um prompt Zsh minimalista, poderoso e extremamente personalizável. Ele combina tudo o que você pode precisar para um trabalho conveniente.

1.  **Clonar o Repositório**

    ```bash
    git clone [https://github.com/spaceship-prompt/spaceship-prompt.git](https://github.com/spaceship-prompt/spaceship-prompt.git) "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
    ```

2.  **Criar Link Simbólico**

    ```bash
    ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
    ```

3.  **Configurar o Tema no `.zshrc`**

    - Edite o arquivo `~/.zshrc` com seu editor preferido (ex.: `nano`):

      ```bash
      nano ~/.zshrc
      ```
    - Altere a variável `ZSH_THEME` para:

      ```zsh
      ZSH_THEME="spaceship"
      ```

4.  **Personalizar a Ordem do Prompt**

    - Adicione ao final do `~/.zshrc` para definir a ordem dos elementos no prompt:

      ```zsh
      SPACESHIP_PROMPT_ORDER=(
        user          # Username section
        dir           # Current directory section
        host          # Hostname section
        git           # Git section (git_branch + git_status)
        hg            # Mercurial section (hg_branch + hg_status)
        exec_time     # Execution time
        line_sep      # Line break
        jobs          # Background jobs indicator
        exit_code     # Exit code section
        char          # Prompt character
      )
      
      SPACESHIP_USER_SHOW=always
      SPACESHIP_PROMPT_ADD_NEWLINE=false
      SPACESHIP_CHAR_SYMBOL="❯"
      SPACESHIP_CHAR_SUFFIX=" "
      ```
    - Para mais configurações do Spaceship, consulte a [documentação oficial](https://spaceship-prompt.sh/docs/options/).

### 4.3. Instalação de Plugins

Além de temas, plugins adicionam funcionalidades ao terminal Zsh, como destaque de sintaxe e sugestões de comandos.

1.  **Zsh-syntax-highlighting**

    - Este plugin destaca comandos enquanto são digitados (verde para correto, vermelho para incorreto).
    - Clone o repositório:

      ```bash
      git clone [https://github.com/zsh-users/zsh-syntax-highlighting.git](https://github.com/zsh-users/zsh-syntax-highlighting.git) ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
      ```

2.  **Zsh-autosuggestions**

    - Este plugin oferece sugestões de comandos baseadas no histórico de uso.
    - Clone o repositório:

      ```bash
      git clone [https://github.com/zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
      ```

3.  **Ativar Plugins no `.zshrc`**

    - Edite o arquivo `~/.zshrc`:

      ```bash
      nano ~/.zshrc
      ```
    - Encontre a linha `plugins=(...)` e adicione os plugins, separados por espaços. Por exemplo:

      ```zsh
      plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
      ```
    - Para explorar outros plugins, consulte a [wiki oficial do Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins).

### 4.4. Aplicar Configurações do Zsh

- Após salvar as alterações no `~/.zshrc`, recarregue as configurações ou reinicie o terminal:

  ```bash
  source ~/.zshrc
  ```

## 5. Configuração de Impressora (CUPS e HPLIP)

Este guia detalha a instalação e configuração de uma impressora no Arch Linux utilizando CUPS e, especificamente para impressoras HP, o HPLIP.

### 5.1. Instalar CUPS (Sistema de Impressão)

- O CUPS é o sistema de impressão padrão. Instale-o juntamente com a opção de impressão em PDF (opcional):

  ```bash
  sudo pacman -S cups cups-pdf
  ```

### 5.2. Iniciar e Habilitar Serviço CUPS

- Para garantir que o CUPS inicie automaticamente com o sistema:

  ```bash
  sudo systemctl enable cups
  sudo systemctl start cups
  ```

### 5.3. Instalar Drivers HP (HPLIP)

- Para suporte a impressoras HP, instale o pacote `hplip`:

  ```bash
  sudo pacman -S hplip
  ```
- Se sua impressora requer plugins proprietários (como algumas multifuncionais), instale também:

  ```bash
  sudo pacman -S hplip-plugin
  ```
  - **Nota**: O `hplip-plugin` pode não estar nos repositórios oficiais. Nesse caso, você pode precisar baixá-lo do site da HP ou usar o AUR (veja o passo 5.5).

### 5.4. Configurar a Impressora com HPLIP

- Execute o comando de configuração da HP. Se a impressora for USB, conecte-a antes de executar:

  ```bash
  sudo hp-setup -i
  ```
- Siga as instruções na interface gráfica ou no terminal para detectar e configurar a impressora (USB ou rede). Para impressoras de rede, tenha o endereço IP ou nome do host em mãos.

### 5.5. (Opcional) Instalar HPLIP Plugin via AUR

- Se o `hplip-plugin` não estiver disponível nos repositórios oficiais, você pode instalá-lo via AUR. Para isso, você precisará de um auxiliar do AUR como `yay` ou `paru`. Se não tiver, instale um, por exemplo, `paru`:

  ```bash
  sudo pacman -S paru
  ```
- Em seguida, instale o plugin:

  ```bash
  paru -S hplip-plugin
  ```
- Após a instalação, execute novamente `sudo hp-setup -i` se necessário.

### 5.6. Acessar a Interface Web do CUPS (Opcional)

- O CUPS possui uma interface web para gerenciar impressoras:
  - Abra o navegador e acesse: [http://localhost:631](http://localhost:631)
  - Vá para a seção "Administration" > "Add Printer".
  - Faça login com suas credenciais de administrador (usuário e senha do sistema).
  - Siga as instruções para adicionar a impressora, caso o `hp-setup` não a tenha configurado automaticamente.

### 5.7. Testar a Impressora

- Após a configuração, teste a impressora:
  - Liste as impressoras configuradas e a padrão:

    ```bash
    lpstat -p -d
    ```
  - Para imprimir uma página de teste:

    ```bash
    lp /usr/share/cups/data/testprint
    ```

### 5.8. (Opcional) Ferramentas Adicionais e Solução de Problemas

- Para gerenciamento gráfico de impressoras, instale:

  ```bash
  sudo pacman -S system-config-printer
  ```
- Para suporte a digitalização (se for uma multifuncional HP), instale:

  ```bash
  sudo pacman -S sane xsane
  ```
- **Solução de problemas (se necessário):**
  - **Impressora não detectada**: Verifique a conexão USB ou o IP da impressora. Certifique-se de que o serviço CUPS está ativo (`systemctl status cups`).
  - **Driver ausente**: Algumas impressoras requerem plugins específicos. Consulte a lista de impressoras suportadas pelo HPLIP no site da HP.
  - **Permissões**: Adicione seu usuário ao grupo `lp` para evitar problemas de permissão:

    ```bash
    sudo usermod -aG lp $USER
    ```

## 6. Instalação de Software Adicional

### 6.1. Navegadores

- Instale o Firefox:

  ```bash
  sudo pacman -S firefox
  ```
- Instale o Brave Browser (via AUR, assumindo `paru` ou `yay` está instalado):

  ```bash
  paru brave-browser
  ```

### 6.2. Ferramentas de Digitalização

- Instale o Simple Scan para digitalização de documentos:

  ```bash
  sudo pacman -S simple-scan
  ```

## 7. Geração de Chave SSH

- Gere um par de chaves SSH RSA com 4096 bits e um comentário:

  ```bash
  ssh-keygen -t rsa -b 4096 -C "heitor.santos@gmail.com"
  ```
- Visualize sua chave pública para adicioná-la a serviços como GitHub, GitLab, etc.:

  ```bash
  cat ~/.ssh/id_rsa.pub
  ```

## 8. Considerações Finais

- **Teste as Configurações**: Execute cada comando e verifique o comportamento do sistema após cada alteração.
- **Compatibilidade**: Certifique-se de que as extensões são compatíveis com sua versão do GNOME.
- **Fontes e Temas**: Combine extensões com temas GTK e fontes do Google Fonts para uma experiência visual coesa.
- **Referências**: Consulte a documentação oficial do Arch Linux, GNOME, NVIDIA e Oh My Zsh para suporte adicional.
