# ============================================================
#  dsh-start — 一键启动 DeepSeek Harness Web
#  用法:
#    双击本文件 或 在终端执行:  powershell -File start-dsh.ps1
#  功能:
#    - 已运行(端口 3080 被占用) -> 只打开浏览器
#    - 未运行 -> 后台启动 dsh web 并打开浏览器
# ============================================================

$ErrorActionPreference = "Stop"

# 可调参数
$Port        = 3080
$BrowserUrl  = "http://127.0.0.1:$Port"
$LogFile     = Join-Path $PSScriptRoot "dsh-web.log"

function Test-PortInUse([int]$port) {
    $conn = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    return ($null -ne $conn)
}

# 1) 检查是否已在运行
if (Test-PortInUse $Port) {
    Write-Host "[dsh-start] DSH 已在运行 ($BrowserUrl)，直接打开浏览器..."
    Start-Process $BrowserUrl
    exit 0
}

# 2) 优先用全局 dsh 命令，否则退回 npx
$dshCmd = Get-Command dsh -ErrorAction SilentlyContinue
if (-not $dshCmd) {
    $npxCache = Get-ChildItem "$env:LOCALAPPDATA\npm-cache\_npx" -Directory -ErrorAction SilentlyContinue |
        ForEach-Object { Join-Path $_.FullName "node_modules\.bin\dsh.cmd" } |
        Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($npxCache) { $dshCmd = Get-Item $npxCache }
}

if (-not $dshCmd) {
    Write-Host "[dsh-start] 错误: 找不到 dsh 命令。请先运行: npm i -g @deepseek-ai/dsh"
    exit 1
}

Write-Host "[dsh-start] 启动 DSH Web (端口 $Port)，日志: $LogFile"

# 3) 后台启动服务（窗口最小化驻留）
$exe = if ($dshCmd.Name -match '\.cmd$') { "cmd.exe" } else { $dshCmd.Source }
$args = if ($exe -eq "cmd.exe") { @("/c", "`"$($dshCmd.Source)`"", "web", "--port", "$Port", ">", "`"$LogFile`"", "2>&1") }
         else { @("web", "--port", "$Port") }

Start-Process -FilePath $exe -ArgumentList $args -WindowStyle Minimized

# 4) 等待端口就绪后打开浏览器
Write-Host "[dsh-start] 等待服务就绪..."
$ready = $false
for ($i = 0; $i -lt 60; $i++) {
    Start-Sleep -Seconds 1
    if (Test-PortInUse $Port) { $ready = $true; break }
}
if ($ready) {
    Start-Sleep -Seconds 1
    Start-Process $BrowserUrl
    Write-Host "[dsh-start] 完成! 浏览器已打开 $BrowserUrl"
} else {
    Write-Host "[dsh-start] 服务启动较慢，请稍后手动访问 $BrowserUrl，或查看日志 $LogFile"
}
