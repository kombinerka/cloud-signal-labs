"""AI-901 Episode 11: create a new image with an image generation model deployed in Microsoft Foundry.

Follows the exercise for the Learn module "Get started with computer vision in Azure": OpenAI Python library,
client.images.generate, base64 result decoded and saved as PNG.

Setup:
    pip install openai
    export FOUNDRY_KEY="<your Foundry resource key>"
    export ENDPOINT="https://<your-resource>.openai.azure.com/openai/v1/"
    export IMAGE_MODEL_NAME="<your text-to-image deployment name>"   # e.g. a gpt-image-1-mini deployment
Run:
    python generate_image.py "A green tent on a misty mountain ridge at sunrise"
"""
import base64
import os
import sys

from openai import OpenAI

client = OpenAI(
    api_key=os.environ["FOUNDRY_KEY"],
    base_url=os.environ["ENDPOINT"],
)

prompt = " ".join(sys.argv[1:]) or "A green tent on a misty mountain ridge at sunrise"

img = client.images.generate(
    model=os.environ["IMAGE_MODEL_NAME"],  # your image model's deployment name
    prompt=prompt,
    n=1,
    size="1024x1024",
)

# GPT-Image models return base64 data, not a link: decode it and save the file.
image_bytes = base64.b64decode(img.data[0].b64_json)
with open("banner.png", "wb") as f:
    f.write(image_bytes)
print("Saved: banner.png")
