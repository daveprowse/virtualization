# File Reference 📁

Complete guide to all files in this project.

---

## Quick Reference

**Files you MUST edit:**
- `.env` - SSH key configuration
- `terraform.tfvars` - Proxmox credentials (you create this)

**Main scripts:**
- `deploy.sh` - Deploy everything
- `z-destroy.sh` - Destroy everything  
- `test-ansible-config.sh` - Test before deploying

---

## Configuration Files ⚙️

### `.env` ⭐ EDIT THIS

**Purpose:** Single source of truth for SSH key configuration

**What to edit:**
```bash
SSH_KEY_NAME=proxmox_key  # Change to your SSH key name
```

**Default:** `proxmox_key`

**Examples:**
```bash
SSH_KEY_NAME=id_rsa          # Use existing key
SSH_KEY_NAME=my_custom_key   # Use custom key
```

---

### `terraform.tfvars` ⭐ CREATE THIS

**Purpose:** Proxmox credentials

**Template:**
```hcl
proxmox_host     = "192.168.1.100"
proxmox_user     = "root@pam"
proxmox_password = "your-password"
node_name        = "pve"
ssh_public_keys  = ["ssh-rsa AAAAB3... your-key"]
```

**Security:** Add to `.gitignore`!

---

### `config.sh`

**Purpose:** Configuration loader

**What it does:**
- Loads `.env`
- Sets SSH_KEY_PATH
- Defines VM IPs
- SSH options

**Edit?** No - reads from `.env`

---

## Main Scripts 🚀

### `deploy.sh`

**Purpose:** Complete deployment

**Time:** ~10 minutes

**Steps:**
1. Check prerequisites
2. Create VMs (Terraform)
3. Wait for cloud-init
4. Install MicroK8s (Ansible)
5. Show summary + timer

---

### `z-destroy.sh`

**Purpose:** Destroy everything

**⚠️ WARNING:** Deletes all 5 VMs immediately!

---

### `test-ansible-config.sh`

**Purpose:** Pre-flight validation

**Checks:**
- SSH key exists
- Ansible config valid
- Ready to deploy

---

## Terraform Files 📋

- `main.tf` - VM definitions (~600 lines)
- `variables.tf` - Variable definitions
- `outputs.tf` - Deployment outputs
- `cloud-init-*.yaml` - VM initialization

---

## Ansible Files 🤖

- `ansible/inventory.yml` - Host definitions
- `ansible/ansible.cfg` - Ansible settings
- `ansible/microk8s-cluster.yml` - MicroK8s playbook
- `ansible/group_vars/all.yml` - Variables
- `ansible/test-connectivity.sh` - SSH test

---

## Documentation 📚

- `README.md` - Main documentation
- `QUICKSTART.md` - Step-by-step tutorial
- `DASHBOARD-ACCESS.md` - Dashboard access
- `STORAGE.md` - Storage requirements
- `FILES.md` - This file
- `CHANGES.md` - Version history

---

## File Tree 🌳

```
proxmox-microk8s/
├── .env ⭐
├── terraform.tfvars ⭐ (create)
├── deploy.sh 🚀
├── z-destroy.sh
├── test-ansible-config.sh
├── config.sh
├── main.tf
├── variables.tf
├── outputs.tf
├── cloud-init-*.yaml
├── ansible/
│   ├── inventory.yml
│   ├── ansible.cfg
│   ├── microk8s-cluster.yml
│   ├── test-connectivity.sh
│   └── group_vars/all.yml
└── docs/
    ├── README.md
    ├── QUICKSTART.md
    ├── DASHBOARD-ACCESS.md
    ├── STORAGE.md
    ├── FILES.md
    └── CHANGES.md
```

---

**See [README.md](README.md) for detailed file descriptions**

Back to [README.md](README.md)
