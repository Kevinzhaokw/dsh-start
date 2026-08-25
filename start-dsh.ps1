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

# 2) 定位 dsh 命令。注意: 必须找 .cmd shim，不能拿 .ps1
#    (PowerShell 里 Get-Command dsh 会解析到 dsh.ps1，
#     而 Start-Process 打开 .ps1 会被文本编辑器接管!)
$dshCmd = $null

# 2a) 优先: npm 全局安装的 dsh.cmd
$globalShim = Join-Path $env:APPDATA "npm\dsh.cmd"
if (Test-Path $globalShim) { $dshCmd = $globalShim }

# 2b) 其次: npx 缓存的 dsh.cmd
if (-not $dshCmd) {
    $npxCache = Get-ChildItem "$env:LOCALAPPDATA\npm-cache\_npx" -Directory -ErrorAction SilentlyContinue |
        ForEach-Object { Join-Path $_.FullName "node_modules\.bin\dsh.cmd" } |
        Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($npxCache) { $dshCmd = $npxCache }
}

# 2c) 最后: PATH 里显式查找 dsh.cmd (避免 .ps1)
if (-not $dshCmd) {
    $pathShim = Get-Command dsh.cmd -ErrorAction SilentlyContinue
    if ($pathShim) { $dshCmd = $pathShim.Source }
}

if (-not $dshCmd) {
    Write-Host "[dsh-start] 错误: 找不到 dsh 命令。请先运行: npm i -g @deepseek-ai/dsh"
    exit 1
}

Write-Host "[dsh-start] 启动 DSH Web (端口 $Port)"
Write-Host "[dsh-start] 使用: $dshCmd"

# 3) 后台启动服务（直接 Start-Process dsh.cmd，窗口最小化驻留）
#    日志用 -RedirectStandardOutput/-RedirectStandardError 捕获，
#    不要用 cmd /c 加重定向符（嵌套引号会被 cmd 拆碎导致服务未启动）
$outLog = Join-Path $PSScriptRoot "dsh-web.out.log"
$errLog = Join-Path $PSScriptRoot "dsh-web.err.log"
Start-Process -FilePath $dshCmd -ArgumentList @("web", "--port", "$Port") -WindowStyle Minimized `
    -RedirectStandardOutput $outLog -RedirectStandardError $errLog

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
    Write-Host "[dsh-start] 服务启动较慢，请稍后手动访问 $BrowserUrl，或查看日志 $outLog / $errLog"
}
