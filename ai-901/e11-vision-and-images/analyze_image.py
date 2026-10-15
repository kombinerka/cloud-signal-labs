"""AI-901 Episode 11: send an image and a question to a vision-enabled model in Microsoft Foundry.

Follows the Learn module "Get started with computer vision in Azure" (unit: Multimodal models for image analysis)
and its exercise: OpenAI Python library, Responses API, one user message with input_text + input_image.

Setup:
    pip install openai
    export FOUNDRY_KEY="<your Foundry resource key>"
    export ENDPOINT="https://<your-resource>.openai.azure.com/openai/v1/"
    export MODEL_NAME="<your deployment name>"   # e.g. a gpt-5-mini deployment
Run:
    python analyze_image.py tent.jpg            # a local image, sent as a base64 data URL
    python analyze_image.py https://.../tent.jpg  # or a URL the service can reach
"""
import base64
import os
import sys
from mimetypes import guess_type

from openai import OpenAI

client = OpenAI(
    api_key=os.environ["FOUNDRY_KEY"],
    base_url=os.environ["ENDPOINT"],
)


def to_image_url(source: str) -> str:
    """Return a URL as-is, or turn a local file into a base64 data URL."""
    if source.startswith(("http://", "https://")):
        return source
    mime_type = guess_type(source)[0] or "image/jpeg"
    with open(source, "rb") as f:
        b64 = base64.b64encode(f.read()).decode("utf-8")
    return f"data:{mime_type};base64,{b64}"


image = sys.argv[1] if len(sys.argv) > 1 else "tent.jpg"
question = input("Question about the image: ").strip() or "What can you tell me about this?"

response = client.responses.create(
    model=os.environ["MODEL_NAME"],  # the deployment name, not the base model name
    input=[
        {
            "role": "user",
            "content": [
                {"type": "input_text", "text": question},
                {"type": "input_image", "image_url": to_image_url(image)},
            ],
        }
    ],
)
print(response.output_text)
