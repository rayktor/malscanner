#!make
export PROJECT := $(or $(PROJECT),malware_scanner)
ENV_NAME ?= dev
PROJECT_CODE = ms-cop
NAMESPACE = $(PROJECT_CODE)-$(ENV_NAME)

TERRAFORM_DIR = terraform
export AWS_REGION ?= us-east-1

ifeq ($(ENV_NAME), dev)
AWS_ACCOUNT_ID = #123456789
AWS_PROFILE = personal
endif


define TFVARS_DATA
target_env = "$(ENV_NAME)"
project_code = "$(PROJECT_CODE)"
endef
export TFVARS_DATA

####################################################################
## Local Development
####################################################################

run-local:
	@echo "+\n++ Make: Running locally ...\n+"
	@docker compose up -d

build-local:
	@echo "+\n++ Make: Running locally ...\n+"
	@docker compose build --no-cache

close-local:
	@echo "+\n++ Make: Closing local container ...\n+"
	@docker compose down

local-api-workspace:
	@docker exec -it $(PROJECT)-api bash

build-scanner:
	@echo "+\n++ Make: Build image...\n+"
	rm -rf packages/scanner/node_modules || true
	@docker compose build malscanner

scanner-run:
	@echo "+\n++ Make: Run function... $(payload) \n+"
	@curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '$(payload)'


####################################################################
## Terraform Config
####################################################################

print-env:
	@echo NAMESPACE=$(NAMESPACE)
	@echo AWS_SA_ROLE_ARN=$(AWS_SA_ROLE_ARN)
	@echo
	@echo ./$(TERRAFORM_DIR)/.auto.tfvars:
	@echo "$$TFVARS_DATA"


tf-init: tf-write-config
	# Initializing the terraform environment
	@aws-vault exec $(AWS_PROFILE) -- terraform -chdir=$(TERRAFORM_DIR) init -input=false -reconfigure

tf-write-config:
	@echo "$$TFVARS_DATA" > $(TERRAFORM_DIR)/.auto.tfvars

tf-deploy:
	# Creating all AWS infrastructure.
	@aws-vault exec $(AWS_PROFILE) --no-session -- terraform -chdir=$(TERRAFORM_DIR) apply -auto-approve -input=false

tf-plan: tf-init
	# Creating all AWS infrastructure.
	@aws-vault exec $(AWS_PROFILE) --no-session -- terraform -chdir=$(TERRAFORM_DIR) plan

tf-force-unlock: tf-init
	@aws-vault exec $(AWS_PROFILE) -- terraform -chdir=$(TERRAFORM_DIR) force-unlock $(LOCK_ID)

tag-scanner-image:
	docker tag $(PROJECT)-malscanner $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(NAMESPACE)-malscanner

new-malscanner-image: build-scanner | tag-scanner-image | push-scanner-image

push-scanner-build:
	@aws-vault exec $(AWS_PROFILE) -- docker push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(NAMESPACE)-malscanner

ecr-login:
	@aws-vault exec $(AWS_PROFILE) -- aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com



destroy: init-tf
	terraform -chdir=$(TERRAFORM_DIR) destroy


get-sa-role-arn:
	@echo $(AWS_SA_ROLE_ARN)
