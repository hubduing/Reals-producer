# Registers the auto-deploy task in Windows Task Scheduler.
# Runs deploy.ps1 every minute so the "server" stays in sync with GitHub.

$ErrorActionPreference = "Stop"

$deployScript = "D:\reels-server\app\deploy.ps1"
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$deployScript`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Minutes 1)
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName "reels-finder-autodeploy" `
    -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force

Write-Output "Auto-deploy task registered. deploy.ps1 will run every minute."
