OE: MBO-Team
Schutzbedarf: Hoch

# ZETA-showcase-Stage

Initial Steps

* install terraform
    * https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
* install azure-cli
    * `brew install azure-cli`
* `az login`
    * probably: `az account set --subscription "SUBSCRIPTION_ID"`

terraform:

* initialise: `terraform init`
* plan: `terraform plan -var-file=../var-envs/common.tfvars -out plan.out`
* apply: `terraform apply plan.out`
* formatter: `terraform fmt -recursive`
* validate code: `terraform validate`

# What this repo does

* creates Resource Group + Storage Account + tfstate container with secure defaults (AAD-only, soft
  delete, versioning). Runs once with local state.

# Prerequisites

* Terraform ≥ 1.6
* Azure CLI logged in: az login (or use SPN/OIDC in CI)
* Rights: Contributor on subscription. For state backend, assign Storage Blob Data Contributor (RBAC) to user/SPN on the
  storage account.

# Get-Started

## 1) Bootstrap remote state (local state)

*WARNING* run this module only if there is no existing storage-account for tf-state in log-group "
rg-zeta-tfstate-westeurope" -> Initial-mode (new azure-subscription)

The state of this module is not persisted anywhere, so a new storage account will be created in every run/apply

```
cd bootstrap-tfstate
terraform init
terraform plan -var-file=../var-envs/common.tfvars -out plan.out
terraform apply plan.out
# Save output (RG, SA, Container) -> will be used in next step
```

## 2) Setup backend.hcl

```touch backend.hcl```

put the following content in **backend.hcl**-file

```
resource_group_name  = "rg-zeta-tfstate-westeurope"
# replace storage_account_name from output of bootstrap-tfstate (in initial-mode: fresh environment, without tfstate)
storage_account_name = "[STORAGE_ACCOUNT_NAME]"
container_name       = "zeta-tfstate"
key                  = "showcase/aks/terraform.tfstate"

# Use AAD; no storage keys needed
use_azuread_auth     = true

```

# Useful cases

## 1) importing existing resources

when trying to adjust/extend this project without exisitng tfstate-file, terraform will try to re-create the resources
even they already exists in azure

````
# import resource-group
terraform import -var-file=../var-envs/common.tfvars azurerm_resource_group.state_resource_group /subscriptions/[SUBSCRIPTION_ID]/resourceGroups/[RESOURCES_GROUP_NAME]

# import storage-account
terraform import -var-file=../var-envs/common.tfvars azurerm_storage_account.state_storage_account /subscriptions/[SUBSCRIPTION_ID]/resourceGroups/[RESOURCES_GROUP_NAME]/providers/Microsoft.Storage/storageAccounts/[STORAGE_ACCOUNTT_NAME]

# import container
terraform import -var-file=../var-envs/common.tfvars azurerm_storage_container.state_container /subscriptions/[SUBSCRIPTION_ID]/resourceGroups/[RESOURCES_GROUP_NAME]/providers/Microsoft.Storage/storageAccounts/[STORAGE_ACCOUNTT_NAME]/blobServices/default/containers/[CONTAINER_NAME]

# role_assignment won't be imported, workaround: comment out the resource
"azurerm_role_assignment" "current_blob_contrib" {
..
}

````
