#!/bin/bash

set -euo pipefail

./build.sh $1
for i in $(podman images --format='{{.Repository}}:{{.Tag}}' | grep localhost/ubuntu-server-dev | tr '\n' ' ' | sed 's;localhost/;ghcr.io/seagl/ubuntu-server-dev/;g'); do
	podman push ubuntu-server-dev:$1 $i
done
