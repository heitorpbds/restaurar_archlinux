# Configuração Inicial e Personalização do Arch Linux

Este guia detalha os passos para configurar um sistema Arch Linux após a instalação, incluindo ajustes de sistema, personalização do ambiente GNOME, configuração de drivers NVIDIA e instalação do Oh My Zsh com temas e plugins. Ele é projetado para otimizar o sistema, melhorar a estética e aumentar a produtividade.

## 1. Configuração do Sistema

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

### 1.4. Otimizar Espelhos com Reflector

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

Personalize o ambiente GNOME com extensões que melhoram funcionalidade, estética e produtividade. As extensões listadas abaixo podem ser instaladas via GNOME Extensions ou pacotes do Arch Linux (ex.: AUR).

### 2.1. Extensões Recomendadas

A tabela a seguir descreve cada extensão, suas funcionalidades e links para mais detalhes.

| Extensão | Descrição | Link |
| --- | --- | --- |
| **App Indicator (KStatusNotifier)** | Integra ícones de aplicativos legados (KDE/Ubuntu) no painel superior. | Link |
| **App Menu is Back** | Restaura o menu de aplicativos no painel, com opções como "Nova Janela". | Link |
| **Astra Monitor** | Monitora CPU, GPU, RAM e rede em tempo real no painel superior. | Link |
| **Blur My Shell** | Adiciona efeitos de desfoque ao painel, dash e overview. | Link |
| **Burn My Windows** | Efeitos visuais (ex.: chamas) ao abrir/fechar janelas. | Link |
| **Caffeine** | Desativa temporariamente a suspensão e protetor de tela. | Link |
| **Clipboard Indicator** | Gerencia histórico de itens copiados (texto/imagens) no painel. | Link |
| **Compiz Windows** | Adiciona efeito wobbly (ondulante) às janelas ao movê-las. | Link |
| **Compiz-like Magic Lamp Effect** | Efeito de lâmpada mágica para minimizar janelas. | Link |
| **Customize Clock on Lock Screen** | Personaliza o relógio na tela de bloqueio com texto/formato. | Link |
| **Dash to Dock** | Transforma o dash em um dock fixo com opções de autohide e animações. | Link |
| **Desktop Cube** | Rotaciona workspaces em um cubo 3D virtual. | Link |
| **Forge** | Gerenciamento avançado de janelas tiling, inspirado no i3. | Link |
| **GNOME Fuzzy App Search** | Melhora busca de apps com algoritmo fuzzy no overview. | Link |
| **GSConnect** | Sincroniza dispositivos (notificações, arquivos) via KDE Connect. | Link |
| **Lock Keys** | Exibe status de Num Lock e Caps Lock no painel superior. | Link |
| **Logo Menu** | Menu rápido com ícone personalizável no painel superior. | Link |
| **Media Controls** | Controles de mídia com arte de álbuns no painel ou Quick Settings. | Link |
| **Open Bar** | Tema personalizável para painel, menus e shell com cores e bordas. | Link |
| **Places Status Indicator** | Menu para acessar pastas do sistema (Home, Documentos, etc.). | Link |
| **Quick Settings Tweaker** | Personaliza o painel de Quick Settings com controles extras. | Link |
| **Remove World Clock** | Remove relógios mundiais do menu de data/hora. | Link |
| **Removable Drive Menu** | Menu para gerenciar dispositivos removíveis (USB, SD cards). | Link |
| **Search Light** | Popup flutuante para busca de apps, similar ao Spotlight. | Link |
| **Systemd Manager** | Gerencia serviços systemd via menu no painel superior. | Link |
| **Text Clock** | Relógio em texto (ex.: "Duas da tarde") no painel superior. | Link |
| **Tiling Shell** | Gerenciamento tiling avançado com layouts e snap dinâmico. | Link |
| **User Themes** | Carrega temas do shell a partir de \~/.themes. | Link |

### 2.2. Recursos de Personalização

