"""AI-901 Episode 12: extract fields from an invoice with Azure Content Understanding in Foundry Tools.

Follows the Learn module "Get started with AI-powered information extraction in Azure" (unit: Extract information
from documents) and its exercise: package azure-ai-contentunderstanding, ContentUnderstandingClient, begin_analyze
with a prebuilt analyzer, poller.result(), then result.contents -> markdown + fields.

Setup:
    pip install azure-ai-contentunderstanding
    export FOUNDRY_ENDPOINT="https://<your-resource>.services.ai.azure.com/"
    export FOUNDRY_KEY="<your Foundry resource key>"
Run:
    python extract_invoice.py https://<your-host>/invoices/invoice.pdf
"""
import os
import sys

from azure.ai.contentunderstanding import ContentUnderstandingClient
from azure.ai.contentunderstanding.models import AnalysisInput
from azure.core.credentials import AzureKeyCredential

client = ContentUnderstandingClient(
    endpoint=os.environ["FOUNDRY_ENDPOINT"],
    credential=AzureKeyCredential(os.environ["FOUNDRY_KEY"]),
)

invoice_url = sys.argv[1] if len(sys.argv) > 1 else os.environ["INVOICE_URL"]

# Analysis is asynchronous: begin_analyze starts a long-running operation and returns a poller.
poller = client.begin_analyze(
    analyzer_id="prebuilt-invoice",
    inputs=[AnalysisInput(url=invoice_url)],
)
result = poller.result()  # waits for completion; the SDK polls for you

# One content per input: markdown (the text) and fields (the values the schema asks for).
for content in result.contents:
    print("=== MARKDOWN ===")
    print(content.markdown)
    print("=== FIELDS ===")
    print(content.fields)
