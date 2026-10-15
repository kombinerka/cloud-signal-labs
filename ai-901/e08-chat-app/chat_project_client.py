"""Pinecone gear helper through the Foundry project client (AI-901 Episode 8).

Pattern from the Microsoft Learn unit "Creating an agent" (AIProjectClient +
get_openai_client) and the Foundry SDK quickstart ("Chat with a model").
A project connection needs a Microsoft Entra ID identity: sign in with `az login` first.

Install:  pip install azure-ai-projects azure-identity openai
Set:      PROJECT_ENDPOINT  (https://<resource>.services.ai.azure.com/api/projects/<project>)
          DEPLOYMENT_NAME
"""
import os

from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential

project_client = AIProjectClient(
    endpoint=os.environ["PROJECT_ENDPOINT"],
    credential=DefaultAzureCredential(),
)
openai_client = project_client.get_openai_client()

response = openai_client.responses.create(
    model=os.environ["DEPLOYMENT_NAME"],
    input=[
        {"role": "system", "content": "You are Pinecone's gear helper."},
        {"role": "user", "content": "Which boots suit a muddy trail?"},
    ],
)

print(response.output_text)