- **Fontes**: Instale fontes personalizadas do Google Fonts para complementar temas visuais.
- **Referências de Vídeo**:
  - Personalização GNOME
  - Configuração Avançada
  - Configuração de Som

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
      Option "AllowEmptyInitialConfiguration"
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
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ```
- Após a instalação, configure o terminal usando o arquivo `~/.zshrc` (substitui `~/.bash_profile`).
- Reinicie o terminal para aplicar as alterações.

### 4.2. Configuração do Tema Spaceship

1. **Clonar o Repositório**

   ```bash
   git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
   ```

2. **Criar Link Simbólico**

   ```bash
   ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"# restaurar_archlinux
   
   
   
   Ao iniciar o arch se logar como ROOT e iniciar as configuracoes:
   
   nmtw
   hostnamectl hostname arch-acer
   
   Ajustar o arquivo de configuracao do reflector:
   nano /etc/xdg/reflector/reflector.conf
   
   Ajustar o arquivo /etc/pacman.conf
   nano /etc/pacman.conf
     Descomentar o Color
     Inserir ILoveCandy
     Mudar o ParallelDownloads = 5 
   
   passwd heitorpbds
   EDITOR=vim visudo
     Descomentar a linha %wheel ALL=(ALL:ALL) ALL
   
   Personalizacao gnome
     bluer my shell
     dash to docker animater
     quick setting tweaker
     compiz windows
     desktop cube
     gsconnect
     burn my windows
     customize clock on lock screen
     Forge
     Gnome Fuzzy App search
     App menu is back
     clipboard indicator
     logo menu
     text clock
     user themes 
     blur my shell
     compiz a like magic lamp effect
     dash to dock or dash to dock animated
     tilling shell
     caffeine
     lock keys
     remove word clock
     clipboard indicator
     astra monitor
     search light
     App indicator  kstatus notifer
     places status indicator
     media control
     removable drive menu
     systemd manager
     open bar
   
   
     https://www.youtube.com/watch?v=viffvWtMTdo&t=35s
     https://www.youtube.com/watch?v=z1tUVX0BpIc
     sound: https://www.youtube.com/watch?v=qVTJX299b5I
   
   
   Fonts: google fonts  
   
   Criar o seguinte arquivo para nvidia:
   
   sudo nano  /etc/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf 
   Section "OutputClass"
           Identifier "NVIDIA"
           MatchDriver " nvidia-drm"
           Driver "nvidia"
           Option "AllowEmptyInitialConfiguration"
           Option "UseSSR" "false"
           Option "AllowExternalGpus" "true"
           Option "MetaModes" " nvidia-auto-select +0 0"
           Option "AllowDithering" "false"
           Option "ProbeAllMonitors" "true"
           Option "SyncToVBlank" "true"
   EndSection
   "
   nvidia-smi
   lspci | grep -i vga
   
   Instalando o Oh My Zsh?
   
   A instalação do Oh My Zsh pode ser feita de duas formas oficiais, via Curl ou via Wget, iremos utilizar o curl.
   
   Digitar o seguinte comando no terminal:
   
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   
   GIF instalação do Oh My Zsh
   
   A partir de agora, todas configurações que você quiser fazer, como adicionar variáveis ambientes ou configurar seu terminal de qualquer forma, você irá utilizar o arquivo ~/.zshrc e não mais o ~/.bash_profile ou derivados.
   
   Reinicie o seu terminal.
   Configurando o tema Spaceship no Oh My Zsh!
   
   Spaceship é um prompt Zsh minimalista, poderoso e extremamente personalizável. Prompt é o que você vê quando digita um comando. Ele pode mostrar muitas dicas úteis, economizando seu tempo e tornando a experiência do usuário suave e agradável. Ele combina tudo o que você pode precisar para um trabalho conveniente, sem complicações desnecessárias, como uma nave espacial real.
   
   Primeiro, vamos clonar o repositório do GitHub:
   
   git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
   
   Criar um link para o seu diretório de temas personalizados oh-my-zsh:spaceship.zsh-theme
   
   ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
   
   Definir e configurar o tema no arquivo .zshrc para isso use o seu editor de texto preferido, no meu caso utilizo o VSCode
   
   code . ~/.zshrc
   
   Procure pela variável ZSH_THEME e altere para ZSH_THEME=”spaceship”
   
   Exemplo configuração variável ZSH_THEME
   
   No final do arquivo copie o seguinte texto:
   
   SPACESHIP_PROMPT_ORDER=(
     user # Username section
     dir # Current directory section
     host # Hostname section
     git # Git section (git_branch + git_status)
     hg # Mercurial section (hg_branch + hg_status)
     exec_time # Execution time
     line_sep # Line break
     jobs # Background jobs indicator
     exit_code # Exit code section
     char # Prompt character
   )
   
   SPACESHIP_USER_SHOW=always
   SPACESHIP_PROMPT_ADD_NEWLINE=false
   SPACESHIP_CHAR_SYMBOL="❯"
   SPACESHIP_CHAR_SUFFIX=" "
   
   Para mais configurações segue o link com as definições das diversas opções que podemos usar para customizar o prompt com o Spaceship.
   
   Para os temas inclusos no Oh My Zsh, você precisa somente configurar a variável ZSH_THEME, segue o link dos temas disponíveis.
   
   Themes · ohmyzsh/ohmyzsh Wiki (github.com)
   Instalando alguns plugins especiais
   
   Além de escolher um tema para modificar a aparência do terminal, também podemos adicionar funcionalidades a ele. Para isso, existem inúmeros plugins, que também são de código aberto e ajudam a tornar o interpretador de comandos muito mais potente que facilitam muito na hora de executar comandos comuns, realizar autocompletes, etc.
   
   Confira alguns deles a seguir.
   Zsh-syntax-highlighting
   
   O plugin zsh-syntax-highlighting da um destaque aos comandos enquanto eles são digitados. Dessa forma, se o comando estiver correto, ele será exibido na cor verde, caso contrário, o comando ficará em vermelho. Isso ajuda a revisar comandos antes de executar eles, particularmente na captura de erros de sintaxe.
   
   Para instalar esse plugin precisamos primeiro clonar o repositório do Github
   
   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
   
   Editar o arquivo .zshrc e ativar o plugin:
   
   plugins=( [plugins...] zsh-syntax-highlighting)
   
   O arquivo ficará da seguinte maneira:
   
   Exemplo da configuração do plugin do ZSH
   Zsh-autosuggestions
   
   Plugin de sugestões para comandos com base no histórico de comandos já usados. Ao digitar comandos, você verá uma conclusão oferecida após o cursor em uma cor cinza silenciada.
   
   A instalação é idêntica ao do plugin Zsh-syntax-highlighting.
   
   Clonar o repositório do Github e ativar o plugin.
   
   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
   # restaurar_archlinux
   
   
   
   Ao iniciar o arch se logar como ROOT e iniciar as configuracoes:
   
   nmtw
   hostnamectl hostname arch-acer
   
   Ajustar o arquivo de configuracao do reflector:
   nano /etc/xdg/reflector/reflector.conf
   
   Ajustar o arquivo /etc/pacman.conf
   nano /etc/pacman.conf
     Descomentar o Color
     Inserir ILoveCandy
     Mudar o ParallelDownloads = 5 
   
   passwd heitorpbds
   EDITOR=vim visudo
     Descomentar a linha %wheel ALL=(ALL:ALL) ALL
   
   Personalizacao gnome
     bluer my shell
     dash to docker animater
     quick setting tweaker
     compiz windows
     desktop cube
     gsconnect
     burn my windows
     customize clock on lock screen
     Forge
     Gnome Fuzzy App search
     App menu is back
     clipboard indicator
     logo menu
     text clock
     user themes 
     blur my shell
     compiz a like magic lamp effect
     dash to dock or dash to dock animated
     tilling shell
     caffeine
     lock keys
     remove word clock
     clipboard indicator
     astra monitor
     search light
     App indicator  kstatus notifer
     places status indicator
     media control
     removable drive menu
     systemd manager
     open bar
   
   
     https://www.youtube.com/watch?v=viffvWtMTdo&t=35s
     https://www.youtube.com/watch?v=z1tUVX0BpIc
     sound: https://www.youtube.com/watch?v=qVTJX299b5I
   
   
   Fonts: google fonts  
   
   Criar o seguinte arquivo para nvidia:
   
   sudo nano  /etc/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf 
   Section "OutputClass"
           Identifier "NVIDIA"
           MatchDriver " nvidia-drm"
           Driver "nvidia"
           Option "AllowEmptyInitialConfiguration"
           Option "UseSSR" "false"
           Option "AllowExternalGpus" "true"
           Option "MetaModes" " nvidia-auto-select +0 0"
           Option "AllowDithering" "false"
           Option "ProbeAllMonitors" "true"
           Option "SyncToVBlank" "true"
   EndSection
   "
   nvidia-smi
   lspci | grep -i vga
   
   Instalando o Oh My Zsh?
   
   A instalação do Oh My Zsh pode ser feita de duas formas oficiais, via Curl ou via Wget, iremos utilizar o curl.
   
   Digitar o seguinte comando no terminal:
   
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   
   GIF instalação do Oh My Zsh
   
   A partir de agora, todas configurações que você quiser fazer, como adicionar variáveis ambientes ou configurar seu terminal de qualquer forma, você irá utilizar o arquivo ~/.zshrc e não mais o ~/.bash_profile ou derivados.
   
   Reinicie o seu terminal.
   Configurando o tema Spaceship no Oh My Zsh!
   
   Spaceship é um prompt Zsh minimalista, poderoso e extremamente personalizável. Prompt é o que você vê quando digita um comando. Ele pode mostrar muitas dicas úteis, economizando seu tempo e tornando a experiência do usuário suave e agradável. Ele combina tudo o que você pode precisar para um trabalho conveniente, sem complicações desnecessárias, como uma nave espacial real.
   
   Primeiro, vamos clonar o repositório do GitHub:
   
   git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
   
   Criar um link para o seu diretório de temas personalizados oh-my-zsh:spaceship.zsh-theme
   
   ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
   
   Definir e configurar o tema no arquivo .zshrc para isso use o seu editor de texto preferido, no meu caso utilizo o VSCode
   
   code . ~/.zshrc
   
   Procure pela variável ZSH_THEME e altere para ZSH_THEME=”spaceship”
   
   Exemplo configuração variável ZSH_THEME
   
   No final do arquivo copie o seguinte texto:
   
   SPACESHIP_PROMPT_ORDER=(
     user # Username section
     dir # Current directory section
     host # Hostname section
     git # Git section (git_branch + git_status)
     hg # Mercurial section (hg_branch + hg_status)
     exec_time # Execution time
     line_sep # Line break
     jobs # Background jobs indicator
     exit_code # Exit code section
     char # Prompt character
   )
   
   SPACESHIP_USER_SHOW=always
   SPACESHIP_PROMPT_ADD_NEWLINE=false
   SPACESHIP_CHAR_SYMBOL="❯"
   SPACESHIP_CHAR_SUFFIX=" "
   
   Para mais configurações segue o link com as definições das diversas opções que podemos usar para customizar o prompt com o Spaceship.
   
   Para os temas inclusos no Oh My Zsh, você precisa somente configurar a variável ZSH_THEME, segue o link dos temas disponíveis.
   
   Themes · ohmyzsh/ohmyzsh Wiki (github.com)
   Instalando alguns plugins especiais
   
   Além de escolher um tema para modificar a aparência do terminal, também podemos adicionar funcionalidades a ele. Para isso, existem inúmeros plugins, que também são de código aberto e ajudam a tornar o interpretador de comandos muito mais potente que facilitam muito na hora de executar comandos comuns, realizar autocompletes, etc.
   
   Confira alguns deles a seguir.
   Zsh-syntax-highlighting
   
   O plugin zsh-syntax-highlighting da um destaque aos comandos enquanto eles são digitados. Dessa forma, se o comando estiver correto, ele será exibido na cor verde, caso contrário, o comando ficará em vermelho. Isso ajuda a revisar comandos antes de executar eles, particularmente na captura de erros de sintaxe.
   
   Para instalar esse plugin precisamos primeiro clonar o repositório do Github
   
   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
   
   Editar o arquivo .zshrc e ativar o plugin:
   
   plugins=( [plugins...] zsh-syntax-highlighting)
   
   O arquivo ficará da seguinte maneira:
   
   Exemplo da configuração do plugin do ZSH
   Zsh-autosuggestions
   
   Plugin de sugestões para comandos com base no histórico de comandos já usados. Ao digitar comandos, você verá uma conclusão oferecida após o cursor em uma cor cinza silenciada.
   
   A instalação é idêntica ao do plugin Zsh-syntax-highlighting.
   
   Clonar o repositório do Github e ativar o plugin.
   
   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
   
   plugins=( [plugins...] zsh-autosuggestions)
   
   Para outros puglins:
   
   Plugins · ohmyzsh/ohmyzsh Wiki (github.com)
   
   Por fim, recarregar as configurações do Zsh para que o seu terminal aberto já carregue as novas configurações:
   
   source ~/.zshrc
   
   plugins=( [plugins...] zsh-autosuggestions)
   
   Para outros puglins:
   
   Plugins · ohmyzsh/ohmyzsh Wiki (github.com)
   
   Por fim, recarregar as configurações do Zsh para que o seu terminal aberto já carregue as novas configurações:
   
   source ~/.zshrc
   
   ```

3. **Configurar o Tema**

   - Edite o arquivo `~/.zshrc` com seu editor preferido (ex.: VSCode):

     ```bash
     code ~/.zshrc
     ```
   - Altere a variável `ZSH_THEME`:

     ```
     ZSH_THEME="spaceship"
     ```

4. **Personalizar o Prompt**

   - Adicione ao final do `~/.zshrc`:

     ```bash
     SPACESHIP_PROMPT_ORDER=(
       user          # Username section
       dir           # Current directory section
       host          # Hostname section
       git           # Git section (git_branch + git_status)
       hg            # Mercurial section (hg_branch + hg_status)
       exec_time     # Execution time
       line_sep      # Line break
       jobs          # Background jobs indicator
       exit_code     # Exit code section
       char          # Prompt character
     )
     
     SPACESHIP_USER_SHOW=always
     SPACESHIP_PROMPT_ADD_NEWLINE=false
     SPACESHIP_CHAR_SYMBOL="❯"
     SPACESHIP_CHAR_SUFFIX=" "
     ```

5. **Recursos Adicionais**

   - Consulte a documentação do Spaceship para mais opções.
   - Veja os temas do Oh My Zsh.

### 4.3. Instalação de Plugins

1. **Zsh-syntax-highlighting**

   - Clone o repositório:

     ```bash
     git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
     ```
   - Adicione ao `~/.zshrc`:

     ```bash
     plugins=(zsh-syntax-highlighting)
     ```

2. **Zsh-autosuggestions**

   - Clone o repositório:

     ```bash
     git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
     ```
   - Adicione ao `~/.zshrc`:

     ```bash
     plugins=(zsh-syntax-highlighting zsh-autosuggestions)
     ```

3. **Aplicar Configurações**

   ```bash
   source ~/.zshrc
   ```

4. **Mais Plugins**

   - Explore a lista de plugins do Oh My Zsh.

## 5. Considerações Finais

- **Teste as Configurações**: Execute cada comando e verifique o comportamento do sistema.
- **Compatibilidade**: Certifique-se de que as extensões são compatíveis com sua versão do GNOME (ex.: 45, 46 ou 47).
- **Fontes e Temas**: Combine extensões com temas GTK e fontes do Google Fonts para uma experiência visual coesa.
- **Referências**: Consulte a documentação oficial do Arch Linux, GNOME, NVIDIA e Oh My Zsh para suporte adicional.



  https://www.youtube.com/watch?v=viffvWtMTdo&t=35s
  https://www.youtube.com/watch?v=z1tUVX0BpIc
  sound: https://www.youtube.com/watch?v=qVTJX299b5I

