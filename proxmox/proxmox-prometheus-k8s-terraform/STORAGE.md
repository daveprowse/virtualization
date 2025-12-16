# Proxmox Storage Configuration 💾

Quick guide to Proxmox storage requirements for this deployment.

---

## Quick Summary

**You need TWO storage types:**

1. **ZFS/LVM storage** for VM disks → Default: `local-zfs`
2. **Directory storage** for ISO/snippets → Default: `local`

**Most Proxmox installations have these by default** ✅

---

## Check Your Storage

```bash
# SSH to Proxmox
ssh root@your-proxmox-ip

# List storage
pvesm status

# Should see:
# local        dir      ✅
# local-zfs    zfspool  ✅
```

**Have both?** You're ready to deploy! ✅

---

## Common Issue: Snippets Not Enabled

**Error:** `content type 'snippets' is not allowed`

**Fix in Proxmox Web UI:**
1. Datacenter → Storage
2. Select `local`
3. Edit
4. Check "Snippets" in Content
5. OK

**Or edit config:**
```bash
# SSH to Proxmox
vim /etc/pve/storage.cfg

# Find:
dir: local
        content vztmpl,iso,backup

# Change to:
dir: local
        content vztmpl,iso,backup,snippets
```

---

## Custom Storage Names

**If your storage has different names:**

Edit `main.tf` and change:
```hcl
# For VM disks (find all instances)
datastore_id = "your-zfs-pool-name"

# For cloud-init files (find all instances)
datastore_id = "your-dir-storage-name"
```

Search and replace:
- `local-zfs` → your ZFS/LVM storage
- `local` → your directory storage

---

## Space Required

- **VM Disks:** 160GB (32GB × 5 VMs)
- **ISO/Snippets:** 1GB
- **Total:** ~161GB

**Recommendation:** Have 200GB free

---

## Troubleshooting

| Error | Solution |
|-------|----------|
| `datastore not found` | Check storage name in `pvesm status` |
| `snippets not allowed` | Enable snippets (see above) |
| `out of space` | Free up space or use different storage |

---

**That's it!** Most users don't need to change anything.

Back to [README.md](README.md) | [QUICKSTART.md](QUICKSTART.md)
