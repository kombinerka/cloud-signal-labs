"""AI-901 Episode 12: transcribe and summarize a voicemail or a meeting recording with Content Understanding.

Same pattern as extract_invoice.py, with a different prebuilt analyzer ID, as in the Learn module unit
"Extract information from audio and video" (prebuilt-audioSearch; prebuilt-videoSearch for video).

Setup:
    pip install azure-ai-contentunderstanding
    export FOUNDRY_ENDPOINT="https://<your-resource>.services.ai.azure.com/"
    export FOUNDRY_KEY="<your Foundry resource key>"
Run:
    python analyze_media.py audio https://<your-host>/samples/voicemail.wav
    python analyze_media.py video https://<your-host>/samples/weekly-meeting.mp4
"""
import os
import sys

from azure.ai.contentunderstanding import ContentUnderstandingClient
from azure.ai.contentunderstanding.models import AnalysisInput
from azure.core.credentials import AzureKeyCredential

ANALYZERS = {"audio": "prebuilt-audioSearch", "video": "prebuilt-videoSearch"}

if len(sys.argv) != 3 or sys.argv[1] not in ANALYZERS:
    sys.exit("usage: python analyze_media.py audio|video <media URL>")
kind, media_url = sys.argv[1], sys.argv[2]

client = ContentUnderstandingClient(
    endpoint=os.environ["FOUNDRY_ENDPOINT"],
    credential=AzureKeyCredential(os.environ["FOUNDRY_KEY"]),
)

poller = client.begin_analyze(
    analyzer_id=ANALYZERS[kind],
    inputs=[AnalysisInput(url=media_url)],
)
result = poller.result()

for content in result.contents:
    # Depending on the analyzer, markdown holds the transcript and fields hold the extracted values.
    print("=== MARKDOWN / TRANSCRIPT ===")
    print(getattr(content, "markdown", None))
    print("=== FIELDS ===")
    print(getattr(content, "fields", None))
