.PHONY: help init plan deploy destroy clean hash

help:
	@echo "KVM Infrastructure Management"
	@echo "=============================="
	@echo ""
	@echo "Available targets:"
	@echo "  init    - Initialize Terraform"
	@echo "  plan    - Plan infrastructure changes"
	@echo "  deploy  - Deploy infrastructure"
	@echo "  destroy - Destroy infrastructure"
	@echo "  clean   - Clean Terraform files"
	@echo "  hash    - Generate password hash"
	@echo ""

init:
	terraform init

plan:
	terraform plan

deploy:
	./scripts/deploy.sh

destroy:
	./scripts/destroy.sh

clean:
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate* tfplan

hash:
	./scripts/generate_password_hash.sh
