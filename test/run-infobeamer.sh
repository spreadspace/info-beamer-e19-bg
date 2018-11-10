#!/bin/bash

export INFOBEAMER_ENV_SERIAL=${1:-1234567890}
if [ -n "$2" ]; then
  export INFOBEAMER_WIDTH=$2
fi
if [ -n "$3" ]; then
  export INFOBEAMER_HEIGHT=$3
fi

BASE_D=$(realpath "${BASH_SOURCE%/*}/..")
if [ ! -e "$BASE_D/config.json" ]; then
  echo '{ "style": "fancy" }' > "$BASE_D/config.json"
fi
exec info-beamer "$BASE_D"
