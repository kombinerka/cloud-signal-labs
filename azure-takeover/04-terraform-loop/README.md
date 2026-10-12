# Option 1: Terraform, done properly

1,600 resources are not written by hand. A loop, one resource group at a time:

1. **Export** a draft: [`export-raw.sh`](export-raw.sh) runs `aztfexport resource-group --hcl-only
   --generate-import-block` into `raw/<rg>/`. Nothing is imported yet.
2. **Refactor** into clean code: variables instead of hard-coded values, modules for repeated patterns, one
   convention for child resources. An AI model can do this first pass, as long as you review what it writes.
3. **Plan until only imports are left**: [`plan-loop.sh`](plan-loop.sh) and
   [`plan-summary.py`](plan-summary.py) reduce the plan to imports plus the attributes that would change, and exit 0
   only when nothing but imports is left. Short output is easier to review (and cheaper if a model reads it).
4. **Pull request, apply, next resource group.** The import blocks make each step reviewable.

Development first, production last, when the loop runs without surprises.

Bicep instead? See [`../05-deployment-stacks/`](../05-deployment-stacks/) and [import-existing](../../import-existing/).
