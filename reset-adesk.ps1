<#
.SYNOPSIS
  AnyDesk Reset/Backup Tool with colored menu

.OPTIONS
  1 - Reset AnyDesk (keep user.conf)
  2 - Clean Reset AnyDesk (backup first, then remove user.conf)
  3 - Backup user.conf
  4 - Restore user.conf from backup (auto restart AnyDesk)
  5 - Exit
#>

function Ensure-Elevated {
    $isAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        Write-Host "Requesting administrative privileges..."
        $psArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        Start-Process -FilePath powershell -ArgumentList $psArgs -Verb RunAs
        Exit
    }
}
Ensure-Elevated

# --- Variables ---
$progDataAnyDesk = Join-Path $env:ProgramData "AnyDesk"
$appDataAnyDesk  = Join-Path $env:APPDATA "AnyDesk"
$userConf        = Join-Path $appDataAnyDesk "user.conf"
$backupDir       = Join-Path $appDataAnyDesk "Backups"
$anyDeskExePath  = "C:\Program Files (x86)\AnyDesk\AnyDesk.exe"

function Stop-AnyDesk {
    Write-Host "[*] Stopping AnyDesk..." -ForegroundColor Yellow
    Get-Process -Name "AnyDesk" -ErrorAction SilentlyContinue | ForEach-Object {
        try { $_ | Stop-Process -Force; Write-Host "    -> AnyDesk stopped." -ForegroundColor Green }
        catch { Write-Warning "    -> Could not stop AnyDesk: $_" }
    }
}

function Delete-ProgramDataFiles {
    if (Test-Path $progDataAnyDesk) {
        Write-Host "[*] Deleting service* and system* files..." -ForegroundColor Yellow
        Get-ChildItem -Path $progDataAnyDesk -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like 'service*' -or $_.Name -like 'system*' } |
            ForEach-Object {
                try { Remove-Item $_.FullName -Force; Write-Host "    -> Deleted: $($_.Name)" -ForegroundColor Green }
                catch { Write-Warning "    -> Failed to delete $($_.Name)" }
            }
    }
}

function Delete-UserConf {
    if (Test-Path $userConf) {
        try {
            Remove-Item $userConf -Force
            Write-Host "    -> user.conf removed." -ForegroundColor Red
        } catch {
            Write-Warning "    -> Failed to delete user.conf: $_"
        }
    } else {
        Write-Host "    -> user.conf not found." -ForegroundColor DarkGray
    }
}

function Backup-UserConf {
    if (Test-Path $userConf) {
        try {
            if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir | Out-Null }
            $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
            $backupFile = Join-Path $backupDir "user.conf.$timestamp.bak"
            Copy-Item $userConf $backupFile -Force
            Write-Host "    -> Backed up user.conf to $backupFile" -ForegroundColor Green
        } catch {
            Write-Warning "Backup failed: $_"
        }
    } else {
        Write-Host "    -> user.conf not found." -ForegroundColor DarkGray
    }
}

function Restore-UserConf {
    if (-not (Test-Path $backupDir)) {
        Write-Host "    -> No backups found." -ForegroundColor Red
        return
    }

    $backups = Get-ChildItem -Path $backupDir -Filter "user.conf.*.bak" | Sort-Object LastWriteTime -Descending
    if ($backups.Count -eq 0) {
        Write-Host "    -> No backups available." -ForegroundColor Red
        return
    }

    Write-Host ""
    Write-Host " Backups directory: $backupDir" -ForegroundColor DarkCyan
    Write-Host " Available backups:" -ForegroundColor Cyan
    for ($i=0; $i -lt $backups.Count; $i++) {
        Write-Host (" [{0}] {1}" -f ($i+1), $backups[$i].Name) -ForegroundColor White
    }

    $choice = Read-Host "`nEnter number of backup to restore (or 0 to cancel)"
    if ($choice -match '^\d+$' -and $choice -gt 0 -and $choice -le $backups.Count) {
        $selected = $backups[$choice-1].FullName
        try {
            Copy-Item $selected $userConf -Force
            Write-Host "    -> Restored user.conf from $($backups[$choice-1].FullName)" -ForegroundColor Green
            Start-AnyDesk
        } catch {
            Write-Warning "Failed to restore backup: $_"
        }
    } else {
        Write-Host "    -> Restore cancelled." -ForegroundColor Yellow
    }
}


function Start-AnyDesk {
    if (Test-Path $anyDeskExePath) {
        Start-Process $anyDeskExePath
        Write-Host "    -> AnyDesk started." -ForegroundColor Green
    } else {
        Write-Warning "    -> AnyDesk not found at $anyDeskExePath"
    }
}

# --- Menu Loop ---
do {

    Clear-Host
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "                                                  " -ForegroundColor Green               
    Write-Host "     _       _           _      _____           _ " -ForegroundColor Green
    Write-Host "    / \   __| | ___  ___| | __ |_   _|__   ___ | |" -ForegroundColor Green
    Write-Host "   / _ \ / _  |/ _ \/ __| |/ /   | |/ _ \ / _ \| |" -ForegroundColor Green
    Write-Host "  / ___ \ (_| |  __/\__ \   <    | | (_) | (_) | |" -ForegroundColor Green
    Write-Host " /_/   \_\__,_|\___||___/_|\_\   |_|\___/ \___/|_|" -ForegroundColor Green
    Write-Host "                                                  " -ForegroundColor Green
    Write-Host "          AnyDesk Reset/Backup Tool               " -ForegroundColor Yellow
    Write-Host "                                                  " -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " [1] Reset AnyDesk (keep user.conf)" -ForegroundColor White
    Write-Host " [2] Clean Reset AnyDesk (backup first, remove user.conf)" -ForegroundColor White
    Write-Host " [3] Backup user.conf" -ForegroundColor White
    Write-Host " [4] Restore user.conf from backup" -ForegroundColor White
    Write-Host " [5] Exit" -ForegroundColor White
    Write-Host ""
    $choice = Read-Host "Select option (1-5)"

    switch ($choice) {
        '1' {
            Stop-AnyDesk
            Delete-ProgramDataFiles
            Start-AnyDesk
            Pause
        }
        '2' {
            Backup-UserConf
            Stop-AnyDesk
            Delete-ProgramDataFiles
            Delete-UserConf
            Start-AnyDesk
            Pause
        }
        '3' {
            Backup-UserConf
            Pause
        }
        '4' {
            Restore-UserConf
            Pause
        }
        '5' {
            Write-Host "Exiting..." -ForegroundColor Yellow
        }
        default {
            Write-Host "Invalid choice, please select 1-5." -ForegroundColor Red
            Pause
        }
    }
} until ($choice -eq '5')
Write-Host "Goodbye!" -ForegroundColor Green