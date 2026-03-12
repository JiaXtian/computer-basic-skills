---
title: Shell L2 进阶
summary: 脚本结构、流程控制、进程与多 Shell 差异
level: intermediate
prerequisites: ["已掌握 Shell L1"]
updated_at: 2026-03-12
---

# Shell L2 进阶

难度：L2 进阶

## 1. 概念

进阶 Shell 的核心是“组合”：把简单命令组合为可靠流程。

关键主题：

- 流程控制：`if/for/while/case`
- 函数封装与参数处理
- 进程与任务控制：`ps`, `kill`, `jobs`, `fg`, `bg`
- 调试与安全：`set -euo pipefail`, `set -x`

## 2. 环境准备

```bash
bash --version
zsh --version || true
fish --version || true
```

预期输出示例：

```text
GNU bash, version 5.x.x
zsh 5.x
fish, version 3.x
```

## 3. 常用命令与写法

```bash
#!/usr/bin/env bash
set -euo pipefail

log_info() {
  echo "[INFO] $*"
}

for file in *.log; do
  [[ -f "$file" ]] || continue
  log_info "processing $file"
  grep -i "error" "$file" | wc -l
done
```

多 Shell 差异速览：

- `bash/zsh`：语法相近，适合脚本兼容
- `fish`：交互体验好，但脚本语法不兼容 Bash
- `powershell`：对象管道，适合 Windows 运维

PowerShell 对应示例：

```powershell
Get-ChildItem *.log | Select-String -Pattern error
```

## 4. 实战任务

任务目标：实现日志统计脚本，统计最近 24 小时 ERROR/WARN 数量。

```bash
cat > log_stat.sh <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

file=${1:-app.log}
[[ -f "$file" ]] || { echo "log file not found: $file"; exit 1; }

err=$(grep -c "ERROR" "$file" || true)
warn=$(grep -c "WARN" "$file" || true)

echo "ERROR=$err"
echo "WARN=$warn"
SCRIPT

chmod +x log_stat.sh
./log_stat.sh app.log
```

回滚/撤销方案：

```bash
rm -f log_stat.sh
```

## 5. 常见错误

- 现象：脚本在 `bash` 下可运行，在 `sh` 下报错
  - 根因：使用了 Bash 专有语法（如 `[[ ]]`）
  - 解决：显式 shebang `#!/usr/bin/env bash`
- 现象：变量含空格导致参数错位
  - 根因：未加双引号
  - 解决：变量引用统一写为 `"$var"`

## 6. 自测题

1. `set -euo pipefail` 三者分别解决什么问题？
2. 为什么生产脚本应避免未引用变量？
3. 你会如何让脚本支持 `--help` 参数？

## 7. 延伸阅读

- ShellCheck: https://www.shellcheck.net/
- Advanced Bash-Scripting Guide: https://tldp.org/LDP/abs/html/
