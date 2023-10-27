#!/bin/bash

# Wait for kwallet
kwallet-query -l kdewallet >/dev/null

for KEY in $(ls $HOME/.ssh/id_ecdsa* | grep -v \.pub); do
	ssh-add -q ${KEY} </dev/null
done
