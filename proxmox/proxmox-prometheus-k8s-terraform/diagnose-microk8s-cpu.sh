#!/bin/bash
# MicroK8s CPU Usage Diagnostic
# Checks what's consuming CPU on your MicroK8s nodes

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

echo "MicroK8s CPU Usage Diagnostic"
echo "=============================="
echo ""

echo "Checking all 3 MicroK8s nodes..."
echo ""

for node in "10.42.88.120:controller" "10.42.88.121:worker1" "10.42.88.122:worker2"; do
    IFS=':' read -r ip name <<< "$node"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 $name ($ip)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    echo "1. Current CPU Usage (top processes):"
    echo "--------------------------------------"
    ssh $SSH_KEY_OPT -o StrictHostKeyChecking=no sa@$ip "top -bn1 | head -20" 2>/dev/null || echo "Cannot connect to $name"
    echo ""
    
    echo "2. MicroK8s Processes:"
    echo "----------------------"
    ssh $SSH_KEY_OPT -o StrictHostKeyChecking=no sa@$ip "ps aux | grep -E 'microk8s|containerd|kubelet|k8s' | grep -v grep" 2>/dev/null || echo "Cannot connect to $name"
    echo ""
    
    echo "3. MicroK8s Status:"
    echo "-------------------"
    ssh $SSH_KEY_OPT -o StrictHostKeyChecking=no sa@$ip "sudo microk8s status --wait-ready 2>/dev/null || echo 'MicroK8s not ready'" || echo "Cannot connect to $name"
    echo ""
    
    echo "4. System Load:"
    echo "---------------"
    ssh $SSH_KEY_OPT -o StrictHostKeyChecking=no sa@$ip "uptime" 2>/dev/null || echo "Cannot connect to $name"
    echo ""
    
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Pods Running in Cluster"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ssh $SSH_KEY_OPT -o StrictHostKeyChecking=no sa@10.42.88.120 "sudo microk8s kubectl get pods -A -o wide" 2>/dev/null || echo "Cannot get pod information"

echo ""
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📈 Pod Resource Usage"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ssh $SSH_KEY_OPT -o StrictHostKeyChecking=no sa@10.42.88.120 "sudo microk8s kubectl top pods -A 2>/dev/null || echo 'Metrics not available (metrics-server not enabled)'" || echo "Cannot get metrics"

echo ""
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Node Resource Usage"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ssh $SSH_KEY_OPT -o StrictHostKeyChecking=no sa@10.42.88.120 "sudo microk8s kubectl top nodes 2>/dev/null || echo 'Metrics not available (metrics-server not enabled)'" || echo "Cannot get metrics"

echo ""
echo ""
echo "═══════════════════════════════════════════════════════"
echo "Analysis"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Normal MicroK8s CPU usage baseline:"
echo "  • Controller: 5-20% idle, spikes during operations"
echo "  • Workers: 2-10% idle, higher when running workloads"
echo ""
echo "What consumes CPU in MicroK8s:"
echo "  • containerd: Container runtime (always running)"
echo "  • kubelet: Node agent (always running)"
echo "  • calico-node: Network plugin (always running)"
echo "  • coredns: DNS service (enabled via addon)"
echo "  • registry: Container registry (enabled via addon)"
echo "  • dashboard: Web UI (enabled via addon)"
echo ""
echo "High CPU (>50% sustained) could indicate:"
echo "  ✓ Initial sync after cluster formation (normal, 5-10 min)"
echo "  ✓ Image pulls/caching (normal, temporary)"
echo "  ✓ CrashLoopBackOff pods (check pod status)"
echo "  ✗ Resource limits too low (unlikely with your specs)"
echo "  ✗ Misconfigured workload"
echo ""
echo "To reduce CPU if needed:"
echo "  1. Disable unused addons:"
echo "     ssh sa@10.42.88.120"
echo "     microk8s disable registry  # If not using local registry"
echo "     microk8s disable dashboard # If not using web UI"
echo ""
echo "  2. Check for problematic pods:"
echo "     microk8s kubectl get pods -A"
echo "     microk8s kubectl describe pod <pod-name> -n <namespace>"
echo ""
echo "  3. Wait 10-15 minutes after cluster creation"
echo "     (initial sync/stabilization period)"
echo ""
