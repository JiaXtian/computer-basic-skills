---
title: 综合项目 A
summary: 从零搭建 文档站 + Docker 本地预览 + GitHub Pages 自动发布
level: intermediate
prerequisites: ["完成 Shell/Git/SSH/Docker 核心章节"]
updated_at: 2026-03-12
---

# 综合项目 A

## 项目目标

独立完成以下闭环：

1. 本地搭建 MkDocs 文档站
2. 使用 Docker 启动本地预览
3. 推送到 GitHub 并自动发布到 Pages

## 任务步骤

1. 创建新章节并通过本地构建。
2. 使用 `docker compose up --build` 预览。
3. 提交 PR 并修复 CI 报错。
4. 合并后验证线上站点可访问。

## 交付标准

- 至少新增 1 个章节页面
- PR 模板完整填写
- CI 全绿
- Pages 发布成功

## 复盘问题

1. 哪个步骤最耗时？为什么？
2. 你如何降低后续发布失败概率？
