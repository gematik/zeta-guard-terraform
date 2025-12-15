## Defaults (override on CLI: make kubeconfig NS=zeta-staging SA=reader)
NS ?= zeta-staging
SA ?= reader
DURATION ?= 1440h
OUT ?= $(NS)-$(SA)-zeta-kubeconfig
MANIFEST ?= zeta-ey-access-reader.yaml

.PHONY: help apply apply-reader apply-deployer apply-ci kubeconfig kubeconfig-reader kubeconfig-deployer kubeconfig-ci kubeconfig-ci-b64

	help:
		@echo "Targets:"
		@echo "  make apply                 # kubectl apply -f $(MANIFEST)"
		@echo "  make apply-reader          # apply reader RBAC (zeta-ey-access-reader.yaml)"
		@echo "  make apply-deployer        # apply deployer RBAC (zeta-achelos-access-writer.yaml)"
		@echo "  make apply-ci              # apply ci RBAC (zeta-dev-ci-deployer-all-ns.yaml)"
		@echo "  make kubeconfig            # generate kubeconfig using NS/SA/DURATION/OUT"
		@echo "  make kubeconfig-reader     # generate kubeconfig for reader (NS=zeta-staging SA=reader)"
		@echo "  make kubeconfig-deployer   # generate kubeconfig for deployer (NS=zeta-achelos SA=deployer)"
		@echo "  make kubeconfig-ci         # generate kubeconfig for ci (NS=ci SA=ci)"
		@echo "  make kubeconfig-ci-b64     # generate CI kubeconfig then write base64 file"
		@echo "Variables (overridable):"
		@echo "  NS=$(NS) SA=$(SA) DURATION=$(DURATION) OUT=$(OUT) MANIFEST=$(MANIFEST)"

apply:
	kubectl apply -f $(MANIFEST)

apply-reader:
	kubectl apply -f zeta-ey-access-reader.yaml

apply-deployer:
	kubectl apply -f zeta-achelos-access-writer.yaml

apply-ci:
	kubectl apply -f zeta-dev-ci-deployer-all-ns.yaml

kubeconfig:
	@SKIP_CONFIRM=1 NS="$(NS)" SA="$(SA)" DURATION="$(DURATION)" OUT="$(OUT)" bash ./generate-standalone-kubeconfig.sh

kubeconfig-reader:
	@$(MAKE) kubeconfig NS=zeta-staging SA=reader OUT=zeta-staging-reader-zeta-kubeconfig --no-print-directory

kubeconfig-deployer:
	@$(MAKE) kubeconfig NS=zeta-achelos SA=deployer OUT=zeta-achelos-deployer-zeta-kubeconfig --no-print-directory

kubeconfig-ci:
		@$(MAKE) kubeconfig NS=ci SA=ci OUT=ci-ci-zeta-kubeconfig --no-print-directory

kubeconfig-ci-b64:
	@$(MAKE) kubeconfig-ci --no-print-directory
	@KCFG=ci-ci-zeta-kubeconfig; OUT_B64=kubeconfig.b64; \
	base64 < "$$KCFG" | tr -d '\n' > "$$OUT_B64"; \
	echo "✅ Base64 written: $$OUT_B64"

# base64 -i ci-ci-zeta-kubeconfig | tr -d '\n' > kubeconfig.b64
