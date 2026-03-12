---
title: Shell L1 基础
summary: Bash 入门与高频命令基础
level: beginner
prerequisites: ["安装 Bash 或使用 macOS/Linux 默认终端"]
updated_at: 2026-03-12
---

# Shell L1 基础

难度：L1 入门

## 1. 概念

Shell 是命令解释器。你输入命令，Shell 解析后调用系统程序执行。

核心概念：

- 当前目录：`pwd`
- 路径切换：`cd`
- 文件操作：`ls`, `cp`, `mv`, `rm`
- 标准流：stdin(0), stdout(1), stderr(2)

## 2. 环境准备

最低环境要求：

- macOS / Linux / WSL
- Bash >= 4.x

版本检查：

```bash
bash --version
pwd
whoami
```

预期输出示例：

```text
GNU bash, version 5.x.x
/Users/yourname
yourname
```

## 3. 常用命令

```bash
# 查看文件并按时间排序
ls -alht

# 创建并进入目录
mkdir -p demo && cd demo

# 输出重定向
echo "hello" > hello.txt

# 追加输出
echo "world" >> hello.txt

# 查看文件内容
cat hello.txt

# 管道：筛选包含 root 的行
cat /etc/passwd | grep root
```

常见用法说明：

- `>` 覆盖写入，`>>` 追加写入
- `|` 将前一个命令的输出作为后一个命令输入
- `2>` 用于重定向错误输出

## 4. 实战任务

任务目标：创建一个目录清单脚本，输出当前目录下前 10 个最大文件。

```bash
cat > top10.sh <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

du -ah . 2>/dev/null | sort -rh | head -n 10
SCRIPT

chmod +x top10.sh
./top10.sh
```

预期输出示例：

```text
120M    ./logs/app.log
80M     ./backup.tar
...
```

回滚/撤销方案：

```bash
rm -f top10.sh
```

## 5. 常见错误

- 现象：`Permission denied`
  - 根因：脚本无执行权限
  - 解决：`chmod +x script.sh`
- 现象：`command not found`
  - 根因：PATH 中没有目标命令
  - 解决：`echo $PATH` 检查并补充

## 6. 自测题

1. `>` 和 `>>` 的差别是什么？
2. 如何只把错误输出保存到文件？
3. 如何查看上一条命令退出码？

## 7. 延伸阅读

- Bash Manual: https://www.gnu.org/software/bash/manual/
- Explain Shell: https://explainshell.com/
