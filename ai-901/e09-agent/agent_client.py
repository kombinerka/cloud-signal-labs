# Cloud Signal · AI-901 · Episode 9: call a Foundry agent from a lightweight client.
# Follows the Microsoft Learn module "Get started with generative AI and agents in Azure"
# (unit "Creating an agent"). The agent (here "gear-helper") is created and saved in the Foundry portal first.
#
#   pip install --pre "azure-ai-projects>=2.0.0b1"
#   pip install azure-identity
#
# Environment variables (never hard-code endpoints):
#   PROJECT_ENDPOINT  e.g. https://<resource>.services.ai.azure.com/api/projects/<project>
#   AGENT_NAME        e.g. gear-helper
# Sign in first (for example with `az login`): a project client needs a Microsoft Entra ID identity,
# key-based authentication is not supported for projects.
import os

from azure.identity import DefaultAzureCredential
from azure.ai.projects import AIProjectClient

project_client = AIProjectClient(
    endpoint=os.environ["PROJECT_ENDPOINT"],
    credential=DefaultAzureCredential(),
)

# Get an existing agent
agent = project_client.agents.get(agent_name=os.environ.get("AGENT_NAME", "gear-helper"))
print(f"Retrieved agent: {agent.name}")

openai_client = project_client.get_openai_client()

# Reference the agent to get a response: no model name, no system prompt, no retrieval code here.
# The instructions, tools and knowledge live in the agent.
response = openai_client.responses.create(
    input=[{"role": "user", "content": "What size should I order in the Ridge boot?"}],
    extra_body={"agent": {"name": agent.name, "type": "agent_reference"}},
)
print(f"Response output: {response.output_text}")

# Note: the portal's "Continue in code" sample and the current SDK quickstart may use a newer form, e.g.
#   extra_body={"agent_reference": {"name": agent.name, "version": agent.version, "type": "agent_reference"}}
# or project_client.get_openai_client(agent_name=...). The form above is the one the AI-901 Learn module teaches.
