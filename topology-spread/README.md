# Pod Pending: when two spread rules disagree

Companion code for the Cloud Signal Short **"Kubernetes Pod Pending: When Two Spread Rules Disagree"**.

A Pod is Pending although the nodes have room. Two **hard** topology spread constraints can each allow a node, just
not the same one:

| | node 1 (zone A) | node 2 (zone A) | node 3 (zone B) |
|---|:-:|:-:|:-:|
| matching Pods | 2 | 1 | 2 |
| zone rule, maxSkew 1 (A = 3, B = 2) | ✗ | ✗ | ✓ |
| node rule, maxSkew 1 | ✗ | ✓ | ✗ |
| both | ✗ | ✗ | ✗ → **Pending** |

Make the node rule `ScheduleAnyway` and it becomes a preference: node 3 passes the remaining hard zone rule. That's a
trade-off, not a universal fix: node spreading is no longer guaranteed.

## Reproduce it locally

```bash
./run.sh        # needs kind, kubectl and Docker
```

| File | What |
|---|---|
| [`kind-cluster.yaml`](kind-cluster.yaml) | 3 workers: two in zone A, one in zone B |
| [`1-existing-pods.yaml`](1-existing-pods.yaml) | the 5 existing Pods, 2 / 1 / 2 per node |
| [`2-pending.yaml`](2-pending.yaml) | both rules `DoNotSchedule` → Pending |
| [`3-fixed.yaml`](3-fixed.yaml) | node rule `ScheduleAnyway` → scheduled on node 3 |

`kubectl describe pod web-6` shows the reason in the events: the nodes didn't match the Pod's topology spread
constraints.

## Before you change a policy

Check the label selectors (do they match the Pods you think?), which nodes count as domains (labels, taints, node
affinity: see `nodeAffinityPolicy` / `nodeTaintsPolicy`), and both constraints together. On AKS, the zone label is
`topology.kubernetes.io/zone` as well.

## Sources

- Kubernetes: Pod Topology Spread Constraints: https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/
- kind: https://kind.sigs.k8s.io/
