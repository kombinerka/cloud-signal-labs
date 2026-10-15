# Cloud Signal · AI-901 · Episode 10: text analysis with Azure Language in Foundry Tools.
# Follows the Microsoft Learn module "Get started with text analysis in Azure"
# (unit "Create a client application that analyzes text").
#
#   pip install azure-ai-textanalytics python-dotenv
#
# .env file:
#   AZURE_LANGUAGE_ENDPOINT=https://<your-resource>.cognitiveservices.azure.com/
#   API_KEY=<your-foundry-key>
import os

from dotenv import load_dotenv
from azure.core.credentials import AzureKeyCredential
from azure.ai.textanalytics import TextAnalyticsClient

# Load environment variables from .env file
load_dotenv()
endpoint = os.getenv("AZURE_LANGUAGE_ENDPOINT")
key = os.getenv("API_KEY")

# Create the client
client = TextAnalyticsClient(endpoint=endpoint, credential=AzureKeyCredential(key))

# Language detection: language name, ISO 639-1 code, confidence score (0 to 1)
text = "Die Wanderschuhe sind bequem, aber die Lieferung hat zu lange gedauert."
result = client.detect_language([text])[0]
print(f"Language      : {result.primary_language.name}")
print(f"ISO code      : {result.primary_language.iso6391_name}")
print(f"Confidence    : {result.primary_language.confidence_score:.2f}")

# PII detection: redacted text plus each entity with its category and confidence score
text = "Please call Alex Example back on 555 0100 about the return."
result = client.recognize_pii_entities([text])[0]
print("Redacted text:", result.redacted_text)
print("\nEntities found:")
for entity in result.entities:
    print(f"  {entity.text} | category={entity.category} | confidence={entity.confidence_score}")
