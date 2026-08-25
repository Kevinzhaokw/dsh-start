@echo off
rem ============================================================
rem  dsh-start launcher (cmd wrapper)
rem  Double-click this file to start DSH Web.
rem  Core logic lives in start-dsh.ps1
rem ============================================================
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-dsh.ps1"
