# My personal dotfiles for

<p align="center">
    <img src=".github/Desktop.png">
</p>

## Installation
1. Install stow and initialize (`stow .`)
2. Install this [Iosevka](https://typeof.net/Iosevka/) or [JetbrainsMono](https://www.jetbrains.com/lp/mono/)
3. Upgrade paths in .gitconfig

## Additional tools:

In all honesty, cba writing platform dependend tools so it's going to stay
this way and you will have to install everything manually. Not like you do this often.


#### Python
* pyenv
* pipx (eg. `$ pipx install youtube-dl`)
* pipenv

#### Rust 
* rustup
* cargo
* rustc

For rest of the setup look at `.cargo`


#### Development
* lazygit
* git
* nvim
* lua

#### Shell related
* oh-my-zsh
* Starhsip sh -c "$(curl -fsSL https://starship.rs/install.sh)"
* zoxide

## TODO

1. Rewrite nvims `vimscript` in `lua` and update it removing unnecessary plugins.
2. Automization of installing and updating all necessary paths and whatnot.
3. Write better readme.
4. Add screenshot showcasing awesomeness.
5. Delete old configs.