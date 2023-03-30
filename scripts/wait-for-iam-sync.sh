#!/usr/bin/env bash

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

if [[ -z "${KUBECONFIG}" ]]; then
  exit 0
fi

USERNAME=$(kubectl config current-context | sed -E "s~.*/(.+)~\1~g")

echo "Checking for user: $USERNAME"

echo "Waiting for role bindings for user: $USERNAME"

function role_binding_count {
  local name="$1"

  local length=$(kubectl get clusterrolebinding -o json | jq --arg NAME "${name}" '[.items[] | select(.metadata.name | test("ibm-admin|ibm-edit|ibm-view")) | .subjects[] | select(.name | test($NAME))] | length')

  echo "${length}"
}

count=0
until [[ $(role_binding_count "${USERNAME}") -gt 0 ]] || [[ $count -eq 40 ]]; do
  count=$((count + 1))
  echo "  Waiting for 30 seconds"
  sleep 30
done

if [[ $count -eq 40 ]]; then
  echo "Timed out waiting for role bindings: $USERNAME" >&2
  exit 1
else
  echo "  Found role bindings for user: $USERNAME"
fi
