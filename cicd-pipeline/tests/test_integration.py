"""Slower tests against the packaged artifact: does what we built actually run?"""
import json
import os
import subprocess
import sys
import tarfile
import tempfile
import unittest
from pathlib import Path

ARTIFACT = os.environ.get("ARTIFACT")


@unittest.skipUnless(ARTIFACT, "set ARTIFACT=dist/shop-<version>.tar.gz")
class Integration(unittest.TestCase):
    def test_artifact_runs_with_injected_config(self):
        with tempfile.TemporaryDirectory() as d:
            with tarfile.open(ARTIFACT) as t:
                t.extractall(d, filter="data")
            out = subprocess.run([sys.executable, "-m", "app.shop"], cwd=d, capture_output=True, text=True,
                                 env={**os.environ, "APP_ENV": "test", "VAT_RATE": "0.2"}, check=True)
            self.assertEqual(json.loads(out.stdout), {"env": "test", "vat_rate": 0.2, "example": 120.0})
            self.assertTrue((Path(d) / "VERSION").exists())
