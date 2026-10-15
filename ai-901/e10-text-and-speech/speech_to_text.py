# Cloud Signal · AI-901 · Episode 10: speech to text with Azure Speech in Foundry Tools.
# Follows the Microsoft Learn module "Get started with speech in Azure" (unit "Speech recognition").
#
#   pip install azure-cognitiveservices-speech
#
# Environment variables: ENDPOINT (your Foundry resource endpoint), FOUNDRY_KEY.
import os

import azure.cognitiveservices.speech as speechsdk

# Set up the speech config using resource endpoint
speech_config = speechsdk.SpeechConfig(
    subscription=os.environ.get("FOUNDRY_KEY"),
    endpoint=os.environ.get("ENDPOINT")
)

# Create a recognizer with microphone input
# (for a recorded voicemail use: speechsdk.audio.AudioConfig(filename="voicemail.wav"))
audio_config = speechsdk.audio.AudioConfig(use_default_microphone=True)
speech_recognizer = speechsdk.SpeechRecognizer(
    speech_config=speech_config,
    audio_config=audio_config
)


# Event handlers
def recognized_handler(evt):
    print(f"Recognized: {evt.result.text}")


def recognizing_handler(evt):
    print(f"Recognizing: {evt.result.text}")


# Connect event handlers
speech_recognizer.recognized.connect(recognized_handler)
speech_recognizer.recognizing.connect(recognizing_handler)

# Start continuous recognition
speech_recognizer.start_continuous_recognition()
print("Say something...")

# Keep the program running
input("Press Enter to stop...")
speech_recognizer.stop_continuous_recognition()
