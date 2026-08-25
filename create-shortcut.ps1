# ============================================================
#  create-shortcut.ps1 — 在桌面生成 "Dsh Start" 快捷方式
#  用法: 双击运行一次即可; 已存在则覆盖更新
# ============================================================

$ErrorActionPreference = "Stop"

$projectDir = $PSScriptRoot
$startScript = Join-Path $projectDir "start-dsh.ps1"
$desktop = [Environment]::GetFolderPath("Desktop")
$lnkPath = Join-Path $desktop "Dsh Start.lnk"

if (-not (Test-Path $startScript)) {
    Write-Host "错误: 找不到 $startScript"
    exit 1
}

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($lnkPath)

# 目标: powershell 执行启动脚本（-NoProfile 提速; -ExecutionPolicy Bypass 防策略拦截）
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$startScript`""
$shortcut.WorkingDirectory = $projectDir
$shortcut.Description = "一键启动 DeepSeek Harness Web"
$shortcut.IconLocation = "shell32.dll,220"   # 蓝色鲸鱼/电脑图标; 可改成你喜欢的
$shortcut.WindowStyle = 7                    # 最小化

$shortcut.Save()

Write-Host "✅ 快捷方式已创建: $lnkPath"
Write-Host "   双击桌面 [Dsh Start] 即可启动 DSH Web"
