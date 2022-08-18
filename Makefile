MAKEFLAGS+=--silent

Env=$(shell cat .env)

.PHONY: all init validate plan apply

all:
	make init
	make validate
	make apply

init:
	make _purge
	make _config
	terraform init -backend-config=backend.tfvars

validate:
	tflint
	terraform validate

plan:
	terraform plan

apply:
	terraform apply

# Private
.PHONY: _purge _config

_purge:
	rm -f .terraform/*.tfstate *.tfvars

_config:
	cp config/terraform.tfvars.$(Env) terraform.tfvars
	cp config/backend.tfvars.$(Env) backend.tfvars
