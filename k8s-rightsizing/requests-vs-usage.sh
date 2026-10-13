#!/usr/bin/env bash
# Requested CPU/memory vs. current usage per pod (needs metrics-server; on AKS it's built in). Read-only.
# One snapshot; look at it over a week or two (or use VPA recommendations) before you change requests.
# Usage: ./requests-vs-usage.sh [namespace]   (default: all namespaces)
set -euo pipefail
ns_args=(-A); [ -n "${1:-}" ] && ns_args=(-n "$1")
kubectl get pods "${ns_args[@]}" -o json | python3 -c '
import json, subprocess, sys
def cpu(v):  # "250m" -> 0.25, "2" -> 2
    return 0.0 if not v else float(v[:-1]) / 1000 if v.endswith("m") else float(v)
def mem(v):  # to MiB
    if not v: return 0.0
    units = {"Ki": 1/1024, "Mi": 1, "Gi": 1024, "K": 1/1048.576, "M": 1/1.048576, "G": 953.674}
    for u, f in units.items():
        if v.endswith(u): return float(v[:-len(u)]) * f
    return float(v) / 1048576
req = {}
for p in json.load(sys.stdin)["items"]:
    c = [x.get("resources", {}).get("requests", {}) for x in p["spec"]["containers"]]
    req[(p["metadata"]["namespace"], p["metadata"]["name"])] = (sum(cpu(r.get("cpu")) for r in c), sum(mem(r.get("memory")) for r in c))
top = subprocess.run(["kubectl", "top", "pods", "-A", "--no-headers"], capture_output=True, text=True).stdout
print("%-50s %8s %8s %9s %9s" % ("namespace/pod", "cpu req", "cpu use", "mem req", "mem use"))
rows = []
for line in top.splitlines():
    ns, pod, c, m = line.split()[:4]
    if (ns, pod) in req:
        rc, rm = req[(ns, pod)]
        rows.append((rc - cpu(c), f"{ns}/{pod}"[:50], rc, cpu(c), rm, mem(m)))
for _, name, rc, uc, rm, um in sorted(rows, reverse=True)[:40]:
    print(f"{name:50} {rc:8.2f} {uc:8.2f} {rm:8.0f}M {um:8.0f}M")
print("\nSorted by unused CPU request (requested - used). Big gaps = money spent on reserved, idle capacity.")
'
