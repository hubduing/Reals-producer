# Server-side deploy script for reels-finder
# Runs on the "server" (local machine): pulls latest code from GitHub and rebuilds the container.

$ErrorActionPreference = "Continue"

$serverDir = "D:\reels-server\app"
$repoUrl = "https://github.com/hubduing/Reals-producer.git"
$logFile = "D:\reels-server\deploy.log"

# Repo may have been cloned by another user; allow git access under SYSTEM.
git config --global --add safe.directory $serverDir 2>$null

function Write-Log($msg) {
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $msg"
    Write-Output $line
    Add-Content -LiteralPath $logFile -Value $line
}

# 1. Clone the repo on first run
if (-not (Test-Path -LiteralPath (Join-Path $serverDir ".git"))) {
    Write-Log "Cloning repo for the first time..."
    New-Item -ItemType Directory -Path $serverDir -Force | Out-Null
    git clone $repoUrl $serverDir 2>&1 | ForEach-Object { Write-Log $_ }
}

# 2. Fetch and check for updates
Push-Location $serverDir
try {
    git fetch origin 2>&1 | Out-Null
    $localRev = git rev-parse HEAD
    $remoteRev = git rev-parse origin/main

    if ($localRev -ne $remoteRev) {
        Write-Log "New commits found: $localRev -> $remoteRev. Deploying..."
        git pull --rebase origin main 2>&1 | ForEach-Object { Write-Log $_ }
        if ($LASTEXITCODE -ne 0) { throw "git pull failed (exit $LASTEXITCODE)" }
        $buildOut = docker compose up -d --build 2>&1
        $buildOut | ForEach-Object { Write-Log $_ }
        if ($LASTEXITCODE -ne 0) { throw "docker compose failed (exit $LASTEXITCODE)" }
        Write-Log "Deploy finished. Container is running."
    } else {
        Write-Log "No changes (HEAD is $localRev)."
    }
}
catch {
    Write-Log "DEPLOY ERROR: $($_.Exception.Message)"
    exit 1
}
finally {
    Pop-Location
}
