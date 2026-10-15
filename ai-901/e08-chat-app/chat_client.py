"""Pinecone gear helper: one question, one answer (AI-901 Episode 8).

Follows the chat client in the Microsoft Learn unit "Using a generative AI model"
(module: Get started with generative AI and agents in Azure).

Install:  pip install azure-ai-projects azure-identity openai
Set:      AZURE_OPENAI_ENDPOINT, AZURE_OPENAI_API_KEY, DEPLOYMENT_NAME
"""
import os

from openai import OpenAI

client = OpenAI(
    # The Learn module shows base_url=f"{endpoint}/openai"; the current Responses API docs use .../openai/v1/.
    # AZURE_OPENAI_ENDPOINT here is the resource URL without a path (unlike Episode 10, where it already ends in /openai/v1/).
    base_url=f"{os.environ['AZURE_OPENAI_ENDPOINT'].rstrip('/')}/openai/v1/",
    api_key=os.environ["AZURE_OPENAI_API_KEY"],
)

response = client.responses.create(
    model=os.environ["DEPLOYMENT_NAME"],  # the deployment name, e.g. "gpt-4.1"
    input=[
        {"role": "system", "content": "You are Pinecone's gear helper. Only answer "
                                      "questions about hiking gear and Pinecone orders. "
                                      "Politely decline anything else."},
        {"role": "user", "content": "Which boots suit a muddy trail?"},
    ],
    max_output_tokens=300,
    temperature=0.7,
)

print(response.output_text)
