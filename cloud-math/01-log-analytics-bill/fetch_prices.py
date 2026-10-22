#!/usr/bin/env python3
"""Print current Log Analytics / Azure Monitor list prices for a region from the public Azure Retail Prices API.
Usage: python3 fetch_prices.py westeurope"""
import json, sys, urllib.parse, urllib.request

region = sys.argv[1] if len(sys.argv) > 1 else "westeurope"
WANT = ("Analytics Logs Data Ingestion", "Analytics Logs Data Retention", "Basic Logs Data Ingestion",
        "Auxiliary Logs Data Ingestion", "Search Queries Scanned", "100 GB Commitment Tier Capacity Reservation")
for service in ("Log Analytics", "Azure Monitor"):
    flt = f"serviceName eq '{service}' and armRegionName eq '{region}' and priceType eq 'Consumption'"
    url = "https://prices.azure.com/api/retail/prices?" + urllib.parse.urlencode({"$filter": flt})
    while url:
        data = json.load(urllib.request.urlopen(url, timeout=30))
        for i in data["Items"]:
            if i["meterName"] in WANT:
                print(f'{i["meterName"]:<48} {i["retailPrice"]:>10} {i["currencyCode"]} per {i["unitOfMeasure"]}'
                      f'  (from {i["tierMinimumUnits"]:g})')
        url = data.get("NextPageLink")
