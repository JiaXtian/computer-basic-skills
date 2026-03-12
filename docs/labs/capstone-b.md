---
title: 综合项目 B
summary: 使用 Git + SSH + Shell 建立个人运维脚手架
level: intermediate
prerequisites: ["完成 Git/SSH/Shell 核心章节"]
updated_at: 2026-03-12
---

# 综合项目 B

## 项目目标

构建一个“可复用的个人运维脚手架”：

- 一键连接常用主机
- 一键收集系统诊断信息
- 自动归档日志并备份

## 任务步骤

1. 配置 `~/.ssh/config` 多主机别名。
2. 编写 `collect.sh` 收集 CPU、内存、磁盘、网络信息。
3. 使用 Git 管理脚本并设置版本标签。

## 验收标准

- 脚本支持参数化输入
- 提供错误处理和退出码
- 附带 README 与回滚方案

## 复盘问题

1. 你如何保护脚本中的敏感信息？
2. 你如何让脚手架支持团队共用？
