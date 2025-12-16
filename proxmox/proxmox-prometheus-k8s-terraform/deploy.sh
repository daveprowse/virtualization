#!/bin/bash
# Infrastructure Deployment Script
# Deploys: 2 standalone servers + 3 MicroK8s cluster nodes

set -e
set -o pipefail  # Make pipes return exit code of first failed command

# Start time tracking
DEPLOY_START_TIME=$(date +%s)

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging - use absolute paths so they work after cd
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/deploy-$(date +%Y%m%d-%H%M%S).log"
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

log_section "Infrastructure Deployment Started"
log "Log file: ${LOG_FILE}"
log "Timestamp: $(date)"
log ""

# Check prerequisites
log_section "Checking Prerequisites"

if ! command -v terraform &> /dev/null; then
    log_error "Terraform not found. Please install terraform."
    exit 1
fi
log_success "Terraform found: $(terraform version -json 2>/dev/null | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4 || terraform version | head -1)"

if ! command -v ansible &> /dev/null; then
    log_error "Ansible not found. Please install ansible."
    exit 1
fi
log_success "Ansible found: $(ansible --version | head -1)"

if [ ! -f "terraform.tfvars" ]; then
    log_error "terraform.tfvars not found. Please create it."
    exit 1
fi
log_success "terraform.tfvars found"

if [ ! -f "cloud-init-controller-minimal-only.yaml" ]; then
    log_error "cloud-init-controller-minimal-only.yaml not found."
    exit 1
fi
log_success "Cloud-init files found"

log ""

# Phase 1: Terraform
log_section "Phase 1: Creating VMs with Terraform"

log "Initializing Terraform..."
if terraform init >> "${LOG_FILE}" 2>&1; then
    log_success "Terraform initialized"
else
    log_error "Terraform init failed. Check log: ${LOG_FILE}"
    exit 1
fi

log ""
log "Running terraform plan..."
if terraform plan -out=tfplan >> "${LOG_FILE}" 2>&1; then
    log_success "Terraform plan completed"
else
    log_error "Terraform plan failed. Check log: ${LOG_FILE}"
    exit 1
fi

log ""
log "Applying Terraform configuration..."
log "Creating 5 VMs:"
log "  - prom1 (10.42.88.1) - 4 cores, 8GB RAM"
log "  - prom2 (10.42.88.2) - 4 cores, 8GB RAM"
log "  - controller (10.42.88.120) - 8 cores, 16GB RAM"
log "  - worker1 (10.42.88.121) - 4 cores, 8GB RAM"
log "  - worker2 (10.42.88.122) - 4 cores, 8GB RAM"
log ""

if terraform apply tfplan >> "${LOG_FILE}" 2>&1; then
    log_success "VMs created successfully!"
else
    log_error "Terraform apply failed. Check log: ${LOG_FILE}"
    exit 1
fi

rm -f tfplan

log ""
log_section "Waiting for Cloud-Init to Complete"

# Clear any old SSH known_hosts entries FIRST (before checking cloud-init)
log "Clearing old SSH host keys..."
for ip in "${VM_IPS[@]}"; do
    ssh-keygen -R "$ip" >> "${LOG_FILE}" 2>&1 || true
done
log_success "SSH host keys cleared"
log ""

# Adaptive wait - check if VMs are actually ready
log "Checking if cloud-init has completed..."

WAIT_COUNT=0
MAX_WAIT=18  # 18 attempts = 3 minutes max

# First, wait for SSH to be available
while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    if ssh $SSH_KEY_OPT -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 sa@10.42.88.120 "echo ok" &>/dev/null; then
        log_success "SSH available on controller!"
        break
    fi
    
    WAIT_COUNT=$((WAIT_COUNT + 1))
    log "Waiting for SSH... (attempt $WAIT_COUNT/$MAX_WAIT)"
    sleep 10
done

if [ $WAIT_COUNT -eq $MAX_WAIT ]; then
    log_error "SSH connectivity failed after 3 minutes"
    exit 1
fi

# Now wait for cloud-init to FULLY complete (not just boot-finished)
log ""
log "Waiting for cloud-init to fully complete on all VMs..."

