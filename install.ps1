# ZipLoot Windows 1-Click Serverless Translation Gateway Setup
try {
    Write-Host "==============================================" -ForegroundColor Green
    Write-Host "[ZipLoot] Translation Gateway Installer" -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Green

    $ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

    # Create project folder locally in the user's CURRENT directory
    $projectFolder = Join-Path $pwd "unlimited-translation-api-project"
    if (Test-Path $projectFolder) {
        Write-Host "[WARN] Folder 'unlimited-translation-api-project' already exists." -ForegroundColor Yellow
    } else {
        New-Item -ItemType Directory -Path $projectFolder -ErrorAction SilentlyContinue | Out-Null
    }

    # Copy template files
    Copy-Item -Path "$scriptDir\\index.js" -Destination "$projectFolder\\index.js" -Force
    Copy-Item -Path "$scriptDir\\package.json" -Destination "$projectFolder\\package.json" -Force

    Set-Location $projectFolder

    # Check Node.js
    $nodeInstalled = Get-Command node -ErrorAction SilentlyContinue
    if (-not $nodeInstalled) {
        Write-Host "[WARN] Node.js not detected. Installing Node.js silently via winget..." -ForegroundColor Yellow
        winget install OpenJS.NodeJS --silent --accept-package-agreements --accept-source-agreements
        $env:Path += ";$env:ProgramFiles\\nodejs"
        
        $nodeVerify = Get-Command node -ErrorAction SilentlyContinue
        if (-not $nodeVerify) {
            Write-Host "[ERROR] Silent Node.js installation failed. Please install Node.js manually." -ForegroundColor Red
            Read-Host "Press Enter to exit..."
            Exit
        }
        Write-Host "[SUCCESS] Node.js successfully installed!" -ForegroundColor Green
    } else {
        Write-Host "[SUCCESS] Node.js is already installed." -ForegroundColor Green
    }

    Write-Host "[INSTALL] Installing dependencies locally..." -ForegroundColor Cyan
    cmd.exe /c "npm install"

    Write-Host "`n[SUCCESS] Local Translation Gateway configured!" -ForegroundColor Green
    Write-Host "To run your translation server locally: " -ForegroundColor Yellow
    Write-Host "1. Open a terminal in the folder: $projectFolder" -ForegroundColor Yellow
    Write-Host "2. Run command: npm start" -ForegroundColor Yellow
    Write-Host "3. Open your browser at: http://localhost:3000" -ForegroundColor Green
    
    Read-Host "`nSetup completed. Press Enter to exit..."
} catch {
    Write-Host "[ERROR] An unexpected error occurred: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
}
