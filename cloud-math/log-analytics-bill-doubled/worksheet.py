#!/usr/bin/env python3
"""Cloud Math worksheet: "Why did our logging bill double?"
Pinecone's Log Analytics workspace, one 30-day month, list prices from prices.json.
Change the volumes below (GB per day) to your own numbers from the Usage queries in queries.kql.
Usage: python3 worksheet.py"""
import json
from pathlib import Path

P = json.loads((Path(__file__).parent / "prices.json").read_text())
DAYS = 30

# Assumptions (fictional workload, GB per day of billable data)
OTHER = 15            # every table except ContainerLogV2
CONTAINER_INFO = 5    # ContainerLogV2 at log level info
CONTAINER_DEBUG = 25  # ContainerLogV2 after one service was left on debug
BASIC_SCAN_GB = 2000  # GB/month the team's queries scan in ContainerLogV2 if it moves to Basic


def analytics(gb_per_day):
    gb = gb_per_day * DAYS
    return max(gb - P["analytics_free_gb_per_month"], 0) * P["analytics_ingestion_per_gb"]


def basic(gb_per_day, scan_gb=BASIC_SCAN_GB):
    return gb_per_day * DAYS * P["basic_ingestion_per_gb"] + scan_gb * P["query_scan_per_gb"]


def commitment_100():
    # 100 GB/day tier: billed per day whatever you ingest below 100 GB
    return P["commitment_100gb_per_day"] * DAYS


rows = [
    ("Before (info)", analytics(OTHER + CONTAINER_INFO)),
    ("After (debug left on)", analytics(OTHER + CONTAINER_DEBUG)),
    ("Option A: 100 GB/day commitment tier", commitment_100()),
    ("Option B: ContainerLogV2 to Basic, still debug", analytics(OTHER) + basic(CONTAINER_DEBUG)),
    ("Option C: log level back to info", analytics(OTHER + CONTAINER_INFO)),
    ("Option C + B: info, and ContainerLogV2 on Basic", analytics(OTHER) + basic(CONTAINER_INFO)),
]
print(f'{P["region"]} list prices ({P["currency"]}), {DAYS}-day month\n')
for name, cost in rows:
    print(f"{name:<50} {cost:>10,.2f}")
be = P["commitment_100gb_per_day"] / P["analytics_ingestion_per_gb"]
print(f"\n100 GB/day commitment tier breaks even at about {be:.1f} GB/day (we ingest {OTHER + CONTAINER_DEBUG}).")
