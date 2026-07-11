#!/bin/bash
# ZipLoot Linux/macOS 1-Click Serverless Translation Gateway Setup
echo "=============================================="
echo "⚡ ZipLoot - Linux/macOS Auto-Installer ⚡"
echo "=============================================="

# Create project folder locally
PROJECT_DIR="$(pwd)/unlimited-translation-api-project"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Download files from repository
echo "📥 Fetching files..."
curl -sL "https://raw.githubusercontent.com/Ziploot/unlimited-translation-api/main/index.js" -o index.js
curl -sL "https://raw.githubusercontent.com/Ziploot/unlimited-translation-api/main/package.json" -o package.json

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "⚠️ Node.js not detected. Attempting to install Node.js..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y nodejs npm
    elif command -v brew &> /dev/null; then
        brew install node
    elif command -v yum &> /dev/null; then
        sudo yum install -y nodejs npm
    else
        echo "❌ Unsupported package manager. Please install Node.js manually."
        exit 1
    fi
    echo "✅ Node.js successfully installed!"
else
    echo "✅ Node.js is already installed."
fi

echo "📦 Installing dependencies locally..."
npm install

echo -e "\n🎉 Success! Local Translation Gateway configured!"
echo "To start the server, run: npm start"
echo "Open browser at: http://localhost:3000"
