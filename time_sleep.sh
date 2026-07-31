#!/bin/bash

set -e

# Знаходимо активну графічну сесію
SESSION=$(loginctl list-sessions --no-legend | awk '$4=="seat0"{print $1; exit}')

if [ -z "$SESSION" ]; then
    echo 0
    exit 1
fi

USER_NAME=$(loginctl show-session "$SESSION" -p Name --value)

if [ -z "$USER_NAME" ]; then
    echo 0
    exit 1
fi

USER_ID=$(id -u "$USER_NAME")

CURRENT=$(sudo -u "$USER_NAME" \
env XDG_RUNTIME_DIR="/run/user/$USER_ID" \
DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" \
gsettings get org.gnome.desktop.session idle-delay)

# Якщо вже встановлено
if [ "$CURRENT" = "uint32 900" ]; then
    echo 1
    exit 0
fi

# Встановлення правила
sudo -u "$USER_NAME" \
env XDG_RUNTIME_DIR="/run/user/$USER_ID" \
DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" \
gsettings set org.gnome.desktop.session idle-delay 900

# Перевірка після зміни
CHECK=$(sudo -u "$USER_NAME" \
env XDG_RUNTIME_DIR="/run/user/$USER_ID" \
DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" \
gsettings get org.gnome.desktop.session idle-delay 2>/dev/null)

if [ "$CHECK" = "uint32 900" ]; then
    echo 1
else
    echo 0
fi
