#!/usr/bin/env bash
# Configures Git to use local .githooks directory.
set -e

git config core.hooksPath .githooks
echo "✅ Git hooks path successfully set to .githooks/"
