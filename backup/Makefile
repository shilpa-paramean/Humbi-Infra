export AWS_DEFAULT_REGION=ap-southeast-2

AWS_IMAGE=public.ecr.aws/dnxsolutions/aws-v2:2.2.9-dnx1
TERRAFORM_IMAGE=public.ecr.aws/dnxsolutions/terraform:1.0.0-dnx1

PARENT_PWD 	  	 := $(dir $(abspath $(dir $$PWD)))

# Export this variable to use external terraform modules locally (see README.md for more details).
EXTERNAL_MODULES ?= $(HOME)/external_modules

RUN_AWS			=docker run -i --rm --env-file=.env --env-file=.env.assume -v $(PWD):/work -v $(PARENT_PWD).clients:/work/.clients -v $(HOME)/.aws:/root/.aws -v $(EXTERNAL_MODULES):/modules --entrypoint "" $(AWS_IMAGE)
RUN_TERRAFORM	=docker run -i --rm --env-file=.env --env-file=.env.assume -v $(PWD):/work -v $(PARENT_PWD).clients:/work/.clients -v $(HOME)/.aws:/root/.aws -v $(EXTERNAL_MODULES):/modules --entrypoint "" $(TERRAFORM_IMAGE)

export AWS_ROLE?=InfraDeploy
export AWS_ACCOUNT_ID?=953027019050# dnx-automation
# AWS_ACCOUNT_ID=$(shell python3 -c "import yaml;print(yaml.safe_load(open('one.yaml'))['workspaces']['$(WORKSPACE)']['aws_account_id'])")

export ASSUME_REQUIRED?=assume-role

STACK_NAME := $(shell basename $$PWD)
CLIENT := $(shell echo ${WORKSPACE} | cut  -d'-' -f1)
BACKEND_CONFIG=$(shell test -e ./.clients/client-$(CLIENT)/.config/terraform-backend.tfvars && echo " -backend-config=./.clients/client-$(CLIENT)/.config/terraform-backend.tfvars ")

############################
# Env and Authentication
############################

env-%: # Check for specific environment variables
	@ if [ "${${*}}" = "" ]; then echo "Environment variable $* not set"; exit 1;fi

.env:
	cp .env.template .env
	echo >> .env
	touch .env.assume

assume-role: .env
	echo > .env.assume
	$(RUN_AWS) assume-role.sh > .env.assume
.PHONY: assume-role

clean-dotenv:
	-rm .env
.PHONY: clean-dotenv

######################
# Terraform Commands
######################

_init:
	rm -rf .terraform terraform.tfstate* terraform.tfstate.d ||:
	terraform init $(BACKEND_CONFIG)
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

init: .env $(ASSUME_REQUIRED) env-WORKSPACE copy_client
	$(RUN_TERRAFORM) make _init
.PHONY: init

lint: .env
	$(RUN_TERRAFORM) make _lint
.PHONY: lint

validate: .env
	$(RUN_TERRAFORM) make _validate
.PHONY: validate

apply: .env $(ASSUME_REQUIRED) env-WORKSPACE
	$(RUN_TERRAFORM) make _apply
.PHONY: apply

plan: .env $(ASSUME_REQUIRED) env-WORKSPACE
	$(RUN_TERRAFORM) make _plan
.PHONY: plan

output:
	@$(RUN_TERRAFORM) make _output
.PHONY: output

######################
# Utilities
######################

shell: .env $(ASSUME_REQUIRED)
	docker run -it --rm  --env-file=.env --env-file=.env.assume -v $(PWD):/work -v $(HOME)/.aws:/root/.aws -v $(PARENT_PWD).clients:/work/.clients -v $(EXTERNAL_MODULES):/modules --entrypoint "/bin/bash" $(TERRAFORM_IMAGE)
.PHONY: shell

check_clean:
	@echo "Are you sure you want to delete the files? It's including (terraform files, gsuite xml and git repository) [yes/no] " && read ans && [ $${ans:-N} == yes ]
.PHONY: check_clean

clean: check_clean .env
	echo "+++ :system: Cleaning default files"
	rm -rf .terraform terraform.tfstate* terraform.tfstate.d .git ||:
.PHONY: clean

copy_client:
	for f in $(PARENT_PWD).clients/client-$(CLIENT)/$(STACK_NAME)/extras/*.tf; do cp -v -- $$f ./extras-$$(basename "$$f"); done || :
	cp -av $(PARENT_PWD).clients/client-$(CLIENT)/$(STACK_NAME)/overwrites/. . || :
	mkdir -p ./.workspaces
	cp -av $(PARENT_PWD).clients/client-$(CLIENT)/$(STACK_NAME)/*.yaml ./.workspaces/
.PHONY: copy_client