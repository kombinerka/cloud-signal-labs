#!/usr/bin/env bash
# Reproduce the video on a local kind cluster. Needs: kind, kubectl, Docker.
set -euo pipefail
cd "$(dirname "$0")"
kind create cluster --name spread --config kind-cluster.yaml
kubectl apply -f 1-existing-pods.yaml
kubectl wait --for=condition=Ready pod -l app=web --timeout=120s

kubectl apply -f 2-pending.yaml
sleep 5
kubectl get pod web-6 -o wide
kubectl describe pod web-6 | sed -n '/Events:/,$p'   # "didn't match pod topology spread constraints"

kubectl delete pod web-6
kubectl apply -f 3-fixed.yaml
kubectl wait --for=condition=Ready pod/web-6 --timeout=60s
kubectl get pods -l app=web -o wide                  # web-6 lands on spread-worker3 (zone B)

echo "Clean up with: kind delete cluster --name spread"
