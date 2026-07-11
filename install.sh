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

# 1-Click Cloudflare Deployment Option
echo ""
echo "=============================================="
echo "⚡ OPTION 1: 1-Click Cloudflare Auto-Deployment"
echo "=============================================="
read -p "[INPUT] Do you want to deploy to Cloudflare Workers automatically for free? (y/n): " DEPLOY_CLOUD

if [ "$DEPLOY_CLOUD" = "y" ] || [ "$DEPLOY_CLOUD" = "Y" ]; then
    echo ""
    echo "[AUTH] Authenticating with Cloudflare via browser. Please click 'Allow' in the browser window..."
    npx wrangler login
    
    echo ""
    echo "[DEPLOY] Deploying worker.js to Cloudflare Workers..."
    DEPLOY_OUTPUT=$(npx wrangler deploy worker.js --name unlimited-translation-api --compatibility-date 2023-05-18)
    echo "$DEPLOY_OUTPUT"
    
    # Parse deployed URL using grep
    WORKER_URL=$(echo "$DEPLOY_OUTPUT" | grep -o 'https://unlimited-translation-api\.[a-zA-Z0-9-]*\.workers\.dev' | head -n 1)
    
    if [ -n "$WORKER_URL" ]; then
        echo ""
        echo "[SUCCESS] Cloudflare Worker deployed successfully!"
        echo "Your live cloud translator dashboard: $WORKER_URL"
        
        if command -v xdg-open > /dev/null; then
            xdg-open "$WORKER_URL"
        elif command -v open > /dev/null; then
            open "$WORKER_URL"
        fi
        exit 0
    else
        echo "[ERROR] Cloudflare deployment failed. Falling back to local setup..."
        sleep 2
    fi
fi

# Local Setup Fallback
echo ""
echo "=============================================="
echo "⚡ OPTION 2: Local Server Setup"
echo "=============================================="
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
echo "[SUCCESS] Local Translation Gateway Fully Running!"
echo "=============================================="
echo "Your local server is currently running in the background."
echo "To start it manually later, run 'npm start' in: $PROJECT_DIR"
echo ""
