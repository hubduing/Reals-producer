# One-time setup: WSL2 + Docker Desktop.
# MUST be run from an elevated (Administrator) PowerShell.
# VT-x must be enabled in BIOS first, otherwise WSL2 will not start.

$ErrorActionPreference = "Stop"

Write-Output "=== Step 1/4: Installing WSL2 ==="
wsl --install --no-distribution
if ($LASTEXITCODE -ne 0) { Write-Warning "wsl --install exited with $LASTEXITCODE" }

Write-Output "=== Step 2/4: Setting WSL default version to 2 ==="
wsl --set-default-version 2

Write-Output "=== Step 3/4: Installing Docker Desktop via winget ==="
winget install -e --id Docker.DockerDesktop --accept-source-agreements --accept-package-agreements
if ($LASTEXITCODE -ne 0) { throw "winget install Docker Desktop failed" }

Write-Output "=== Step 4/4: Starting Docker Desktop ==="
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

Write-Output ""
Write-Output "Docker Desktop is starting."
Write-Output "When it says 'Docker Desktop is running', run:  docker --version"