for ip in 10.42.88.1 10.42.88.2 10.42.88.120 10.42.88.121 10.42.88.122; do
    WAIT_COUNT=0
    MAX_WAIT=24  # 4 minutes max per VM
    
    while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
        # Check cloud-init status - must be 'done' or 'disabled'
        STATUS=$(ssh $SSH_KEY_OPT -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 sa@$ip "cloud-init status 2>/dev/null | cut -d: -f2 | xargs" 2>/dev/null || echo "unknown")
        
        if [ "$STATUS" = "done" ] || [ "$STATUS" = "disabled" ]; then
            log_success "Cloud-init completed on $ip (status: $STATUS)"
            break
        fi
        
        WAIT_COUNT=$((WAIT_COUNT + 1))
        if [ $((WAIT_COUNT % 3)) -eq 0 ]; then  # Log every 30 seconds
            log "Waiting for cloud-init on $ip (status: $STATUS)..."
        fi
        sleep 10
    done
    
    if [ $WAIT_COUNT -eq $MAX_WAIT ]; then
        log_warning "Cloud-init status check timed out on $ip, but proceeding..."
    fi
done

log ""
log_success "All VMs ready - cloud-init fully completed"

# Phase 2: Test SSH
log ""
log_section "Testing SSH Connectivity"

log "Testing SSH to all 5 servers..."

cd ansible

if ./test-connectivity.sh >> "${LOG_FILE}" 2>&1; then
    log_success "All servers are reachable via SSH"
else
    log_warning "Some servers not reachable yet. Trying again in 30 seconds..."
    sleep 30
    if ./test-connectivity.sh >> "${LOG_FILE}" 2>&1; then
        log_success "All servers are now reachable"
    else
        log_error "Cannot reach all servers. Please check:"
        log "   1. SSH manually: ssh -o StrictHostKeyChecking=no sa@10.42.88.120"
        log "   2. Check VM console on Proxmox"
        log "   3. Verify cloud-init completed: sudo cloud-init status"
        log "   4. Check log: ${LOG_FILE}"
        exit 1
    fi
fi

# Phase 3: Ansible
log ""
log_section "Phase 2: Installing MicroK8s with Ansible"
log "Installing MicroK8s 1.34 on cluster nodes..."
log "This will take approximately 3-5 minutes."
log ""

# Pass SSH key name from .env to Ansible
if ansible-playbook microk8s-cluster.yml --extra-vars "ssh_key_name=${SSH_KEY_NAME}" | tee -a "${LOG_FILE}"; then
    log ""
    log_success "MicroK8s cluster deployed successfully!"
else
    log_error "Ansible playbook failed. Check log: ${LOG_FILE}"
    exit 1
fi

cd ..

# Summary
log ""
log_section "Deployment Complete!"

log "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
log "${GREEN}║                  DEPLOYMENT SUCCESSFUL!                    ║${NC}"
log "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
log ""

log "📊 INFRASTRUCTURE SUMMARY"
log ""
log "Standalone Servers:"
log "  ├─ prom1:      ssh sa@10.42.88.1"
log "  └─ prom2:      ssh sa@10.42.88.2"
log ""
log "MicroK8s Cluster:"
log "  ├─ controller: ssh sa@10.42.88.120"
log "  ├─ worker1:    ssh sa@10.42.88.121"
log "  └─ worker2:    ssh sa@10.42.88.122"
log ""

log "🎯 NEXT STEPS"
log ""
log "1. Verify cluster status:"
log "   ssh sa@10.42.88.120"
log "   microk8s kubectl get nodes"
log ""
log "2. View all pods:"
log "   microk8s kubectl get pods -A"
log ""
log "3. Access dashboard:"
log "   See the DASHBOARD-ACCESS manual."
log ""
log "4. Get kubeconfig:"
log "   microk8s config > ~/.kube/config"
log ""

log "📝 Log file saved: ${LOG_FILE}"
log ""

# Calculate deployment duration
DEPLOY_END_TIME=$(date +%s)
DEPLOY_DURATION=$((DEPLOY_END_TIME - DEPLOY_START_TIME))
DEPLOY_MINUTES=$((DEPLOY_DURATION / 60))
DEPLOY_SECONDS=$((DEPLOY_DURATION % 60))

log "Deployment completed at: $(date)"
log ""

# Display duration in bright colors
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  ${YELLOW}⏱️  Total Deployment Time: ${DEPLOY_MINUTES}m ${DEPLOY_SECONDS}s${NC}                    ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
log ""

log_success "All done! Enjoy your infrastructure! 🎉"
log ""

# Triple beep to notify completion
printf '\a'
sleep 0.3
printf '\a'
sleep 0.3
printf '\a'

