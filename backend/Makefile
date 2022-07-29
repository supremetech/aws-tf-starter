Env=$(shell cat ../.env)

.PHONY: all init apply

all:
	make init
	make apply

init:
	make _config
	terraform init
	terraform workspace new $(Env) || true
	terraform workspace select $(Env)

apply:
	terraform apply

# Private
.PHONY: _config

_config:
	! [ -f ../config/backend.tfvars.$(Env) ]
	rm -f terraform.tfvars
	for var in \
		project_name \
		environment \
		allowed_account_ids \
		region \
	; do \
		grep $$var ../config/terraform.tfvars.$(Env) >> terraform.tfvars; \
	done
