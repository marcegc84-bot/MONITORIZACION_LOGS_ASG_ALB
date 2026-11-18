# Uso:
#   make init     ENV=dev STACK=00-network  STATE_BUCKET=mi-bucket-de-estado
#   make plan     ENV=dev STACK=00-network  STATE_BUCKET=mi-bucket-de-estado
#   make apply    ENV=dev STACK=00-network  STATE_BUCKET=mi-bucket-de-estado
#   make destroy  ENV=dev STACK=10-asg-alb  STATE_BUCKET=mi-bucket-de-estado
#   make fmt | make validate-all
#   make sync-versions   copia config/versions.tf a cada stack (tras cambiar versiones)
#   make check-versions  falla si alguna copia no coincide con config/ (lo ejecuta el CI)
#
# Orden de creación: 00-network -> 10-asg-alb -> 20-eks. Orden de destrucción: el inverso.
# Antes de 10-asg-alb:  export TF_VAR_alert_email="tu@correo"
# Antes de 20-eks:      export TF_VAR_api_allowed_cidrs="[\"$(curl -s https://checkip.amazonaws.com)/32\"]"
#   make kubeconfig ENV=dev STATE_BUCKET=...   configura kubectl para el clúster

# En Windows (Git Bash) make ejecuta los comandos simples sin shell y no encuentra terraform
SHELL := bash

ENV          ?= dev
STACK        ?= 00-network
STATE_BUCKET ?=
DIR          := environments/$(ENV)/$(STACK)

# Stacks que reciben las versiones centralizadas en config/versions.tf
ALL_STACKS := bootstrap $(wildcard environments/*/*)

# El stack 10-asg-alb lee el estado de la red desde este bucket
export TF_VAR_state_bucket := $(STATE_BUCKET)

.PHONY: init plan apply destroy output kubeconfig fmt validate-all check-bucket sync-versions check-versions

check-bucket:
	@test -n "$(STATE_BUCKET)" || (echo "Falta STATE_BUCKET=<bucket de estado>" && exit 1)

init: check-bucket
	terraform -chdir=$(DIR) init -backend-config=backend.hcl -backend-config="bucket=$(STATE_BUCKET)"

plan: check-bucket
	terraform -chdir=$(DIR) plan

apply: check-bucket
	terraform -chdir=$(DIR) apply

destroy: check-bucket
	terraform -chdir=$(DIR) destroy

output: check-bucket
	terraform -chdir=$(DIR) output

# Configura kubectl con el clúster de ENV (stack 20-eks)
kubeconfig: check-bucket
	$$(terraform -chdir=environments/$(ENV)/20-eks output -raw kubeconfig_command)

fmt:
	terraform fmt -recursive

# Valida sintaxis y referencias de todos los stacks sin tocar AWS ni el estado
validate-all:
	@set -e; for d in environments/*/*/ bootstrap/; do \
	  echo "==> $$d"; \
	  terraform -chdir=$$d init -backend=false -input=false >/dev/null; \
	  terraform -chdir=$$d validate; \
	done

# Copia el origen único de versiones (config/) a cada stack
sync-versions:
	@for d in $(ALL_STACKS); do cp config/versions.tf $$d/versions.tf; done
	@echo "Versiones sincronizadas en $(words $(ALL_STACKS)) stacks"

# Falla si alguna copia difiere del origen
check-versions:
	@rc=0; \
	for d in $(ALL_STACKS); do diff -q config/versions.tf $$d/versions.tf >/dev/null 2>&1 || { echo "Desincronizado: $$d/versions.tf"; rc=1; }; done; \
	if [ $$rc -eq 0 ]; then echo "Versiones sincronizadas"; else echo "Ejecuta: make sync-versions"; exit 1; fi
