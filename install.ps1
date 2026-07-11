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

    # 1-Click Cloudflare Automated OAuth Deploy Option
    Write-Host "`n==============================================" -ForegroundColor Green
    Write-Host "⚡ OPTION 1: 1-Click Cloudflare Auto-Deployment" -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Green
    $deployCloud = Read-Host "[INPUT] Do you want to deploy to Cloudflare Workers automatically for free? (Y/N)"
    
    if ($deployCloud -eq "Y" -or $deployCloud -eq "y") {
        # Check Node.js is required for Wrangler CLI
        $nodeInstalled = Get-Command node -ErrorAction SilentlyContinue
        if (-not $nodeInstalled) {
            Write-Host "[WARN] Node.js not detected. Installing NodeJS via winget..." -ForegroundColor Yellow
            winget install OpenJS.NodeJS --silent --accept-package-agreements --accept-source-agreements
            $env:Path += ";$env:ProgramFiles\nodejs"
        }

        Write-Host "`n[AUTH] Authenticating with Cloudflare via browser. Please click 'Allow' in the browser window..." -ForegroundColor Cyan
        cmd.exe /c "npx wrangler login"
        
        Write-Host "`n[DEPLOY] Deploying worker.js to Cloudflare Workers..." -ForegroundColor Cyan
        $deployOutput = cmd.exe /c "npx wrangler deploy worker.js --name unlimited-translation-api --compatibility-date 2023-05-18"
        Write-Output $deployOutput
        
        # Parse the deployed URL from Wrangler output
        $urlMatch = [regex]::Match($deployOutput, 'https://unlimited-translation-api\.[a-zA-Z0-9-]+\.workers\.dev')
        if ($urlMatch.Success) {
            $workerUrl = $urlMatch.Value
            Write-Host "`n[SUCCESS] Cloudflare Worker deployed successfully!" -ForegroundColor Green
            Write-Host "Your live cloud translator dashboard: $workerUrl" -ForegroundColor Green
            
            Write-Host "`n[BROWSER] Launching your Live Cloud Dashboard..." -ForegroundColor Cyan
            Start-Process $workerUrl
            Read-Host "`nCloud Setup completed! Press Enter to exit..."
            Exit
        } else {
            Write-Host "`n[ERROR] Cloudflare deployment failed or URL could not be parsed." -ForegroundColor Red
            Write-Host "Falling back to local setup..." -ForegroundColor Yellow
            Start-Sleep -Seconds 3
        }
    }

    # Local Setup Fallback
    Write-Host "`n==============================================" -ForegroundColor Green
    Write-Host "⚡ OPTION 2: Local Server Setup" -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Green
    
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
    Write-Host "[SUCCESS] Local Translation Gateway Fully Running!" -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Green
    Write-Host "Your local server is currently running in the background."
    Write-Host "To start it manually later, run 'npm start' in: $projectFolder"
    
    Read-Host "`nSetup completed. Press Enter to exit..."
} catch {
    Write-Host "[ERROR] An unexpected error occurred: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
}
