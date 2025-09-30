# 🛠 ɅnyDesk Reset/Backup Tool

This tool lets you safely **reset ɅnyDesk**, manage **backups of `user.conf`**, and restore them when needed.
It includes a **colorized interactive menu** for ease of use.

---

## 📌 Features

* ✅ Reset ɅnyDesk without touching your `user.conf`
* ✅ Clean reset (removes `user.conf` after auto-backup)
* ✅ Backup `user.conf` with timestamp to `AppData\ɅnyDesk\Backups`
* ✅ Restore from any saved backup (with full path shown)
* ✅ Auto-elevation (asks for admin if not already elevated)
* ✅ Restarts ɅnyDesk after reset/restore

---

## 📂 Backup Location

Backups are stored here:

```
%APPDATA%\AnyDesk\Backups
```

Each backup is named:

```
user.conf.YYYYMMDD-HHMMSS.bak
```

---

## 🚀 How to Run

### Option 1: Clone or Download

```powershell
powershell -ExecutionPolicy Bypass -File ".\reset-adesk.ps1"
```

### Option 2: One-liner (remote execute with `irm`)


```powershell
irm "https://raw.githubusercontent.com/Kintoyyy/Adesk-Tool/main/reset-adesk.ps1" | iex
```
---

## 📜 Menu Options

When you run the tool, you’ll see:

```
==================================================
                                                                
     _       _           _      _____           _ 
    / \   __| | ___  ___| | __ |_   _|__   ___ | |
   / _ \ / _  |/ _ \/ __| |/ /   | |/ _ \ / _ \| |
  / ___ \ (_| |  __/\__ \   <    | | (_) | (_) | |
 /_/   \_\__,_|\___||___/_|\_\   |_|\___/ \___/|_|
                                                  
          ɅnyDesk Reset/Backup Tool               
                                                  
==================================================

 [1] Reset ɅnyDesk (keep user.conf)
 [2] Clean Reset ɅnyDesk (remove user.conf)
 [3] Backup user.conf
 [4] Restore user.conf from backup
 [5] Exit
```

---

## ⚠️ Notes

* Always trust the script source before using the one-liner.
* Run inside **elevated PowerShell** (admin). The script auto-prompts if not elevated.
* Works on Windows with ɅnyDesk installed in the default path.
