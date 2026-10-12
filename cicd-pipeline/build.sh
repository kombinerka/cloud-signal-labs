#!/usr/bin/env bash
# Build ONCE: one versioned artifact plus its checksum. Every environment gets exactly this file.
# Usage: VERSION=1.4.0+abc1234 ./build.sh   -> dist/shop-<version>.tar.gz and .sha256
set -euo pipefail
cd "$(dirname "$0")"
version="${VERSION:-0.0.0+$(git rev-parse --short HEAD 2>/dev/null || echo local)}"
mkdir -p dist
echo "$version" > VERSION
tar --sort=name --mtime='2000-01-01' --owner=0 --group=0 -czf "dist/shop-${version}.tar.gz" app VERSION
rm VERSION
(cd dist && sha256sum "shop-${version}.tar.gz" > "shop-${version}.tar.gz.sha256")
echo "dist/shop-${version}.tar.gz"
