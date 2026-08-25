# ============================================================
#  create-shortcut.ps1 — 在桌面生成 "Dsh Start" 快捷方式
#  用法: 双击运行一次即可; 已存在则覆盖更新
#  说明: 快捷方式指向 start-dsh.cmd（.cmd 双击即执行，
#        不依赖 .ps1 文件关联，避免被文本编辑器打开）
# ============================================================

$ErrorActionPreference = "Stop"

$projectDir = $PSScriptRoot
$launcher = Join-Path $projectDir "start-dsh.cmd"
$desktop = [Environment]::GetFolderPath("Desktop")
$lnkPath = Join-Path $desktop "Dsh Start.lnk"

if (-not (Test-Path $launcher)) {
    Write-Host "错误: 找不到 $launcher"
    exit 1
}

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($lnkPath)

$shortcut.TargetPath = $launcher
$shortcut.Arguments = ""
$shortcut.WorkingDirectory = $projectDir
$shortcut.Description = "一键启动 DeepSeek Harness Web"
$shortcut.IconLocation = "shell32.dll,220"
$shortcut.WindowStyle = 7

$shortcut.Save()

Write-Host "OK: 快捷方式已更新 -> $lnkPath"
