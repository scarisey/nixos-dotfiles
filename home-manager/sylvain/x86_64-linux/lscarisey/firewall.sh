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
  ufw reset
  ufw default allow outgoing
  ufw default allow forward
  ufw default deny incoming
  ufw allow ssh
  ufw limit ssh
  ufw allow http
  ufw allow https
  ufw allow 53 #waydroid
  ufw allow 67 #waydroid
}

_requirements
_checkCommand $@
$@
