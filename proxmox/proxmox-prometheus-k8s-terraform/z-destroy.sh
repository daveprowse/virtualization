#!/bin/bash
# Infrastructure Destruction Script
# Destroys: All VMs and associated resources

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
LOG_DIR="./logs"
LOG_FILE="${LOG_DIR}/destroy-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "${LOG_DIR}"

# Function to log messages
log() {
    echo -e "${1}" | tee -a "${LOG_FILE}"
}

log_section() {
    log "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
    log "${BLUE}${1}${NC}"
    log "${BLUE}════════════════════════════════════════════════════════════${NC}\n"
}

log_success() {
    log "${GREEN}✅ ${1}${NC}"
}

log_warning() {
    log "${YELLOW}⚠️  ${1}${NC}"
}

log_error() {
    log "${RED}❌ ${1}${NC}"
}

log_section "Infrastructure Destruction Started"
log "Log file: ${LOG_FILE}"
log "Timestamp: $(date)"
log ""

# Check if terraform is available
if ! command -v terraform &> /dev/null; then
    log_error "Terraform not found. Cannot destroy infrastructure."
    exit 1
fi

# Check if terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    log_warning "No terraform.tfstate file found."
    log "Either infrastructure was never created, or state file is missing."
    log ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Destruction cancelled."
        exit 0
    fi
fi

# Display what will be destroyed
log_section "Infrastructure to be Destroyed"
log ""
log "The following resources will be destroyed:"
log ""
log "Standalone Servers:"
log "  ├─ prom1 (10.42.88.1, VMID 2101)"
log "  └─ prom2 (10.42.88.2, VMID 2102)"
log ""
log "MicroK8s Cluster:"
log "  ├─ controller (10.42.88.120, VMID 2120)"
log "  ├─ worker1 (10.42.88.121, VMID 2121)"
log "  └─ worker2 (10.42.88.122, VMID 2122)"
log ""
log "Cloud-init snippets:"
log "  ├─ cloud-init-prom1.yaml"
log "  ├─ cloud-init-prom2.yaml"
log "  ├─ cloud-init-controller.yaml"
log "  ├─ cloud-init-worker1.yaml"
log "  └─ cloud-init-worker2.yaml"
log ""
log "Ubuntu cloud image (if not used by other VMs)"
log ""

log_warning "⚠️  THIS ACTION CANNOT BE UNDONE! ⚠️"
log ""

# Confirmation prompt
read -p "Are you sure you want to destroy ALL infrastructure? (yes/NO) " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    log "Destruction cancelled by user."
    exit 0
fi

log ""
log_warning "Starting destruction in 5 seconds..."
log_warning "Press Ctrl+C to cancel!"
for i in {5..1}; do
    printf "\r  ⏱️  Destroying in %d seconds..." $i
    sleep 1
done
echo ""
log ""

# Run terraform destroy
log_section "Destroying Infrastructure"
log "Running terraform destroy..."
log ""

# Create a temporary file for tracking progress
PROGRESS_FILE="/tmp/terraform_destroy_progress_$$"

# Run terraform destroy and capture output
if terraform destroy -auto-approve 2>&1 | tee -a "${LOG_FILE}" | tee "${PROGRESS_FILE}"; then
    log ""
    log_success "Terraform destroy completed successfully!"
    
    # Parse and summarize what was destroyed
    log ""
    log_section "Destruction Summary"
    
    DESTROYED_COUNT=$(grep -c "Destruction complete" "${PROGRESS_FILE}" 2>/dev/null || echo "0")
    
    log "Resources destroyed: ${DESTROYED_COUNT}"
    log ""
    
    if grep -q "prom1" "${PROGRESS_FILE}"; then
        log_success "prom1 VM destroyed"
    fi
    
    if grep -q "prom2" "${PROGRESS_FILE}"; then
        log_success "prom2 VM destroyed"
    fi
    
    if grep -q "controller" "${PROGRESS_FILE}"; then
        log_success "controller VM destroyed"
    fi
    
    if grep -q "worker1" "${PROGRESS_FILE}"; then
        log_success "worker1 VM destroyed"
    fi
    
    if grep -q "worker2" "${PROGRESS_FILE}"; then
        log_success "worker2 VM destroyed"
    fi
    
    log ""
    log_success "All VMs and associated resources have been destroyed."
    
    # Clean up
    rm -f "${PROGRESS_FILE}"
    
else
    log ""
    log_error "Terraform destroy failed!"
    log "Check the log file for details: ${LOG_FILE}"
    log ""
    log "Common issues:"
    log "  - VMs already deleted manually in Proxmox"
    log "  - Network connectivity issues"
    log "  - Proxmox API authentication problems"
    log ""
    log "You may need to:"
    log "  1. Check Proxmox web UI for remaining VMs"
    log "  2. Manually delete VMs if needed"
    log "  3. Run: terraform state list"
    log "  4. Remove stuck resources: terraform state rm <resource>"
    log ""
    
    rm -f "${PROGRESS_FILE}"
    exit 1
fi

# Final summary
log ""
log_section "Destruction Complete"

log "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
log "${GREEN}║            INFRASTRUCTURE DESTROYED SUCCESSFULLY           ║${NC}"
log "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
log ""

log "📊 CLEANUP SUMMARY"
log ""
log "✅ All VMs destroyed"
log "✅ Cloud-init snippets removed from Proxmox"
log "✅ Terraform state updated"
log ""

log "📝 REMAINING FILES (local)"
log ""
log "The following files are still present locally:"
log "  ├─ terraform.tfstate (history of destroyed resources)"
log "  ├─ terraform.tfstate.backup"
log "  ├─ .terraform/ directory"
log "  └─ Configuration files (main.tf, variables.tf, etc.)"
log ""
log "These files are safe to keep for future deployments."
log "To completely clean up:"
log "  rm -rf .terraform/ terraform.tfstate*"
log ""

log "📝 Log file saved: ${LOG_FILE}"
log ""
log "Destruction completed at: $(date)"
log ""

log_success "Infrastructure successfully destroyed! 🗑️"
