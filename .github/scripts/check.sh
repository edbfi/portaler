#!/usr/bin/env bash
set -euo pipefail
bunx --bun biome ci .
bun run check
bun run test
python3 -B -m unittest discover -s tests -p 'test_*.py'
bun run build
