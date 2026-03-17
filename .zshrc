# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="gallois"
SOLARIZED_THEME="dark"
export BAT_THEME="gruvbox-dark"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#989898,bold"

gsettings set org.gnome.desktop.interface enable-animations false

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
autoload -U compinit && compinit

# Mise
eval "$(~/.local/bin/mise activate zsh)"

plugins=(
	zsh-autosuggestions
	zsh-syntax-highlighting
	zsh-completions
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

#                                
# ===================================================
#    ▄▄▄  ▄▄▄           ▄▄       
#    ███  ███  ██   ▀▀  ██       
#    ███  ███ ▀██▀▀ ██  ██ ▄█▀▀▀ 
#    ███▄▄███  ██   ██  ██ ▀███▄ 
#    ▀██████▀  ██   ██▄ ██ ▄▄▄█▀ 
#                                
#                                

# Hurl
function hurljq {
  command hurl "$@" | jq
}

function hurlcsv {
  command hurl "$@" | csvlook 
}

function echo_red() {
    echo -e "\033[31m$*\033[0m"
}

function echo_green() {
    echo -e "\033[32m$*\033[0m"
}

function echo_yellow() {
    echo -e "\033[33m$*\033[0m"
}

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
bindkey '^ ' autosuggest-accept

alias ls="eza -a -l --header --icons --time-style relative --group-directories-first"
alias img="wezterm imgcat $@"
# ===================================================

# ===================================================
#                        
#     ▄▄▄▄▄▄▄            
#    ███▀▀▀▀▀  ▀▀   ██   
#    ███       ██  ▀██▀▀ 
#    ███  ███▀ ██   ██   
#    ▀██████▀  ██▄  ██   
#                        
#                        
alias lg="lazygit"
# AI-powered Git Commit Function Source: https://gist.github.com/karpathy/1dd0294ef9567971c1e4348a90d69285
# 1) gets the current staged changed diff
# 2) sends them to an LLM to write the git commit message
# 3) allows you to easily accept, edit, regenerate, cancel
# But - just read and edit the code however you like
function gitc() {
    # Function to generate commit message
    function generate_commit_message() {
            git diff --cached | llm -m openrouter/minimax/minimax-m2.5 "
        You are an automated, non-interactive Git commit message generation machine. You are part of a shell pipeline. Your ONLY purpose is to read a git diff and output raw text. 

        UNDER NO CIRCUMSTANCES should you ask questions, make suggestions, or converse. If you see garbage, debugging code, or errors in the diff, ignore them and simply document what was added or removed.

        Analyze the diff and generate a commit message following the Conventional Commits specification.

        STRICT RULES:
        1. Identify the PRIMARY change to determine the commit type (feat, fix, docs, style, refactor, perf, test, chore).
        2. Write a subject line (max 50 chars): <type>(<optional scope>): <short description>.
        3. Leave exactly one blank line after the subject.
        4. Write a detailed body explaining the motivation for the main change and listing secondary changes.
        5. NO MARKDOWN. Do not use backticks (\`\`\`).
        6. NO CONVERSATION. Do not output anything like 'Here is the commit' or 'Would you like to change this?'.

        OUTPUT TEMPLATE:
        <type>(<scope>): <subject>

        <body>

        DIFF TO ANALYZE:
        "
    }

    # Function to read user input compatibly with both Bash and Zsh
    function read_input() {
        if [ -n "$ZSH_VERSION" ]; then
            echo -n "$1"
            read -r REPLY
        else
            read -p "$1" -r REPLY
        fi
    }

    # Main script
    echo "🤖 Generating AI-powered commit message..."
    commit_message=$(generate_commit_message)

    if [ $? -ne 0 ] || [ -z "$commit_message" ]; then
        echo_red "Error: Failed to generate commit message. Exiting."
        return 1
    fi

    while true; do
        echo -e "\nProposed commit message:\n"
        echo "$commit_message"

        read_input "\nDo you want to (a)ccept, (e)dit, (r)egenerate, or (c)ancel? "
        choice=$REPLY

        case "$choice" in
            a|A )
                if git commit -m "$commit_message"; then
                    echo_green "\n✅ Changes committed successfully!"
                    return 0
                else
                    echo_red "Commit failed. Please check your changes and try again."
                    return 1
                fi
                ;;
            e|E )
                # Create a temporary file to hold the commit message
                tmp_file=$(mktemp)
                echo "$commit_message" > "$tmp_file"
                
                # Open the file in nvim
                nvim "$tmp_file"
                
                # Read the edited message back and clean up the temp file
                commit_message=$(cat "$tmp_file")
                rm -f "$tmp_file"

                # Abort if the user deleted all text in the editor
                if [ -z "$commit_message" ]; then
                    echo_yellow "\nCommit message is empty. Commit cancelled."
                    return 1
                fi

                if git commit -m "$commit_message"; then
                    echo_green "\n✅ Changes committed successfully with your edited message!"
                    return 0
                else
                    echo_red "\nCommit failed. Please check your message and try again."
                    return 1
                fi
                ;;
            r|R )
                echo "Regenerating commit message..."
                commit_message=$(generate_commit_message)
                ;;
            c|C )
                echo_yellow "Commit cancelled."
                return 1
                ;;
            * )
                echo_red "Invalid choice. Please try again."
                ;;
        esac
    done
}
# ===================================================

# ===================================================
#                                       
#    ▄▄▄▄▄▄▄▄▄                          
#    ▀▀▀███▀▀▀ ▀▀                       
#       ███    ██  ███▄███▄ ▄█▀█▄ ████▄ 
#       ███    ██  ██ ██ ██ ██▄█▀ ██ ▀▀ 
#       ███    ██▄ ██ ██ ██ ▀█▄▄▄ ██    
#                                       
#                                       
typeset -A pomo_options
pomo_options[work]="25"
pomo_options[break]="5"

function pomodoro() {
  local session_type="$1"
  
  if [[ -n "$session_type" && -n "${pomo_options[$session_type]}" ]]; then
    echo "Pomodoro: $session_type" 
    timer "${pomo_options[$session_type]}m"
    notify-send "'$session_type' session done"
  else
    echo "Invalid pomodoro session type. Use 'work' or 'break'."
  fi
}

alias workdo='pomodoro work'
alias workbreak='pomodoro break'

# ===================================================
#                                                           
#      ▄▄▄▄   ▄▄▄▄▄▄▄   ▄▄▄▄▄   ▄▄▄   ▄▄▄                   
#    ▄██▀▀██▄ ███▀▀███▄  ███    ███ ▄███▀                   
#    ███  ███ ███▄▄███▀  ███    ███████   ▄█▀█▄ ██ ██ ▄█▀▀▀ 
#    ███▀▀███ ███▀▀▀▀    ███    ███▀███▄  ██▄█▀ ██▄██ ▀███▄ 
#    ███  ███ ███       ▄███▄   ███  ▀███ ▀█▄▄▄  ▀██▀ ▄▄▄█▀ 
#                                                 ██        
#                                               ▀▀▀         

# --- Configuration ---
typeset -g secret_file="$HOME/secrets.sh"
typeset -g secret_asc="$HOME/secrets.sh.asc"
typeset -g gpg_id="michal0kasprzyk@gmail.com"

# --- Functions ---

# Decrypts the .asc file back to a plain text file (for editing)
secrets_decrypt() {
    if [[ ! -f "$secret_asc" ]]; then
        print -P "%F{red}Error:%f $secret_asc not found."
        return 1
    fi
    gpg --decrypt --output "$secret_file" "$secret_asc"
    print -P "%F{yellow}Unlocked:%f $secret_file is now available for editing."
}

# Encrypts the plain text file and removes the original
secrets_encrypt() {
    if [[ ! -f "$secret_file" ]]; then
        print -P "%F{red}Error:%f $secret_file not found to encrypt."
        return 1
    fi
    # -e (encrypt), -a (ascii armor), -r (recipient), --yes (overwrite existing .asc)
    gpg -ea -r "$gpg_id" --yes --output "$secret_asc" "$secret_file"
    rm "$secret_file"
    print -P "%F{green}Locked:%f $secret_file encrypted to $secret_asc and removed."
}

load_secrets() {
    local ram_tmp="/dev/shm/secrets_tmp_${UID}"
    local -a loaded_keys  

    if [[ ! -f "$secret_asc" ]]; then
        print -P "%F{red}Error:%f Encrypted file not found at $secret_asc"
        return 1
    fi

    # Decrypt directly to RAM
    if ! gpg --quiet --decrypt "$secret_asc" > "$ram_tmp" 2>/dev/null; then
        print -P "%F{red}Error:%f Decryption failed (check your GPG agent/passphrase)."
        [[ -f "$ram_tmp" ]] && rm -f "$ram_tmp"
        return 1
    fi

    # Parse names using ZSH parameter expansion
    for line in ${(f)"$(< $ram_tmp)"}; do
        if [[ $line == export\ * ]]; then
            # Strip 'export ' and everything after '='
            local var_name=${${line#export }%%=*}
            loaded_keys+=($var_name)
        fi
    done

    source "$ram_tmp"
    rm -f "$ram_tmp"

    print -P "%F{green}✅ Secrets loaded into environment:%f"
    for key in $loaded_keys; do
        print -P "  %F{blue}-%f $key"
    done
}
# ===================================================

alias python="python3"
export PATH="$PATH:/home/michal/.local/bin"
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"

# ===================================================

# pnpm
export PNPM_HOME="/home/michal/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Zoxide
eval "$(zoxide init zsh)"
