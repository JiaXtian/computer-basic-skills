---
title: Shell L3 实战
summary: 自动备份、日志分析、批量处理综合练习
level: intermediate
prerequisites: ["已掌握 Shell L1/L2"]
updated_at: 2026-03-12
---

# Shell L3 实战

难度：L3 实战

## 1. 概念

L3 关注“可交付脚本”：

- 可重复执行
- 失败可定位
- 变更可回滚

## 2. 环境准备

最低要求：

- Bash 4+
- `tar`, `find`, `grep`, `awk`

```bash
command -v tar find grep awk
```

## 3. 常用命令

```bash
# 打包备份
tar -czf backup-$(date +%F).tar.gz ./data

# 查找7天内变更的日志
find ./logs -type f -name "*.log" -mtime -7

# 统计接口状态码
awk '{print $9}' access.log | sort | uniq -c | sort -nr
```

## 4. 实战任务

任务 A：备份脚本（带保留策略）

```bash
cat > backup.sh <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

src=${1:-./data}
out=${2:-./backup}
mkdir -p "$out"

archive="$out/backup-$(date +%F-%H%M%S).tar.gz"
tar -czf "$archive" "$src"

# 仅保留最近7个备份
ls -1t "$out"/backup-*.tar.gz | tail -n +8 | xargs -r rm -f

echo "created: $archive"
SCRIPT

chmod +x backup.sh
./backup.sh ./data ./backup
```

任务 B：批量重命名

```bash
# 将 .txt 改为 .md（演示）
for f in *.txt; do mv "$f" "${f%.txt}.md"; done
```

回滚/撤销方案：

```bash
# 撤销备份脚本
rm -f backup.sh

# 如果误改名，可反向执行
for f in *.md; do mv "$f" "${f%.md}.txt"; done
```

## 5. 常见错误

- 现象：`xargs: argument line too long`
  - 解决：使用 `find ... -exec ... +` 或分批处理
- 现象：备份目录不断膨胀
  - 解决：增加保留策略和容量告警

## 6. 自测题

1. 为什么备份脚本要加保留策略？
2. 批量重命名如何避免覆盖同名文件？
3. 如何给脚本加日志级别（INFO/WARN/ERROR）？

## 7. 延伸阅读

- GNU Coreutils: https://www.gnu.org/software/coreutils/
