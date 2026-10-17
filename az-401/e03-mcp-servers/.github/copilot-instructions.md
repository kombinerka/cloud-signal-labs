# Pinecone shop — instructions for GitHub Copilot

- This repository is the Pinecone online shop (fictional example).
- Every pull request description links its Azure Boards work item with `AB#<id>`.
- Infrastructure lives in `/infra` as Bicep. Changes there need a review from @pinecone-gear/platform (see CODEOWNERS).
- Never put secrets in code or config. Read them from pipeline variables or Azure Key Vault.
- Update `README.md` when you change how to build or run the shop.
