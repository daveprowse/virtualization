# Proxmox MicroK8s Deployment 🚀

Automated deployment of a complete MicroK8s Kubernetes cluster on Proxmox using Infrastructure as Code.

## What This Deploys

- **2 Standalone Servers** (Ubuntu 24.04)
  - General purpose VMs - 4 cores, 8GB RAM, 32GB disk each

- **3-Node MicroK8s Cluster** (Kubernetes 1.34)
  - 1 Controller: 8 cores, 16GB RAM, 32GB disk
  - 2 Workers: 4 cores, 8GB RAM, 32GB disk each
  - Pre-configured with DNS, Dashboard, and Registry

**Total: 5 VMs, fully automated deployment in ~10 minutes**

---

## Prerequisites

### Required Software

- **Bash Shell** (v4.0+) - Linux/macOS built-in, Windows use WSL2
- **Terraform** (v1.0+) - [Install Guide](https://developer.hashicorp.com/terraform/install)
- **Ansible** (v2.14+) - [Install Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

### Quick Install

```bash
# macOS
brew install terraform ansible

# Ubuntu/Debian
sudo apt update
sudo apt install terraform ansible

# Verify
terraform --version
ansible --version
```

### Infrastructure

- **Proxmox VE** (v7.0+) with API access
- **SSH Key Pair** (`~/.ssh/proxmox_key` or custom)
- **Network** access to Proxmox and VMs

---

## Quick Start 🎯

**See [QUICKSTART.md](QUICKSTART.md) for detailed tutorial**

### 1. Configure

```bash
# Edit .env (SSH key)
vim .env
# Set: SSH_KEY_NAME=proxmox_key

# Create terraform.tfvars (Proxmox credentials)
vim terraform.tfvars
```

### 2. Test

```bash
./test-ansible-config.sh
```

### 3. Deploy

```bash
./deploy.sh
```

**Takes ~10 minutes. Ends with triple beep! 🔔🔔🔔**

### 4. Access

```bash
ssh sa@10.42.88.120
microk8s kubectl get nodes
```

---

## Documentation 📚

- **[QUICKSTART.md](QUICKSTART.md)** - Step-by-step tutorial
- **[DASHBOARD-ACCESS.md](DASHBOARD-ACCESS.md)** - Access Kubernetes dashboard  
- **[STORAGE.md](STORAGE.md)** - Proxmox storage setup
- **[FILES.md](FILES.md)** - Complete file reference
- **[CHANGES.md](CHANGES.md)** - Version history

---

## Project Structure

```
.env                    # ⭐ Edit this (SSH key)
terraform.tfvars        # ⭐ Create this (Proxmox creds)
deploy.sh               # 🚀 Run this
z-destroy.sh            # ⚠️  Destroys everything
```

**See [FILES.md](FILES.md) for complete structure**

---

## Features ✨

- 🔄 Fully automated deployment
- ⚡ Fast (~10 minutes)
- 🔐 Secure (SSH keys)
- 📝 Infrastructure as Code
- 🎨 Clean output with timer
- 🛠️ Single `.env` config
- 📊 Production ready

---

## Support 🤝

1. Check **[QUICKSTART.md](QUICKSTART.md)**
2. Run `./test-ansible-config.sh`
3. Check `logs/` directory
4. Open an issue

---

## License 📄

MIT License

---

**Happy Deploying!** 🚀
