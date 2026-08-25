# dsh-start

一键启动 DeepSeek Harness Web 的启动器项目。

## 背景

每次启动 DSH Web 都要手动打开 PowerShell 输入 `npx @deepseek-ai/dsh web`，
太长太麻烦。本项目提供两种便捷启动方式。

## 使用方式

### 方式一：桌面快捷方式（推荐，懒人首选）

1. 双击运行一次 `create-shortcut.ps1`（生成桌面图标）
2. 之后双击桌面 **Dsh Start** 图标即可启动

### 方式二：直接运行脚本

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File start-dsh.ps1
```

### 方式三：终端直接输 dsh（需要全局安装）

```powershell
npm i -g @deepseek-ai/dsh
dsh web
```

## 智能行为

`start-dsh.ps1` 会检查 3080 端口：

- **已在运行** → 只打开浏览器（不会重复启动服务）
- **未运行** → 后台启动服务 → 等待就绪 → 自动打开浏览器

## 项目结构

```
dsh-start/
├── start-dsh.ps1        # 核心启动脚本
├── create-shortcut.ps1  # 生成桌面快捷方式（运行一次）
└── README.md
```

## 常见问题

| 问题 | 解决 |
|---|---|
| 找不到 dsh 命令 | 先 `npm i -g @deepseek-ai/dsh` |
| 快捷方式双击没反应 | 重新运行 `create-shortcut.ps1` |
| 服务启动慢 | 看同目录 `dsh-web.log` |
| 想换端口 | 改 `start-dsh.ps1` 里的 `$Port`（需同时改浏览器地址） |

## 许可

MIT
