MAKEFLAGS+=--silent

Env=$(shell cat .env)

.PHONY: all init apply

all:
	make init
	make apply

init:
	make _purge
	make _config
	terraform init -backend-config=backend.tfvars

apply:
	terraform apply

# Private
.PHONY: _purge _config

_purge:
	rm -f .terraform/*.tfstate *.tfvars

_config:
	cp config/terraform.tfvars.$(Env) terraform.tfvars
	cp config/backend.tfvars.$(Env) backend.tfvars
