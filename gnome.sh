sudo apt install -y gnome-tweak-tool
uv tool install gnome-extensions-cli

gsettings set org.gnome.desktop.interface enable-animations false

# Turn off default Ubuntu extensions
gnome-extensions disable tiling-assistant@ubuntu.com
gnome-extensions disable ubuntu-appindicators@ubuntu.com
gnome-extensions disable ubuntu-dock@ubuntu.com
gnome-extensions disable ding@rastersoft.com

# Install new extensions
gext install AlphabeticalAppGrid@stuarthayhurst
gext install gTile@vibou
gext install just-perfection-desktop@just-perfection
gext install openbar@neuromorph
gext install rounded-window-corners@fxgn
gext install space-bar@luchrioh
gext install task-widget@juozasmiskinis.gitlab.io
gext install tophat@fflewddur.github.io
gext install undecorate@sun.wxg@gmail.com
gext install useless-gaps@pimsnel.com
