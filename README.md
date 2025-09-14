# restaurar_archlinux

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
