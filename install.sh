#!/bin/bash
# ZipLoot Linux/macOS 1-Click Serverless Translation Gateway Setup
echo "=============================================="
echo "[ZipLoot] Translation Gateway Installer"
echo "=============================================="

PROJECT_DIR="unlimited-translation-api-project"
mkdir -p "$PROJECT_DIR"

# Download files
curl -sL "https://raw.githubusercontent.com/Ziploot/unlimited-translation-api/main/index.js" -o "$PROJECT_DIR/index.js"
curl -sL "https://raw.githubusercontent.com/Ziploot/unlimited-translation-api/main/worker.js" -o "$PROJECT_DIR/worker.js"
curl -sL "https://raw.githubusercontent.com/Ziploot/unlimited-translation-api/main/package.json" -o "$PROJECT_DIR/package.json"
curl -sL "https://raw.githubusercontent.com/Ziploot/unlimited-translation-api/main/README.md" -o "$PROJECT_DIR/README.md"

cd "$PROJECT_DIR"
npm install

echo -e "
[START] Launching Local Translation Server..."
node index.js > /dev/null 2>&1 &
sleep 2

echo -e "
[BROWSER] Opening Translation Dashboard..."
if command -v xdg-open > /dev/null; then
    xdg-open "http://localhost:3000"
elif command -v open > /dev/null; then
    open "http://localhost:3000"
fi

echo ""
echo "=============================================="
echo "[SUCCESS] Translation Gateway Fully Running!"
echo "=============================================="
echo "👉 OPTION 1: 1-Click Serverless Cloud Deployment (Cloudflare Workers)"
echo "Deploy directly to the cloud for free ($0 Setup):"
echo "1. Go to Cloudflare Dashboard -> Create a new Worker"
echo "2. Copy code from worker.js and paste it."
echo "3. Click Save & Deploy. Your public gateway is live!"
echo ""
echo "👉 OPTION 2: Local Server Setup"
echo "Your server is currently running in the background."
echo "To start it manually later, run 'npm start' in: $PROJECT_DIR"
echo ""
