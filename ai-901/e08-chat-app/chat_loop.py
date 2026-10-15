"""Pinecone gear helper as a real chat: keeps the conversation history (AI-901 Episode 8).

Same client and call as chat_client.py; the app keeps a growing list of messages and
sends the whole list each turn, as described in the Microsoft Learn unit "Prompts"
(conversation history). Type an empty line to quit.

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

messages = [{"role": "system", "content": "You are Pinecone's gear helper. Only answer "
                                          "questions about hiking gear and Pinecone orders. "
                                          "Politely decline anything else."}]

while True:
    question = input("You: ").strip()
    if not question:
        break
    messages.append({"role": "user", "content": question})
    response = client.responses.create(
        model=os.environ["DEPLOYMENT_NAME"],
        input=messages,
        max_output_tokens=300,
    )
    messages.append({"role": "assistant", "content": response.output_text})
    print("Helper:", response.output_text)
