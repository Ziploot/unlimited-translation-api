# ZipLoot Windows 1-Click Serverless Translation Gateway Setup
try {
    Write-Host "==============================================" -ForegroundColor Green
    Write-Host "[ZipLoot] Translation Gateway Installer" -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Green

    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $projectFolder = Join-Path $pwd "unlimited-translation-api-project"
    if (Test-Path $projectFolder) {
        Write-Host "[WARN] Folder 'unlimited-translation-api-project' already exists." -ForegroundColor Yellow
    } else {
        New-Item -ItemType Directory -Path $projectFolder -ErrorAction SilentlyContinue | Out-Null
    }

    # Copy files
    Copy-Item -Path "$scriptDir\index.js" -Destination "$projectFolder\index.js" -Force
    Copy-Item -Path "$scriptDir\worker.js" -Destination "$projectFolder\worker.js" -Force
    Copy-Item -Path "$scriptDir\package.json" -Destination "$projectFolder\package.json" -Force
    Copy-Item -Path "$scriptDir\README.md" -Destination "$projectFolder\README.md" -Force

    Set-Location $projectFolder

    # Check Node.js
    $nodeInstalled = Get-Command node -ErrorAction SilentlyContinue
    if (-not $nodeInstalled) {
        Write-Host "[WARN] Node.js not detected. Installing NodeJS via winget..." -ForegroundColor Yellow
        winget install OpenJS.NodeJS --silent --accept-package-agreements --accept-source-agreements
        $env:Path += ";$env:ProgramFiles\nodejs"
    }

    Write-Host "[INSTALL] Installing local dependencies..." -ForegroundColor Cyan
    cmd.exe /c "npm install"

    Write-Host "`n[START] Launching Local Translation Server..." -ForegroundColor Cyan
    # Start the node server in a hidden background window
    Start-Process -FilePath "node" -ArgumentList "index.js" -WorkingDirectory $projectFolder -WindowStyle Hidden
    Start-Sleep -Seconds 2

    Write-Host "`n[BROWSER] Opening Translation Dashboard..." -ForegroundColor Cyan
    Start-Process "http://localhost:3000"

    Write-Host "`n==============================================" -ForegroundColor Green
    Write-Host "[SUCCESS] Translation Gateway Fully Running!" -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Green
    Write-Host "👉 OPTION 1: 1-Click Serverless Cloud Deployment (Cloudflare Workers)" -ForegroundColor Cyan
    Write-Host "No servers to run! Deploy directly to the cloud:"
    Write-Host "1. Open Cloudflare Dashboard -> Create a new Worker"
    Write-Host "2. Copy code from worker.js (in your project folder) and paste it."
    Write-Host "3. Save and Deploy. Your public translation gateway is active!"
    
    Write-Host "`n👉 OPTION 2: Local Server Setup" -ForegroundColor Cyan
    Write-Host "Your server is currently running in the background."
    Write-Host "To start it manually later, run 'npm start' in: $projectFolder"
    
    Read-Host "`nSetup completed. Press Enter to exit..."
} catch {
    Write-Host "[ERROR] An unexpected error occurred: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
}
