#!/usr/bin/env bash
#set -euxo pipefail
set -euo pipefail

SCRIPTNAME=$(basename "$0")
RUNDIR=$(dirname "$(realpath $0)")
CURRENTDIR=$(pwd)

REVEALJS_THEME="white"
REVEALJS_CDN=https://cdn.jsdelivr.net/npm/reveal.js@4.1.2
ASCIIDOCTOR_OPTS_WITH_IMAGE="-a data-uri"
ASCIIDOCTOR_OPTS_REVEALJS="-a revealjs_theme=${REVEALJS_THEME} -a revealjsdir=${REVEALJS_CDN} -a revealjs_slideNumber=h.v -a revealjs_mouseWheel=true -a revealjs_transition=fade"

function _usage() {
	echo "USAGE"
	echo "${SCRIPTNAME} prez [args for revealjs]"
	echo "${SCRIPTNAME} adoc [args for asciidoctor]"
	exit 1
}

function _requirements() {
	if ! command -v docker &>/dev/null; then
		echo "docker could not be found"
		exit
	fi
}

function _checkCommand() {
	case ${1:-''} in
	prez) ;;
	adoc) ;;
	*)
		_usage
		exit 1
		;;
	esac
}

function _dockerRun() {
	docker run -it -u $(id -u):$(id -g) -v ${CURRENTDIR}:/documents/ asciidoctor/docker-asciidoctor $@
}

function prez() {
	_dockerRun asciidoctor-revealjs ${ASCIIDOCTOR_OPTS_REVEALJS} ${ASCIIDOCTOR_OPTS_WITH_IMAGE} $@
}

function adoc() {
	_dockerRun asciidoctor ${ASCIIDOCTOR_OPTS_WITH_IMAGE} $@
}

_requirements
_checkCommand $@
$@
