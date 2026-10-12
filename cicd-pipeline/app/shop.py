"""A deliberately tiny app, so the pipeline is the interesting part."""
import json
import os


def price_with_vat(net: float, rate: float) -> float:
    return round(net * (1 + rate), 2)


def config() -> dict:
    """Configuration comes from the environment at deploy time, never from the artifact."""
    return {"env": os.environ.get("APP_ENV", "local"), "vat_rate": float(os.environ.get("VAT_RATE", "0.19"))}


if __name__ == "__main__":
    c = config()
    print(json.dumps({**c, "example": price_with_vat(100, c["vat_rate"])}))
