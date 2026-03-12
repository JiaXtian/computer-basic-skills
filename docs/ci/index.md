---
title: CI/CD 模块总览
summary: GitHub Actions 持续集成与文档自动发布基础
level: beginner
prerequisites: ["掌握 Git L2"]
updated_at: 2026-03-12
---

# CI/CD 模块总览

难度：L2 进阶

## 1. 概念

CI/CD 目标是把“人工检查”变成“自动化门禁”，提升交付稳定性。

## 2. 环境准备

- GitHub 仓库
- `main` 保护分支（可选）
- 已配置 Pages Source 为 GitHub Actions

## 3. 常用命令

```bash
# 本地先行验证
mkdocs build --strict
markdownlint-cli2 "**/*.md"
lychee README.md docs/**/*.md --no-progress
```

## 4. 实战任务

任务：提交一次文档变更并通过完整流水线。

1. 新建 `feature/*` 分支并修改文档。
2. 提交 PR，等待 Docs CI 通过。
3. 合并到 main，观察 Pages 自动发布。

回滚/撤销方案：revert 触发发布的提交。

## 5. 常见错误

- Workflow 失败：依赖未安装或命令版本不兼容。
- Pages 无更新：检查 `pages.yml` 执行状态和权限。

## 6. 自测题

1. 为什么要在 PR 阶段执行链接检查？
2. 发布失败时你会先看哪个 Job 日志？
3. 什么情况下应该阻止自动部署？

## 7. 延伸阅读

- GitHub Actions Docs: https://docs.github.com/actions
