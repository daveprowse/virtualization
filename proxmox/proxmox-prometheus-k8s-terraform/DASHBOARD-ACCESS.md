# Accessing the Kubernetes Dashboard

## The Issue with dashboard-proxy

The `microk8s dashboard-proxy` command expects the old dashboard layout in `kube-system` namespace, but the modern dashboard (v3.x) is deployed in the `kubernetes-dashboard` namespace with multiple components.

## How to Access the Dashboard

### Method 1: Port Forward (Recommended)

```bash
# SSH to controller
ssh sa@10.42.88.120

# Port forward the dashboard service
microk8s kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard-kong-proxy 8443:443 --address 0.0.0.0
```

Then from your local machine:
```bash
# Create SSH tunnel
ssh -L 8443:localhost:8443 sa@10.42.88.120

# Open browser to:
https://localhost:8443
```

### Method 2: Get the Service URL

```bash
# Check what services are available
microk8s kubectl get svc -n kubernetes-dashboard

# You should see:
# NAME                           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
# kubernetes-dashboard-api       ClusterIP   10.152.183.xx   <none>        8000/TCP   10m
# kubernetes-dashboard-auth      ClusterIP   10.152.183.xx   <none>        8000/TCP   10m
# kubernetes-dashboard-kong-proxy ClusterIP   10.152.183.xx   <none>        443/TCP    10m
# kubernetes-dashboard-metrics-scraper ClusterIP   10.152.183.xx   <none>        8000/TCP   10m
# kubernetes-dashboard-web       ClusterIP   10.152.183.xx   <none>        8000/TCP   10m
```

### Method 3: Create NodePort Service

```bash
# Expose dashboard via NodePort
microk8s kubectl patch svc kubernetes-dashboard-kong-proxy -n kubernetes-dashboard -p '{"spec":{"type":"NodePort"}}'

# Get the NodePort
microk8s kubectl get svc -n kubernetes-dashboard kubernetes-dashboard-kong-proxy

# Access via:
# https://10.42.88.120:<NodePort>
```

### Method 4: Create Token for Access

```bash
# Create service account
microk8s kubectl create serviceaccount dashboard-admin -n kubernetes-dashboard

# Create cluster role binding
microk8s kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:dashboard-admin

# Get token (for k8s 1.24+)
microk8s kubectl create token dashboard-admin -n kubernetes-dashboard --duration=8760h

# Copy the token and use it to log in to the dashboard
```

## Quick Access Script

Save this as `dashboard-access.sh`:

```bash
#!/bin/bash
# Quick dashboard access script

echo "Setting up dashboard access..."
echo ""

# Create service account if it doesn't exist
microk8s kubectl get sa dashboard-admin -n kubernetes-dashboard &>/dev/null || \
  microk8s kubectl create serviceaccount dashboard-admin -n kubernetes-dashboard

# Create cluster role binding if it doesn't exist
microk8s kubectl get clusterrolebinding dashboard-admin &>/dev/null || \
  microk8s kubectl create clusterrolebinding dashboard-admin \
    --clusterrole=cluster-admin \
    --serviceaccount=kubernetes-dashboard:dashboard-admin

# Get token
echo "Your dashboard token (save this!):"
echo "===================================="
TOKEN=$(microk8s kubectl create token dashboard-admin -n kubernetes-dashboard --duration=8760h)
echo "$TOKEN"
echo ""
echo "===================================="
echo ""

# Start port forward
echo "Starting port forward..."
echo "Dashboard will be available at: https://localhost:8443"
echo "Use the token above to log in"
echo ""
echo "Press Ctrl+C to stop"

microk8s kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard-kong-proxy 8443:443 --address 0.0.0.0
```

## Recommended Setup

On the controller:
```bash
# 1. Create the access script
cat > ~/dashboard-access.sh << 'EOF'
#!/bin/bash
microk8s kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard-kong-proxy 8443:443 --address 0.0.0.0
EOF

chmod +x ~/dashboard-access.sh

# 2. Run it
./dashboard-access.sh
```

On your local machine:
```bash
# Create tunnel
ssh -L 8443:localhost:8443 sa@10.42.88.120

# Open browser
open https://localhost:8443  # or visit manually
```

## Why dashboard-proxy Doesn't Work

The error you see:
```
Error from server (NotFound): deployments.apps "kubernetes-dashboard" not found
```

This is because:
- Old dashboard: Single deployment in `kube-system` namespace
- New dashboard: Multiple components in `kubernetes-dashboard` namespace
- The `dashboard-proxy` command hasn't been updated for the new architecture

The dashboard IS running (you can see the pods), it just needs to be accessed differently.

## Verify Dashboard is Running

```bash
# Check all dashboard pods
microk8s kubectl get pods -n kubernetes-dashboard

# Should show 5 pods all Running:
# kubernetes-dashboard-api-xxx
# kubernetes-dashboard-auth-xxx
# kubernetes-dashboard-kong-xxx
# kubernetes-dashboard-metrics-scraper-xxx
# kubernetes-dashboard-web-xxx

# Check services
microk8s kubectl get svc -n kubernetes-dashboard
```

All green? Dashboard is working! Just use one of the access methods above.
