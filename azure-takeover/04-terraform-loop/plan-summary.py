#!/usr/bin/env python3
"""Reduce a Terraform JSON plan to what matters while adopting existing resources.

  terraform plan -out=tfplan && terraform show -json tfplan > tfplan.json
  python3 plan-summary.py tfplan.json

Prints imports, and for anything that would change only the attributes that differ. Exit code 0 when the plan is
imports only (no create, update, replace or delete), 1 otherwise. Short output is easier to review, and cheaper if
an AI model reads it in the cleanup loop.
"""
import json
import sys


def diff(before, after, path=""):
    """Yield (path, before, after) for leaf values that differ."""
    if isinstance(before, dict) and isinstance(after, dict):
        for k in sorted(set(before) | set(after)):
            yield from diff(before.get(k), after.get(k), f"{path}.{k}" if path else k)
    elif isinstance(before, list) and isinstance(after, list) and len(before) == len(after):
        for i, (b, a) in enumerate(zip(before, after)):
            yield from diff(b, a, f"{path}[{i}]")
    elif before != after:
        yield path, before, after


def short(v, n=80):
    s = json.dumps(v)
    return s if len(s) <= n else s[: n - 3] + "..."


def main() -> int:
    plan = json.load(open(sys.argv[1], encoding="utf-8"))
    imports, problems = [], []
    for rc in plan.get("resource_changes", []):
        ch = rc["change"]
        actions = [a for a in ch["actions"] if a != "no-op"]
        if ch.get("importing"):
            imports.append(rc["address"])
        if not actions:
            continue
        if actions == ["read"]:
            continue
        lines = [f"{'/'.join(actions):18} {rc['address']}"]
        if "update" in actions or ("create" in actions and "delete" in actions):
            unknown = ch.get("after_unknown") or {}
            for p, b, a in diff(ch.get("before") or {}, ch.get("after") or {}):
                if a is None and unknown:
                    a = "(known after apply)"
                lines.append(f"    {p}: {short(b)} -> {short(a)}")
            for p in ch.get("replace_paths") or []:
                lines.append(f"    forces replacement: {'.'.join(map(str, p))}")
        problems.append("\n".join(lines))
    print(f"imports: {len(imports)}")
    for p in problems:
        print(p)
    if problems:
        print(f"\n{len(problems)} resource(s) would change. Fix the code until only imports are left.")
        return 1
    print("only imports: ready for a pull request")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
