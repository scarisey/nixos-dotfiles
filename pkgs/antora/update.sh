#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nodejs libarchive prefetch-npm-deps moreutils jq
# shellcheck shell=bash

set -euxo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

TMPDIR="$(mktemp -d)"
trap 'rm -r -- "$TMPDIR"' EXIT

pushd -- "$TMPDIR"

npm pack antora --json | jq '.[0]|{version,integrity,filename}' >source.json
bsdtar -x -f "$(jq -r .filename source.json)"

pushd package
npm i --package-lock-only '@sntke/antora-mermaid-extension'
npm i --package-lock-only '@antora/lunr-extension'
npm install --omit=optional --package-lock-only
popd

DEPS="$(prefetch-npm-deps package/package-lock.json)"
jq ".deps = \"$DEPS\"" source.json | sponge source.json

popd

cp -t . -- "$TMPDIR/source.json" "$TMPDIR/package/package-lock.json"
