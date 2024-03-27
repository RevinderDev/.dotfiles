# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="gallois"
SOLARIZED_THEME="dark"
export BAT_THEME="gruvbox-dark"

# Python
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$HOME/.poetry/bin:$PATH"

eval "$(pyenv init --path)" # This must happen before pyenv plugin initialization: see https://github.com/pyenv/pyenv/issues/2041#issuecomment-990253001
eval "$(pyenv virtualenv-init -)"

plugins=(
	zsh-autosuggestions
	zsh-syntax-highlighting
	git
	gitfast
	kubectl
	docker
	docker-compose
	python
	encode64
	rust
	fzf
	pyenv
	poetry
	zoxide
)

source $ZSH/oh-my-zsh.sh
export FZF_BASE=/usr/bin/fzf

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#989898,bold"
bindkey '^ ' autosuggest-accept

alias ls="eza -a -l --header --icons --hyperlink --time-style relative"
alias lg="lazygit"


# Zellij
export ZELLIJ_CONFIG_FILE=~/.config/zellij/config.kdl


# Golang
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/go/bin

# Neovim
export PATH="$PATH:/opt/nvim-linux64/bin"
alias neovide="neovide --frame none"

# Node 
export NVM_DIR="/home/michal/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Hurl
function hurl {
  command hurl "$@" | jq
}

# Utils
function clear-scrollback-buffer {
  # Behavior of clear: 
  # 1. clear scrollback if E3 cap is supported (terminal, platform specific)
  # 2. then clear visible screen
  # For some terminal 'e[3J' need to be sent explicitly to clear scrollback
  clear && printf '\e[3J'
  # .reset-prompt: bypass the zsh-syntax-highlighting wrapper
  # https://github.com/sorin-ionescu/prezto/issues/1026
  # https://github.com/zsh-users/zsh-autosuggestions/issues/107#issuecomment-183824034
  # -R: redisplay the prompt to avoid old prompts being eaten up
  # https://github.com/Powerlevel9k/powerlevel9k/pull/1176#discussion_r299303453
  zle && zle .reset-prompt && zle -R
}

zle -N clear-scrollback-buffer
bindkey '^L' clear-scrollback-buffer


# Starship
eval "$(starship init zsh)"
# Zoxide
eval "$(zoxide init zsh)"

# Created by `pipx` on 2024-03-14 08:04:57
export PATH="$PATH:/home/michal/.local/bin"
