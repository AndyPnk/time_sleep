#!/bin/bash

set -e

URL="https://raw.githubusercontent.com/AndyPnk/time_sleep/main/time_sleep.sh"

echo "Downloading and running latest version..."

wget -qO- "$URL" | sudo bash

RET=$?

exit $RET
