#!/bin/bash

set -e

# Пошук активного користувача GNOME
USER_NAME=$(loginctl list-sessions --no-legend | awk '$3 != "" {print $3; exit}')

if [ -z "$USER_NAME" ]; then
    echo "Не знайдено активного користувача."
    exit 1
fi

USER_UID=$(id -u "$USER_NAME")

export XDG_RUNTIME_DIR="/run/user/$USER_UID"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

run_gsettings() {
    sudo -u "$USER_NAME" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
    gsettings set "$@"
}

echo "Налаштовую політику енергозбереження для користувача $USER_NAME"

run_gsettings org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 900
run_gsettings org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type suspend

run_gsettings org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 900
run_gsettings org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type suspend

run_gsettings org.gnome.desktop.session idle-delay "uint32 900"

run_gsettings org.gnome.desktop.screensaver lock-enabled true

# Для Ubuntu
if sudo -u "$USER_NAME" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
    gsettings writable org.gnome.desktop.screensaver ubuntu-lock-on-suspend >/dev/null 2>&1; then

    run_gsettings org.gnome.desktop.screensaver ubuntu-lock-on-suspend true
fi

echo "Готово."
