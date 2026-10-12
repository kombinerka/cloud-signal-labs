#!/usr/bin/env python3
"""Which Azure resources does Terraform already manage? Read-only.

Compares the resource IDs in every Terraform state file with what Azure Resource Graph lists, and writes three lists
(plus a fourth for stale state):

  managed.txt        in Azure and in exactly one state file
  unmanaged.txt      in Azure, in no state file (created by hand, or by another tool)
  managed-twice.txt  in more than one state file (two configurations fighting over one resource)
  stale.txt          in a state file but no longer in Azure

Usage:
  # 1. pull every state (one per workspace / environment / backend key)
  terraform -chdir=envs/dev state pull > states/dev.tfstate
  # 2. export Azure (../01-discover/discover.sh writes all-resources.json)
  # 3. compare
  python3 compare.py --azure discovery/2026-10-12/all-resources.json states/*.tfstate --out lists/

Resource Graph lists top-level resources and some child types; Terraform state also holds child resources such as
subnets, role assignments and diagnostic settings. Those only appear in "stale.txt" if their parent is gone, because
IDs under a resource Azure lists are treated as part of it.
"""
import argparse
import json
from collections import defaultdict
from pathlib import Path


def state_ids(path: Path) -> set[str]:
    """Resource IDs in a state file (format v4, as written by `terraform state pull`)."""
    state = json.loads(path.read_text(encoding="utf-8"))
    ids = set()
    for res in state.get("resources", []):
        if res.get("mode") != "managed":
            continue  # data sources only read
        for inst in res.get("instances", []):
            rid = (inst.get("attributes") or {}).get("id")
            if isinstance(rid, str) and rid.lower().startswith("/subscriptions/"):
                ids.add(rid.lower())
    return ids


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--azure", required=True, type=Path, help="JSON array of resources with an 'id' field")
    ap.add_argument("states", nargs="+", type=Path, help="Terraform state files")
    ap.add_argument("--out", type=Path, default=Path("lists"))
    a = ap.parse_args()

    azure = {r["id"].lower() for r in json.loads(a.azure.read_text(encoding="utf-8"))}
    owners: dict[str, list[str]] = defaultdict(list)
    for s in a.states:
        for rid in state_ids(s):
            owners[rid].append(s.name)

    def in_azure(rid: str) -> bool:  # the resource itself, or a child of one Azure lists
        parts = rid.split("/")
        return any("/".join(parts[:n]) in azure for n in range(len(parts), 8, -2))

    managed = sorted(r for r in azure if len(owners.get(r, [])) == 1)
    twice = sorted(f"{r}  <- {', '.join(owners[r])}" for r in azure if len(owners.get(r, [])) > 1)
    unmanaged = sorted(r for r in azure if r not in owners)
    stale = sorted(f"{r}  <- {', '.join(o)}" for r, o in owners.items() if not in_azure(r))

    a.out.mkdir(parents=True, exist_ok=True)
    for name, rows in (("managed", managed), ("unmanaged", unmanaged), ("managed-twice", twice), ("stale", stale)):
        (a.out / f"{name}.txt").write_text("\n".join(rows) + ("\n" if rows else ""), encoding="utf-8")
        print(f"{name:14} {len(rows):6}")
    total = len(azure)
    if total:
        print(f"coverage       {100 * len(managed) / total:5.1f}% of {total} Azure resources in exactly one state")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
