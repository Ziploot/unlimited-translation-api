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

    # 1-Click Cloudflare Automated Deploy Option
    Write-Host "`n==============================================" -ForegroundColor Green
    Write-Host "⚡ OPTION 1: 1-Click Cloudflare Auto-Deployment" -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Green
    $deployCloud = Read-Host "[INPUT] Do you want to deploy to Cloudflare Workers automatically for free? (Y/N)"
    
    if ($deployCloud -eq "Y" -or $deployCloud -eq "y") {
        Write-Host "`nTo deploy, we need your Cloudflare Account details (100% Secure & Local):" -ForegroundColor Cyan
        $cfAccountId = (Read-Host "[INPUT] Enter your Cloudflare Account ID").Trim()
        $cfApiToken = (Read-Host "[INPUT] Enter your Cloudflare API Token").Trim()
        
        if ($cfAccountId -and $cfApiToken) {
            Write-Host "`n[DEPLOY] Reading worker.js content..." -ForegroundColor Cyan
            $workerContent = [System.IO.File]::ReadAllText("$projectFolder\worker.js", [System.Text.Encoding]::UTF8)
            
            Write-Host "[DEPLOY] Uploading & Deploying Worker script to Cloudflare..." -ForegroundColor Cyan
            $cfHeaders = @{
                "Authorization" = "Bearer $cfApiToken"
                "Content-Type" = "application/javascript"
            }
            
            $uploadUrl = "https://api.cloudflare.com/client/v4/accounts/$cfAccountId/workers/scripts/unlimited-translation-api"
            
            try {
                $cfRes = Invoke-RestMethod -Method Put -Uri $uploadUrl -Headers $cfHeaders -Body $workerContent
                
                # Fetch Subdomain
                $subUrl = "https://api.cloudflare.com/client/v4/accounts/$cfAccountId/workers/subdomain"
                $subHeaders = @{ "Authorization" = "Bearer $cfApiToken" }
                $subRes = Invoke-RestMethod -Method Get -Uri $subUrl -Headers $subHeaders
                $subdomain = $subRes.result.subdomain
                
                $workerUrl = "https://unlimited-translation-api.$subdomain.workers.dev"
                
                Write-Host "`n[SUCCESS] Cloudflare Worker deployed successfully!" -ForegroundColor Green
                Write-Host "Your live cloud translator dashboard: $workerUrl" -ForegroundColor Green
                
                Write-Host "`n[BROWSER] Launching your Live Cloud Dashboard..." -ForegroundColor Cyan
                Start-Process $workerUrl
                Read-Host "`nCloud Setup completed! Press Enter to exit..."
                Exit
            } catch {
                Write-Host "`n[ERROR] Cloudflare deployment failed: $_" -ForegroundColor Red
                Write-Host "Please double check your Account ID & API Token." -ForegroundColor Yellow
                Write-Host "Falling back to local setup..." -ForegroundColor Yellow
                Start-Sleep -Seconds 3
            }
        } else {
            Write-Host "[WARN] Credentials not entered. Falling back to local setup..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
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
