# What artifact attestations actually prove

Companion code for the Cloud Signal Short **"What GitHub Artifact Attestations Actually Prove"**.

A green workflow doesn't prove that the file in front of you came from that workflow. An attestation adds signed
provenance (this digest was built by this workflow, from this repository and ref), but the security control is the
**verification**: before you deploy or run the artifact, check digest, signature, source and builder against what you
expect. Change one byte, or build it somewhere else, and the gate rejects it.

| Platform | How | File |
|---|---|---|
| GitHub Actions | `actions/attest` (SLSA build provenance, Sigstore-signed) + `gh attestation verify` as the deploy gate | [`github/.github/workflows/build-attest-verify.yml`](github/.github/workflows/build-attest-verify.yml) |
| GitLab CI | keyless signing with cosign and the job's ID token; `cosign verify-blob` pinned to project, pipeline file and branch | [`gitlab/.gitlab-ci.yml`](gitlab/.gitlab-ci.yml) |
| Azure DevOps | no built-in attestations: cosign with a signing key that stays in Azure Key Vault, verified before deploy | [`azure-devops/azure-pipelines.yml`](azure-devops/azure-pipelines.yml) |
| Your machine | `gh attestation verify` on a downloaded file | [`verify-local.sh`](verify-local.sh) |

## What the GitHub verify step pins

```bash
gh attestation verify app.tar.gz \
  --repo my-org/my-app \
  --signer-workflow my-org/my-app/.github/workflows/build-attest-verify.yml \
  --source-ref refs/heads/main \
  --deny-self-hosted-runners
```

| Flag | Pins |
|---|---|
| `--repo` | built from this repository |
| `--signer-workflow` | by this workflow file |
| `--source-ref` | from this branch |
| `--deny-self-hosted-runners` | on GitHub-hosted runners only |

Without the pins, any attestation from any workflow in the repository would pass. Attestations in private repos
need GitHub Enterprise Cloud; public repos work on every plan.

An attestation proves where an artifact came from. It doesn't prove the code is safe: that's what reviews, tests
and scanning are for.

## Sources

- GitHub Docs: Artifact attestations: https://docs.github.com/en/actions/concepts/security/artifact-attestations
- GitHub Docs: Use artifact attestations: https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations
- SLSA: Verifying artifacts: https://slsa.dev/spec/v1.2/verifying-artifacts
- Sigstore cosign: https://docs.sigstore.dev/cosign/signing/signing_with_blobs/
