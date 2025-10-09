# ZETA-showcase-Stage

Initial Steps

* install terraform
    * https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
* install azure-cli
    * `brew install azure-cli`
* `az login`
    * probably: `az account set --subscription "SUBSCRIPTION_ID"`
* set azure subscription id in `var-envs/common.tfvars`

Terraform:

* initialise: `terraform init`
* plan: `terraform plan -var-file=../var-envs/common.tfvars -out plan.out`
* apply: `terraform apply plan.out`
* formatter: `terraform fmt -recursive`
* validate code: `terraform validate`

# What this repo does

* bootstrap-tfstate: creates Resource Group + Storage Account + tfstate container with secure defaults (AAD-only, soft
  delete, versioning). Runs once with local state.
* showcase-stage: provisions a minimal AKS cluster; uses the remote state in the storage account created above.

# Prerequisites

* Terraform ≥ 1.6
* Azure CLI logged in: az login (or use SPN/OIDC in CI)
* Rights: Contributor on subscription. For state backend, assign Storage Blob Data Contributor (RBAC) to user/SPN on the
  storage account.

# Get-Started

### Bootstrap remote state (local state) -> only in initial-mode

see  [bootstrap-tfstate](bootstrap-tfstate/README.md)

## Wire up remote backend for AKS

```
cd showcase-stage
terraform init -backend-config=backend.hcl
# Or when changes in Backend:
terraform init -reconfigure -backend-config=backend.hcl
terraform plan -var-file=../var-envs/common.tfvars -out plan.out
terraform apply plan.out
```

## Get kubeconfig and verify

```
az aks get-credentials -g $(terraform output -raw resource_group) -n $(terraform output -raw aks_name) --overwrite-existing
# or 
az aks get-credentials -g gematik-zeta-dev-stage -n zeta-dev-aks --overwrite-existing 
kubectl get nodes

# Demo app note: Terraform already deploys a demo nginx app in namespace "demo-ui" with a LoadBalancer Service.
# Watch for the external IP once nodes are ready:
kubectl get svc -n demo-ui -w
```
