#!/usr/bin/env bash

set -euo pipefail

SCRIPTNAME=$(basename "$0")
RUNDIR=$(dirname "$(realpath $0)")
CURRENTDIR=$(pwd)

function _usage() {
  echo "USAGE"
  echo "${SCRIPTNAME} defaults"
  exit 1
}

function _requirements() {
  if ! command -v ufw &>/dev/null; then
    echo "ufw could not be found"
    exit
  fi
}

function _checkCommand() {
  case ${1:-''} in
  defaults) ;;
  *)
    _usage
    exit 1
    ;;
  esac
}

function defaults {
  sudo -v
  sudo ufw reset
  sudo ufw default allow outgoing
  sudo ufw default allow forward
  sudo ufw default deny incoming
  sudo ufw allow ssh
  sudo ufw limit ssh
  sudo ufw allow http
  sudo ufw allow https
  sudo ufw allow 53 #waydroid
  sudo ufw allow 67 #waydroid
  sudo ufw allow 2049/tcp #nfs
  sudo ufw allow nfs
  sudo ufw enable
}

_requirements
_checkCommand $@
$@
