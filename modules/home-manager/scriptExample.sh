#!/usr/bin/env bash

#set -euxo pipefail
set -euo pipefail

SCRIPTNAME=$(basename "$0")
RUNDIR=$(dirname "$(realpath $0)")
CURRENTDIR=$(pwd)
OUTPUTDIR=${CURRENTDIR}/out

mkdir -p $OUTPUTDIR

function _usage() {
	echo "USAGE"
	echo "${SCRIPTNAME} foo"
	echo "${SCRIPTNAME} bar aFile.json"
	exit 1
}

function _requirements() {
	if ! command -v jq &>/dev/null; then
		echo "jq could not be found"
		exit
	fi
}

function _checkCommand() {
	case ${1:-''} in
	completions) ;;
	foo) ;;
	bar) ;;
	*)
		_usage
		exit 1
		;;
	esac
}

function _checkArg() {
	if [ -z ${1:-''} ]; then
		_usage
		exit 1
	fi
}

function foo() {
	echo foo
}

function uuid() {
	cat /proc/sys/kernel/random/uuid
}

function bar() {
	_checkArg $1
	jq --unbuffered -c '.[]' $1 >$OUTPUTDIR/$1
}

_requirements
_checkCommand $@
$@
