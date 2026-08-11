# CLI Tools
# Repository for Flameshot
sudo add-apt-repository ppa:quentiumyt/flameshot
sudo apt install -y fzf fd-find flameshot xclip

# ZSH
sudo apt install zsh
# Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Oh-My-Zsh Plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions.git ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions

# Ulauncher
sudo add-apt-repository universe -y && sudo add-apt-repository ppa:agornostal/ulauncher -y && sudo apt update && sudo apt install ulauncher

# UV Python package manager
curl -LsSf https://astral.sh/uv/install.sh | sh

uv tool install black
uv tool install csvkit
uv tool install sqlparse
uv tool install ruff-lsp
uv tool install pyright

# Starship
curl -sS https://starship.rs/install.sh | sh

# Ghostty
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"

# Neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

# Mise and then install tools from mise/config.toml
curl https://mise.run | sh
