resource_group_name  = "rg-zeta-tfstate-westeurope"
# replace storage_account_name from output of bootstrap-tfstate (in initial-mode: fresh environment, without tfstate)
storage_account_name = "sttfstatewesteuropeg1ju9"
container_name       = "zeta-tfstate"
key                  = "showcase/aks/terraform.tfstate"

