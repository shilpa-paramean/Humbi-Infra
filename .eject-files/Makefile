export GOOGLE_IDP_ID?=C01501d06
export GOOGLE_SP_ID?=192607830114
export AZURE_TENANT_ID?=PLACEHOLDER
export AZURE_APP_ID_URI?=PLACEHOLDER
export AWS_DEFAULT_REGION=ap-southeast-2

GOOGLE_AUTH_IMAGE=public.ecr.aws/dnxsolutions/aws-google-auth:latest
AZURE_AUTH_IMAGE=public.ecr.aws/dnxsolutions/docker-aws-azure-ad:latest
AWS_IMAGE=public.ecr.aws/dnxsolutions/aws-v2:2.2.9-dnx1
TERRAFORM_IMAGE=public.ecr.aws/dnxsolutions/terraform:1.0.0-dnx1

PARENT_PWD := $(dir $(abspath $(dir $$PWD)))

RUN_GOOGLE_AUTH=docker run -it --rm --env-file=.env -v $(PWD)/.env.auth:/work/.env $(GOOGLE_AUTH_IMAGE)
RUN_AZURE_AUTH =docker run -it --rm --env-file=.env -v $(PWD)/.env.auth:/work/.env $(AZURE_AUTH_IMAGE)
RUN_AWS        =docker run -i --rm --env-file=.env --env-file=.env.auth --env-file=.env.assume -v $(PWD):/work -v $(PWD)/aws-sso-config:/root/.aws/config --entrypoint "" $(AWS_IMAGE)
RUN_TERRAFORM  =docker run -i --rm --env-file=.env --env-file=.env.auth --env-file=.env.assume -v $(PWD):/work -v /var/run/secrets:/var/run/secrets --entrypoint "" $(TERRAFORM_IMAGE)

export AWS_ROLE?=InfraDeploy
export AWS_ACCOUNT_ID?=953027019050# dnx-automation
export ASSUME_REQUIRED?=assume-role

STACK_NAME := $(shell basename $$PWD)
CLIENT := $(shell echo ${WORKSPACE} | cut  -d'-' -f1)


############################
# Env and Authentication
############################

env-%: # Check for specific environment variables
	@ if [ "${${*}}" = "" ]; then echo "Environment variable $* not set"; exit 1;fi

.env:
	cp .env.template .env
	echo >> .env
	touch .env.auth
	touch .env.assume

assume-role: .env
	echo > .env.assume
	$(RUN_AWS) assume-role.sh > .env.assume
.PHONY: assume-role

clean-dotenv:
	-rm .env
.PHONY: clean-dotenv

google-auth: .env env-GOOGLE_IDP_ID env-GOOGLE_SP_ID
	echo > .env.auth
	$(RUN_GOOGLE_AUTH)
.PHONY: google-auth

aws-sso-configure:
	$(RUN_AWS) aws configure sso
.PHONY: aws-sso-configure

aws-sso-auth: .env env-AWS_SSO_PROFILE
	$(RUN_AWS) bash /opt/scripts/aws-sso.sh > .env.auth
.PHONY: aws-sso-auth

######################
# Terraform Commands
######################

_init:
	rm -rf .terraform terraform.tfstate* terraform.tfstate.d ||:
	terraform init 
	terraform workspace new $(WORKSPACE) 2>/dev/null; true # ignore if workspace already exists
	terraform workspace "select" $(WORKSPACE)

_lint:
	terraform fmt --recursive -check=true

_validate:
	terraform validate

_plan:
	terraform plan -out=.terraform-plan-$(WORKSPACE)

_apply: 
	terraform apply .terraform-plan-$(WORKSPACE)

_output:
	terraform output -json > output.json

######################
# Entry Points
######################

init: .env  env-WORKSPACE
	$(RUN_TERRAFORM) make _init
.PHONY: init

lint: .env
	$(RUN_TERRAFORM) make _lint
.PHONY: lint

validate: .env
	$(RUN_TERRAFORM) make _validate
.PHONY: validate

apply: .env  env-WORKSPACE
	$(RUN_TERRAFORM) make _apply
.PHONY: apply

plan: .env  env-WORKSPACE
	$(RUN_TERRAFORM) make _plan
.PHONY: plan

output:
	@$(RUN_TERRAFORM) make _output
.PHONY: output

######################
# Utilities
######################

shell: .env 
	docker run -it --rm  --env-file=.env --env-file=.env.assume -v $(PWD):/work --entrypoint "/bin/bash" $(TERRAFORM_IMAGE)
.PHONY: shell

check_clean:
	@echo "Are you sure you want to delete the files? It's including (terraform files, gsuite xml and git repository) [yes/no] " && read ans && [ $${ans:-N} == yes ]
.PHONY: check_clean

clean: check_clean .env
	echo "+++ :system: Cleaning default files"
	rm -rf .terraform terraform.tfstate* terraform.tfstate.d .git ||:
.PHONY: clean

