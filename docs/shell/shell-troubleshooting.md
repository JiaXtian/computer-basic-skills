---
title: Shell 排错手册
summary: Shell 运行失败的定位方法与标准处理流程
level: intermediate
prerequisites: ["已掌握 Shell 基础"]
updated_at: 2026-03-12
---

# Shell 排错手册

难度：L3 实战

## 1. 概念

排错流程建议固定为：

1. 复现问题
2. 最小化输入
3. 打开调试信息
4. 验证根因
5. 执行修复并回归测试

## 2. 环境准备

```bash
set -x
bash -n your_script.sh
shellcheck your_script.sh || true
```

## 3. 常用排错命令

```bash
# 查看退出码
echo $?

# 跟踪系统调用（Linux）
strace -f -o trace.log ./your_script.sh

# 打印环境变量
env | sort
```

## 4. 实战任务

任务：定位脚本在 CI 中失败但本地成功的问题。

建议步骤：

1. 打印 `pwd`, `whoami`, `env`。
2. 检查是否存在路径硬编码。
3. 检查是否依赖交互输入。
4. 对关键变量加 `echo` 与 `set -x`。

回滚/撤销方案：

```bash
# 删除临时调试日志
rm -f trace.log debug.log
```

## 5. 常见错误

- `bad interpreter: /bin/bash^M`
  - 根因：Windows CRLF 换行
  - 解决：`sed -i '' 's/\r$//' script.sh`（macOS）或 `dos2unix script.sh`
- `unbound variable`
  - 根因：启用 `set -u` 后未定义变量
  - 解决：使用 `${var:-default}`

## 6. 自测题

1. 为什么排错时要固定“最小复现”？
2. `bash -n` 能发现哪类问题？
3. CRLF 问题如何在团队内预防？

## 7. 延伸阅读

- Bash FAQ: https://mywiki.wooledge.org/BashFAQ
