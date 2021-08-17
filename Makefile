ifneq (,$(wildcard ./.env))
	include .env
	export
endif

.DEFAULT_GOAL := help

.PHONY: start
start: ## Runs the full application stack locally
	@docker compose up

.PHONY: build
build: ## Generate compiled application files to prepare for a deployment
	@docker compose run site --

.PHONY: clean
clean: ## Reset docker and clear temporary files
	@rm -rf ./site/public/
	@rm -rf ./site/resources/
	@rm -rf ./terraform/.terraform/
	@rm -rf ./terraform/plan
	@docker compose down

.PHONY: sh-site
sh-site: ## Open a shell in the site docker image
	@docker compose run --entrypoint sh site

.PHONY: sh-terraform
sh-terraform: ## Open a shell in the terraform docker image
	@docker compose run --entrypoint sh terraform

.PHONY: sh-tfsec
sh-tfsec: ## Open a shell in the tfsec docker image
	@docker compose run --entrypoint sh tfsec

.PHONY: docker-rebuild-site
docker-rebuild-site: ## Rebuild docker image used for site
	@docker compose build site

.PHONY: docker-rebuild-terraform
docker-rebuild-terraform: ## Rebuild docker image used for terraform
	@docker compose build terraform

.PHONY: docker-rebuild-tfsec
docker-rebuild-tfsec: ## Rebuild docker image used for tfsec
	@docker compose build tfsec

.PHONY: tfsec
tfsec: ## Runs tfsec to scan for security issues
	@docker compose run tfsec /terraform

.PHONY: deploy-main
deploy: ## 🔒 Deploys compiled application files to static host
	@docker compose run aws s3 sync /site/public/ s3://${DOMAIN_NAME}-site/

.PHONY: deploy-preview
deploy: ## 🔒 Deploys compiled application files to static host
	@docker compose run aws s3 sync /site/public/ s3://${DOMAIN_NAME}-previews/${PREVIEW_ENVIRONMENT}/

.PHONY: terraform-init
terraform-init: ## 🔒 Runs terraform init
	@docker compose run terraform init -backend-config="bucket=${DOMAIN_NAME}-terraform"

.PHONY: terraform-plan
terraform-plan: ## 🔒 Runs terraform plan
	@docker compose run terraform plan -out=plan

.PHONY: terraform-apply
terraform-apply: ## 🔒 Runs terraform apply
	@docker compose run terraform apply plan

.PHONY: help
help:
	@echo "Usage: make [task]\n\nAvailable tasks:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-24s\033[0m %s\n", $$1, $$2}'
	@echo "\n\033[33m(🔒) These tasks require AWS credentials configured via environment variables (see .env.example).\033[0m"
