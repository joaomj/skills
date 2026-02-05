#!/usr/bin/env bash
set -euo pipefail

# Downloads and installs OpenCode Skills pre-commit hooks in the current project
# Usage: curl -sSL https://raw.githubusercontent.com/joaomj/skills/main/setup-hooks.sh | bash

RAW_URL="https://raw.githubusercontent.com/joaomj/skills/main"

echo "Downloading pre-commit config..."
curl -sSL "$RAW_URL/instructions/.pre-commit-config.yaml" -o .pre-commit-config.yaml

echo "Downloading check_file_length.py..."
mkdir -p .hooks
curl -sSL "$RAW_URL/instructions/check_file_length.py" -o .hooks/check_file_length.py
chmod +x .hooks/check_file_length.py

echo "Updating config to use local hook..."
sed -i.bak 's|python instructions/check_file_length.py|python .hooks/check_file_length.py|' .pre-commit-config.yaml
rm -f .pre-commit-config.yaml.bak

echo "Installing pre-commit..."
pip install -q pre-commit

echo "Installing hooks..."
pre-commit install

echo ""
echo "Done! Pre-commit hooks are now active."
echo "Quality checks will run automatically on every 'git commit'."
