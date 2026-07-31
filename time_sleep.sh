#!/bin/bash

set -e

USER_NAME=$(loginctl list-sessions --no-legend | awk '$6=="active" {print $3; exit}')

if [ -z "$USER_NAME" ]; then
    echo 0
    exit 1
fi

USER_ID=$(id -u "$USER_NAME")

CURRENT=$(sudo -u "$USER_NAME" \
DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" \
gsettings get org.gnome.desktop.session idle-delay)

# Якщо вже встановлено
if [ "$CURRENT" = "uint32 900" ]; then
    echo 1
    exit 0
fi


# Встановлення правила
sudo -u "$USER_NAME" \
DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" \
gsettings set org.gnome.desktop.session idle-delay 900


# Перевірка після зміни
if CHECK=$(sudo -u "$USER_NAME" \
DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" \
gsettings get org.gnome.desktop.session idle-delay 2>/dev/null); then

    if [ "$CHECK" = "uint32 900" ]; then
        echo 1
    else
        echo 0
    fi

else
    echo 0
fi
