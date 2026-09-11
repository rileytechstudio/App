#!/bin/bash
set -e

# Use Developer Directory if on macOS
if [ -d "/Library/Developer/CommandLineTools" ]; then
  export DEVELOPER_DIR="/Library/Developer/CommandLineTools"
fi

echo "🚀 Building Riley PWA Distribution..."
python3 scripts/build.py
echo "✨ Build completed successfully!"
