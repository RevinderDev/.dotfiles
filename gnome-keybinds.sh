#!/usr/bin/env zsh

add_gnome_keybind() {
    local NAME="$1"
    local CMD="$2"
    local BIND="$3"

    # Generate a unique path slug using Zsh parameter expansion
    local SLUG="${(L)NAME//[^a-zA-Z0-9]/_}"
    local KEY_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${SLUG}/"

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH name "$NAME"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH command "$CMD"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH binding "$BIND"

    # Fetch current array of custom keybindings to avoid duplicates.
    local EXISTING
    EXISTING=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

    if [[ "$EXISTING" == *"${KEY_PATH}"* ]]; then
        print -r "Updated existing shortcut: $NAME"
        return 0
    fi

    # Safely append new path to the GNOME array
    local NEW_LIST
    if [[ "$EXISTING" == "@as []" ]] || [[ "$EXISTING" == "[]" ]]; then
        NEW_LIST="['$KEY_PATH']"
    else
        NEW_LIST="${EXISTING%]*}, '$KEY_PATH']"
    fi

    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$NEW_LIST"
    print -r "Successfully added shortcut: $NAME ($BIND)"
}

# Execute keybinding calls
add_gnome_keybind "Flameshot" 'sh -c "QT_QPA_PLATFORM=wayland flameshot gui"' "<Shift><Super>s"
add_gnome_keybind "Ulauncher" "ulauncher-toggle" "<Super>g"
