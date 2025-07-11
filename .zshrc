# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="gallois"
SOLARIZED_THEME="dark"
export BAT_THEME="gruvbox-dark"

gsettings set org.gnome.desktop.interface enable-animations false

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
	poetry
	zoxide
)

source $ZSH/oh-my-zsh.sh
export FZF_BASE=/usr/bin/fzf

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#989898,bold"
bindkey '^ ' autosuggest-accept

alias ls="eza -a -l --header --icons --time-style relative --group-directories-first"
alias lg="lazygit"
alias img="wezterm imgcat $@"


# Zellij
export ZELLIJ_CONFIG_FILE=~/.config/zellij/config.kdl


# Golang
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/go/bin

# Neovim
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
alias neovide="neovide --fork --frame none"
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"

# Node 
export NVM_DIR="/home/michal/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Hurl
function hurljq {
  command hurl "$@" | jq
}

function hurlcsv {
  command hurl "$@" | csvlook 
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

alias python="python3"
# Starship
eval "$(starship init zsh)"
# Zoxide
eval "$(zoxide init zsh)"

export PATH="$PATH:/home/michal/.local/bin"
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
