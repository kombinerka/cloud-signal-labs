# Validation (AZ-401 episode 6, run 2026-10-16)

Commands run from this `code/` folder:

```
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" azure-pipelines.yml                       # OK
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" .github/workflows/publish-package.yml     # OK
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" .github/workflows/build.yml               # OK
python3 -c "import xml.dom.minidom; xml.dom.minidom.parse('nuget.config')"                                # OK
```

What this proves: the files parse. They were not run against a live Azure DevOps organization or GitHub
repository (the names are fictional). Task inputs (DotNetCoreCLI@2 pack/versioningScheme/versionEnvVar,
NuGetAuthenticate@1, the publish keyword), the run-number tokens and the counter expression follow the
Microsoft Learn pages listed in ../SOURCES.md; the GitHub workflows follow docs.github.com
("Publishing Node.js packages", "Store and share data with workflow artifacts").
No secrets: the Azure Artifacts push uses NuGetAuthenticate@1 (the `--api-key` value is a required placeholder
string), and GitHub Packages uses the built-in GITHUB_TOKEN.
