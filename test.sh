#!/bin/bash
#
# Run helm on docker
#
set -e

if [ -z "$KUBECONFIGONDOCKER" ]; then
  >&2 echo "Please make sure KUBECONFIGONDOCKER exists."
  >&2 echo "It should contain something like:"
  >&2 echo "~/.kubeconfig/gke.yml:/root/.kube/xyz.yml"
  exit 1
fi

docker run -e KUBECONFIG="$KUBECONFIGONDOCKER" -ti --rm -v $(pwd):/apps -v ~/.kube:/root/.kube -v ~/.config/helm:/root/.config/helm -v ~/.cache/helm:/root/.cache/helm -v ~/.helm:/root/.helm alpine/helm "$@"

