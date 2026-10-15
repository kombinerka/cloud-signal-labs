# Cloud Signal · AI-901 · Episode 10: text analysis with a general-purpose model (Responses API).
# Follows the Microsoft Learn module "Get started with text analysis in Azure"
# (unit "Create a client application that analyzes text").
#
#   pip install openai python-dotenv
#
# .env file (names must match the code):
#   AZURE_OPENAI_ENDPOINT=https://<your-resource>.openai.azure.com/openai/v1/
#   MODEL_DEPLOYMENT_NAME=<your deployment name>
#   API_KEY=<your-foundry-key>
import os

from dotenv import load_dotenv
from openai import OpenAI

# Load environment variables from .env file
load_dotenv()
endpoint = os.getenv("AZURE_OPENAI_ENDPOINT")
api_key = os.getenv("API_KEY")
deployment_name = os.getenv("MODEL_DEPLOYMENT_NAME")

# Create the client object
client = OpenAI(
    base_url=endpoint,
    api_key=api_key
)

review = "The Ridge boots kept my feet dry all weekend, but the laces broke on day two."

# Make a request using the client
message = client.responses.create(
    model=deployment_name,
    input=f"Give the overall sentiment of this review, then one line per sentence: {review}",
)

# Print the results
print(f"Sentiment: {message.output_text}")
