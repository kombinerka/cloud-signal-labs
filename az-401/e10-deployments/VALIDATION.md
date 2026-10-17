# Validation (2026-10-16)

```
for f in azure-pipelines.yml rolling-vm.yml .github/workflows/release.yml; do
  python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" "$f"; done    # all OK (PyYAML 6.0.3)
actionlint .github/workflows/release.yml                                         # actionlint 1.7.12, 0 findings
```

Notes
- Azure Pipelines files were checked for parsing only; no Azure DevOps organization was used. Task inputs follow
  the Learn task reference: SqlAzureDacpacDeployment@1, AzureWebAppContainer@1, AzureWebApp@1,
  AzureAppServiceManage@0 (Action: Swap Slots). The rolling strategy follows the deployment jobs article
  (VM resources only; environment `tags` filter from the YAML schema).
- GitHub actions/versions as shown on Microsoft Learn: azure/login@v2, azure/webapps-deploy@v3 (`slot-name`,
  `images`, `package`), azure/sql-action@v2.3; `az webapp deployment slot swap` from the App Service slots article.
- The rollback (swap the same slots again) is only correct if the swap already happened; see the comments.
- Nothing was run against a live Azure subscription. All names, servers and registries are fictional.
