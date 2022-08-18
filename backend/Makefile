Env=$(shell cat ../.env)

.PHONY: all init validate plan apply

all:
	make init
	make validate
	make apply

init:
	make _config
	terraform init
	terraform workspace new $(Env) || true
	terraform workspace select $(Env)

validate:
	tflint
	terraform validate

plan:
	terraform plan

apply:
	terraform apply

# Private
.PHONY: _config

_config:
	# Comment below line if you want to re-config the backend
	# ! [ -f ../config/backend.tfvars.$(Env) ]
	rm -f terraform.tfvars
	for var in \
		project_name \
		environment \
		allowed_account_ids \
		region \
	; do \
		grep $$var ../config/terraform.tfvars.$(Env) >> terraform.tfvars; \
	done
