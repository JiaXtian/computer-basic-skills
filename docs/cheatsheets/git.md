---
title: Git 速查
summary: Git 高频命令与恢复命令速查表
level: beginner
prerequisites: ["无"]
updated_at: 2026-03-12
---

# Git 速查

| 场景 | 命令 |
|---|---|
| 查看状态 | `git status` |
| 查看历史 | `git log --oneline --graph --decorate` |
| 新建分支 | `git switch -c feature/x` |
| 同步主分支 | `git fetch origin && git rebase origin/main` |
| 撤销已推送提交 | `git revert <commit>` |
| 找回误删历史 | `git reflog` |
