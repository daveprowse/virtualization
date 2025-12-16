# Quick Start Guide 🚀

**Complete step-by-step tutorial for first-time users**

---

## Time Required

- **Setup:** 5-10 minutes
- **Deployment:** 8-12 minutes
- **Total:** ~15-20 minutes

---

## Prerequisites Check ✅

Before starting, verify you have:

### 1. Operating System

- ✅ Linux (any distribution)
- ✅ macOS (10.15+)
- ✅ Windows with WSL2 or Git Bash

### 2. Required Software

Test if installed:

```bash
# Bash (should already be installed)
bash --version
# Should show: 4.0 or higher

# Terraform
terraform --version
# Should show: 1.0 or higher

# Ansible
ansible --version
# Should show: 2.14 or higher
```

**Not installed?** See [Installation Guide](#software-installation) below.

### 3. Infrastructure Access

- ✅ Proxmox server with API access
- ✅ Know your Proxmox IP address
- ✅ Know your Proxmox credentials
- ✅ SSH key pair exists (or will create)

---

## Step 1: Install Required Software

### Terraform

**macOS:**
```bash
brew install terraform
```

**Ubuntu/Debian:**
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**Verify:**
```bash
terraform --version
# Should show: Terraform v1.x.x
```

### Ansible

**macOS:**
```bash
brew install ansible
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install ansible
```

**Python pip:**
```bash
pip3 install ansible
```

**Verify:**
```bash
ansible --version
# Should show: ansible [core 2.x.x]
```

---

## Step 2: Get SSH Key Ready

### Check if you have a key

```bash
ls ~/.ssh/id_* 2>/dev/null || ls ~/.ssh/proxmox_key 2>/dev/null
```

**If nothing shows:** Generate a new key

```bash
# Generate ED25519 key (recommended)
ssh-keygen -t ed25519 -f ~/.ssh/proxmox_key -C "proxmox-access"

# Or RSA key (if ED25519 not supported)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/proxmox_key -C "proxmox-access"
```

**Prompts:**
- Enter passphrase: (press Enter for no passphrase)
- Enter same passphrase again: (press Enter)

**Result:** Two files created:
- `~/.ssh/proxmox_key` (private key - keep secure!)
- `~/.ssh/proxmox_key.pub` (public key - will use in config)

### Set correct permissions

```bash
chmod 600 ~/.ssh/proxmox_key
chmod 644 ~/.ssh/proxmox_key.pub
```

---

## Step 3: Download Project

```bash
# Clone repository (if using git)
git clone <repository-url>
cd proxmox-microk8s

# Or download and extract ZIP
# cd proxmox-microk8s-main
```

---

## Step 4: Configure SSH Key

**Edit `.env` file:**

```bash
vim .env
# Or use nano: nano .env
# Or any text editor
```

**Change this line:**
```bash
SSH_KEY_NAME=proxmox_key  # If using default name
# Or
SSH_KEY_NAME=id_rsa      # If using existing key
# Or
SSH_KEY_NAME=my_key      # If using custom name
```

**Save and exit** (vim: `:wq`, nano: Ctrl+X, Y, Enter)

**Verify:**
```bash
# Should show your key
ls ~/.ssh/$(grep SSH_KEY_NAME .env | cut -d'=' -f2)
```

---

## Step 5: Configure Proxmox

### Get your public key

```bash
cat ~/.ssh/proxmox_key.pub
```

**Copy the entire output** (starts with `ssh-rsa` or `ssh-ed25519`)

### Create terraform.tfvars

```bash
vim terraform.tfvars
```

**Paste this template and fill in your values:**

```hcl
# Proxmox Connection
proxmox_host     = "192.168.1.100"    # ← Your Proxmox IP
proxmox_user     = "root@pam"         # ← Your username  
proxmox_password = "your-password"    # ← Your password
node_name        = "pve"              # ← Your Proxmox node name

# SSH Public Keys (paste your public key here)
ssh_public_keys = [
  "ssh-rsa AAAAB3NzaC1yc2EAAA..."     # ← Paste your key here
]

# Optional: Override defaults
# proxmox_port = 8006
# bridge_name = "vmbr2"
```

**How to find your values:**

1. **Proxmox IP:** 
   - Look at your Proxmox web UI URL: `https://192.168.1.100:8006`
   - The IP is `192.168.1.100`

2. **Node name:**
   - In Proxmox web UI, look at left sidebar
   - Usually "pve" or your server hostname

3. **Public key:**
   - From `cat ~/.ssh/proxmox_key.pub` above

**Save and exit**

---

## Step 6: Test Configuration

**Run validation:**

```bash
chmod +x test-ansible-config.sh
./test-ansible-config.sh
```

**Expected output:**
```
Testing Ansible Configuration...
================================================
1. Checking SSH key configuration...
-----------------------------------
Ansible will use SSH key: /home/user/.ssh/proxmox_key
✅ SSH key exists
✅ SSH key has correct permissions (600)

2. Checking inventory configuration...
--------------------------------------
Hosts in inventory:
  ✅ controller
  ✅ worker1
  ✅ worker2
  ✅ prom1
  ✅ prom2

...

✅ Ansible configuration is valid!

Ready to deploy: ./deploy.sh
```

**If you see errors:**
- SSH key not found: Check Step 4
- Permission denied: Run `chmod 600 ~/.ssh/proxmox_key`
- Other errors: See [Troubleshooting](#troubleshooting)

---

## Step 7: Deploy! 🚀

```bash
chmod +x deploy.sh
./deploy.sh
```

**What happens:**

1. **Prerequisites check** (5 seconds)
   ```
   ✅ Terraform found
   ✅ Ansible found
   ✅ terraform.tfvars found
   ✅ Cloud-init files found
   ```

2. **Terraform creates VMs** (3-4 minutes)
   ```
   Creating 5 VMs:
     - prom1 (10.42.88.1)
     - prom2 (10.42.88.2)
     - controller (10.42.88.120)
     - worker1 (10.42.88.121)
     - worker2 (10.42.88.122)
   
   [Progress bars showing VM creation]
   ✅ VMs created successfully!
   ```

3. **Wait for cloud-init** (30-60 seconds)
   ```
   Clearing old SSH host keys...
   ✅ SSH host keys cleared
   Checking if cloud-init has completed...
   ✅ Cloud-init completed on controller!
   ```

4. **Test SSH connectivity** (10 seconds)
   ```
   Testing SSH to all 5 servers...
   ✅ All servers are reachable via SSH
   ```

5. **Install MicroK8s** (4-5 minutes)
   ```
   Installing MicroK8s 1.34 on cluster nodes...
   
   [Ansible playbook runs]
   
   PLAY RECAP *********************************************************************
   k8s-controller  : ok=15   changed=9
   k8s-worker1     : ok=12   changed=6
   k8s-worker2     : ok=12   changed=6
   
   ✅ MicroK8s cluster deployed successfully!
   ```

6. **Success!**
   ```
   ╔════════════════════════════════════════════════════════════╗
   ║                  DEPLOYMENT SUCCESSFUL!                    ║
   ╚════════════════════════════════════════════════════════════╝
   
   📊 INFRASTRUCTURE SUMMARY
   
   Standalone Servers:
     ├─ prom1:      ssh sa@10.42.88.1
     └─ prom2:      ssh sa@10.42.88.2
   
   MicroK8s Cluster:
     ├─ controller: ssh sa@10.42.88.120
     ├─ worker1:    ssh sa@10.42.88.121
     └─ worker2:    ssh sa@10.42.88.122
   
   ╔════════════════════════════════════════════════════════════╗
   ║  ⏱️  Total Deployment Time: 9m 34s                        ║
   ╚════════════════════════════════════════════════════════════╝
   
   ✅ All done! Enjoy your infrastructure! 🎉
   
   🔔🔔🔔  (Triple beep!)
   ```

---

## Step 8: Verify Cluster

```bash
# SSH to controller
ssh sa@10.42.88.120

# Check cluster nodes
microk8s kubectl get nodes
```

**Expected output:**
```
NAME          STATUS   ROLES    AGE   VERSION
controller    Ready    <none>   2m    v1.34.1
worker1       Ready    <none>   1m    v1.34.1
worker2       Ready    <none>   1m    v1.34.1
```

**All show "Ready"?** ✅ Perfect!

```bash
# Check all pods
microk8s kubectl get pods -A
```

Should show pods in these namespaces:
- `kube-system` - Core Kubernetes components
- `container-registry` - Local registry
- `kubernetes-dashboard` - Dashboard components

**All showing "Running"?** ✅ Excellent!

---

## Step 9: Access Dashboard

**See [DASHBOARD-ACCESS.md](DASHBOARD-ACCESS.md) for complete guide**

**Quick access:**

```bash
# On controller (leave running)
ssh sa@10.42.88.120
microk8s kubectl port-forward -n kubernetes-dashboard \
  service/kubernetes-dashboard-kong-proxy 8443:443 --address 0.0.0.0
```

**In new terminal on your machine:**
```bash
# Create tunnel
ssh -L 8443:localhost:8443 sa@10.42.88.120

# Open browser (or visit https://localhost:8443 manually)
open https://localhost:8443
```

---

## Step 10: Deploy Your First App

```bash
# SSH to controller
ssh sa@10.42.88.120

# Create deployment
microk8s kubectl create deployment hello --image=nginxdemos/hello

# Expose as service
microk8s kubectl expose deployment hello --port=80 --type=NodePort

# Get the port
microk8s kubectl get svc hello

# Access your app
curl http://10.42.88.120:<PORT>
```

**See "Hello from..."?** ✅ Your cluster is working!

---

## Next Steps 🎯

### Learn Kubernetes

```bash
# Get kubeconfig for local kubectl
ssh sa@10.42.88.120
microk8s config > ~/kubeconfig

# Copy to your machine
scp sa@10.42.88.120:~/kubeconfig ~/.kube/config

# Use kubectl locally
kubectl get nodes
kubectl get pods -A
```

### Deploy Real Applications

```bash
# Enable more addons
microk8s enable ingress
microk8s enable cert-manager
microk8s enable prometheus

# Deploy apps using Helm
microk8s helm3 install ...
```

### Use Standalone Servers

```bash
# SSH to standalone servers
ssh sa@10.42.88.1   # prom1
ssh sa@10.42.88.2   # prom2

# Install whatever you want!
# Databases, monitoring, CI/CD, etc.
```

---

## Troubleshooting

### Terraform Errors

**"Error: Unable to connect to Proxmox"**
- Check `proxmox_host` in terraform.tfvars
- Verify Proxmox is accessible: `ping 192.168.1.100`
- Check credentials are correct

**"Error: node_name not found"**
- Check node name in Proxmox web UI (left sidebar)
- Update `node_name` in terraform.tfvars

### SSH Errors

**"Permission denied (publickey)"**
```bash
# Check key exists
ls ~/.ssh/proxmox_key

# Check permissions
chmod 600 ~/.ssh/proxmox_key

# Verify .env has correct key name
cat .env | grep SSH_KEY_NAME
```

**"Host key verification failed"**
```bash
# Clear old host keys
ssh-keygen -R 10.42.88.120
ssh-keygen -R 10.42.88.121
ssh-keygen -R 10.42.88.122
```

### Ansible Errors

**"SSH timeout"**
- VMs might still be booting
- Wait 2-3 minutes and try `./test-ansible-config.sh` again

**"ansible_env is undefined"**
- Make sure you have latest `.env` and `deploy.sh`
- Re-download files if needed

### Cluster Issues

**Nodes not Ready:**
```bash
ssh sa@10.42.88.120
microk8s status
microk8s inspect
```

**Dashboard not accessible:**
- See [DASHBOARD-ACCESS.md](DASHBOARD-ACCESS.md)
- Check pods: `microk8s kubectl get pods -n kubernetes-dashboard`

---

## Clean Up / Destroy

**⚠️ WARNING: This destroys ALL 5 VMs immediately!**

```bash
./z-destroy.sh
```

Confirms with:
```
This will destroy ALL infrastructure including:
  - 2 Standalone servers (prom1, prom2)
  - 3 MicroK8s cluster nodes (controller, worker1, worker2)

Are you sure? (yes/no):
```

Type `yes` to destroy.

---

## Common Questions

**Q: Can I change IP addresses?**  
A: Yes, edit `main.tf` and `ansible/inventory.yml`

**Q: Can I add more workers?**  
A: Yes, edit `main.tf` to add worker VMs, then re-run `deploy.sh`

**Q: Can I use existing SSH keys?**  
A: Yes, just set `SSH_KEY_NAME` in `.env` to your key name

**Q: Do I need to run deploy.sh again?**  
A: Only if you destroy the cluster or want to rebuild it

**Q: How much does this cost?**  
A: Software is free! You just need Proxmox server (your hardware)

---

## Success Checklist ✅

After deployment, you should have:

- [ ] 5 VMs running on Proxmox
- [ ] Can SSH to all VMs without password
- [ ] `microk8s kubectl get nodes` shows 3 nodes Ready
- [ ] `microk8s kubectl get pods -A` shows all pods Running
- [ ] Dashboard accessible via port forward
- [ ] Can deploy test application

**All checked?** 🎉 **Congratulations! You're done!**

---

## Get Help 🆘

1. Check logs: `tail -f logs/deploy-*.log`
2. Run diagnostics: `./test-ansible-config.sh`
3. Check [DASHBOARD-ACCESS.md](DASHBOARD-ACCESS.md) for dashboard issues
4. Review [README.md](README.md) troubleshooting section
5. Open an issue with logs

---

**Happy deploying!** 🚀

Back to [README.md](README.md)
