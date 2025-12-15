# Access to kubernetes-cluster (namespaced ServiceAccount, no Azure account)

Give external partners access to **only their namespace** on AKS cluster using
Kubernetes **service accounts + RBAC**. Developers receive a **standalone kubeconfig**
and do **not** need Azure credentials.

> ⚠️ The generated kubeconfig contains a bearer token. Treat it like a secret (ignored in git).

---

## Prerequisites

- Can run `kubectl` against the cluster with sufficient rights (cluster-admin).
- This folder contains:
    - [zeta-dev-access-writer.yaml](zeta-dev-access-writer.yaml) – namespace, service account,
      Role/RoleBinding (writer),
      and ResourceQuota/LimitRange.
    - [generate-standalone-kubeconfig.sh](generate-standalone-kubeconfig.sh) – creates a kubeconfig for the
      service account

---

## Step 1 — Apply namespace & RBAC

Apply the provided RBAC manifest (adjust the file name and namespace if needed).

## registry-secret (imagePullSecrets)

### create secret

_**HINT:** This is a temporary way to create registry-secret -> later External Secrets + Secret-Store: Azure Key Vault
and External Secrets
Operator_

```shell
# creates a secret for a specific namespace, used to pull images from the
# registry inside the cluster 
kubectl -n <NAMESPACE> create secret docker-registry gitlab-registry-credentials-zeta-group \
    --docker-server=registry.tas-devtools-gitlab.spree.de:443 \
    --docker-username=<TOKEN-NAME> \
    --docker-password=<PAT> \
    --docker-email=zeta-k8s-admin@spree.de 
```

### Specifying on a deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata: { ... }
spec:
  selector: { ... }
  template:
    metadata: { ... }
    spec:
      containers:
        - name: ...
      imagePullSecrets:
        - name: registry-credentials
```

### Writer profile (deploy rights)

```bash
kubectl apply -f zeta-dev-access-writer.yaml
```

### Verify

```bash
kubectl -n zetadev get sa,role,rolebinding,resourcequota,limitrange
# Expect at least: sa/deployer, role/deployer-write, rolebinding/deployer-binding
```

## Step 2 — Generate a standalone kubeconfig (script)

Use the provided script to create a kubeconfig bound to the service account and namespace.

```bash
chmod +x generate-standalone-kubeconfig.sh
./generate-standalone-kubeconfig.sh
```

What the script does:

- Reads API server URL and cluster CA from your current kube context.
- Requests a short-lived token for the service account.
- Writes a kubeconfig with the context defaulted to the target namespace.

---

## Step 3 — Handoff to the developer (usage)

Share the kubeconfig securely (e.g. via 1password or xchange).

```bash
# One-off usage in developer’s shell
KUBECONFIG=zetadev-deployer-zeta-kubeconfig get deploy,svc -n zetadev
KUBECONFIG=zetadev-deployer-zeta-kubeconfig kubectl apply -f myapp.yaml -n zetadev

# Or export for the session
export KUBECONFIG=[PATH_TO_CONFIG]/zetadev-deployer-zeta-kubeconfig
kubectl get pod,deploy,svc,rs -n zetadev
```

---

## Step 4 — Rotate tokens or revoke access

**Rotate tokens** (issue a fresh token/kubeconfig):

```bash
./generate-standalone-kubeconfig.sh
```

**Revoke immediately** (choose one):

```bash
# Fast: remove RoleBinding
kubectl delete rolebinding deployer-binding -n zetadev

# Stricter: remove the service account
kubectl delete sa deployer -n zetadev

# Nuclear option: remove the whole namespace (deletes everything inside)
kubectl delete ns zetadev
```

---

## Troubleshooting

```bash
# Token expired → regenerate
# Unauthorized (401)
./generate-standalone-kubeconfig.sh

# Missing permissions → adjust Role rules and re-apply
# Forbidden (403)
kubectl -n zetadev get role,rolebinding

# Wrong namespace/resource
# NotFound
kubectl -n zetadev get all
```

---

## Port-forwarding

The writer role allows port-forwarding to pods and services in the namespace.

```bash
# Pod example
kubectl -n [NAMESPACE] port-forward pod/[POD-NAME] 8080:80 

# Service example
kubectl -n [NAMESPACE] port-forward svc/[SERVICE-NAME] 8080:80 

# open http://localhost:8080
```
