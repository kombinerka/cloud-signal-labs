#!/usr/bin/env bash
# Find the Fault #2: compare the subject from an AADSTS error with every federated credential
# on a user-assigned managed identity, case-sensitive (as Microsoft Entra ID compares them).
# Usage: ./check-subject.sh <resource-group> <identity-name> '<subject from the error>'
# Example: ./check-subject.sh rg-pinecone-shop id-pinecone-shop-gh 'repo:pinecone-gear/shop:environment:Production'
# Needs: Azure CLI, signed in. Read-only. Checked with bash -n and shellcheck, not run against Azure.
set -euo pipefail

rg="${1:?resource group}"
identity="${2:?identity name}"
presented="${3:?subject from the error message}"

echo "Presented subject: ${presented}"
found_exact=0
found_case=0

while IFS=$'\t' read -r name issuer subject; do
  [ -z "${name}" ] && continue
  if [ "${subject}" = "${presented}" ]; then
    echo "EXACT MATCH     ${name}  ${subject}  (${issuer})"
    found_exact=1
  elif [ "${subject,,}" = "${presented,,}" ]; then
    echo "CASE ONLY       ${name}  ${subject}  <- differs only in case: this is the fault"
    found_case=1
  else
    echo "no match        ${name}  ${subject}"
  fi
done < <(az identity federated-credential list \
           --identity-name "${identity}" \
           --resource-group "${rg}" \
           --query "[].[name, issuer, subject]" -o tsv)

if [ "${found_exact}" -eq 1 ]; then
  echo "OK: a credential matches exactly. Check the issuer and audience next."
elif [ "${found_case}" -eq 1 ]; then
  echo "FAULT: fix the case on one side (the credential, or the workflow's environment name)."
  exit 1
else
  echo "No credential matches, even ignoring case. Compare the issuer and the repository name too."
  exit 2
fi
