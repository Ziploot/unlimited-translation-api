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
    echo "To deploy, we need your Cloudflare Account details (100% Secure & Local):"
    read -p "[INPUT] Enter your Cloudflare Account ID: " CF_ACCOUNT_ID
    read -p "[INPUT] Enter your Cloudflare API Token: " CF_API_TOKEN
    
    if [ -n "$CF_ACCOUNT_ID" ] && [ -n "$CF_API_TOKEN" ]; then
        echo "[DEPLOY] Uploading & Deploying Worker script to Cloudflare..."
        
        UPLOAD_RES=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/workers/scripts/unlimited-translation-api"             -H "Authorization: Bearer $CF_API_TOKEN"             -H "Content-Type: application/javascript"             --data-binary "@worker.js")
            
        SUBDOMAIN_RES=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/workers/subdomain"             -H "Authorization: Bearer $CF_API_TOKEN")
            
        SUBDOMAIN=$(echo "$SUBDOMAIN_RES" | grep -o '"subdomain":"[^"]*' | grep -o '[^"]*$')
        
        if [ -n "$SUBDOMAIN" ]; then
            WORKER_URL="https://unlimited-translation-api.$SUBDOMAIN.workers.dev"
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
