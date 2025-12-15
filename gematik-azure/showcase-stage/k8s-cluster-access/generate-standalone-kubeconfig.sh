#!/usr/bin/env bash

# abort when first error occurs
set -o pipefail
set -o errexit
set -o nounset

# Edit the variables below as needed.
# DURATION must be in HOURS.
# The resulting kubeconfig is written to $OUT.
#
# Note: The cluster might cap token lifetime regardless of DURATION.

# ====== Editable variables (env-overridable) ==================================
# override via env, e.g.:
#   NS=zeta-staging SA=reader bash generate-standalone-kubeconfig.sh
NS="${NS:-ci}"                                # target namespace (default CI namespace)
SA="${SA:-ci}"                                # service account (default CI)
DURATION="${DURATION:-720h}"                  # token TTL, in hours (e.g., 24h=1d, 168h=7d, 720=30d)
OUT="${OUT:-${NS}-${SA}-zeta-kubeconfig}"     # output file name
# ==============================================================================

# Pull cluster API server & CA from current context
SERVER="$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')"
CA="$(kubectl config view --raw --minify -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')"

# Request short-lived token for the ServiceAccount
TOKEN="$(kubectl -n "$NS" create token "$SA" --duration="$DURATION")"

# Ensure we start fresh: remove existing kubeconfig file if present
if [ -e "$OUT" ]; then
  echo "✅ Existing kubeconfig found, deleting: $OUT"
  rm -f -- "$OUT"
fi

# Write kubeconfig
cat >"$OUT" <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${CA}
    server: ${SERVER}
  name: aks
contexts:
- context:
    cluster: aks
    user: ${NS}-${SA}
    namespace: ${NS}
  name: ${NS}
current-context: ${NS}
users:
- name: ${NS}-${SA}
  user:
    token: ${TOKEN}
EOF

echo "✅ Kubeconfig written: $OUT"
echo "Namespace: $NS | ServiceAccount: $SA"
echo "Requested token duration: $DURATION"
echo "Use it like:"
echo "  KUBECONFIG=$OUT kubectl get pods -n $NS"
