---
title: Git 排错手册
summary: Git 常见误操作修复与历史恢复指南
level: intermediate
prerequisites: ["已掌握 Git 基础"]
updated_at: 2026-03-12
---

# Git 排错手册

难度：L3 实战

## 1. 概念

Git 排错核心是：先保护现场，再修复。

建议流程：

1. `git status` 看当前状态
2. `git log --oneline --graph` 看历史
3. `git reflog` 找回丢失引用
4. 选择安全修复策略

## 2. 环境准备

```bash
git status
git reflog -n 20
```

## 3. 常用排错命令

```bash
# 误删分支后恢复
git reflog
git branch recover-branch <commit-id>

# 撤销最近一次提交（保留修改）
git reset --soft HEAD~1

# 撤销某个已推送提交
git revert <commit-id>
```

## 4. 实战任务

任务：恢复误操作导致丢失的提交。

1. 故意创建一条提交。
2. `git reset --hard HEAD~1` 模拟误删。
3. 通过 `git reflog` 找到丢失提交。
4. `git cherry-pick <commit-id>` 恢复。

回滚/撤销方案：

```bash
# 如果 cherry-pick 出错
git cherry-pick --abort
```

## 5. 常见错误

- 现象：误把大文件提交进仓库
  - 解决：使用 `git rm --cached`，必要时用过滤工具重写历史
- 现象：误将密码提交
  - 解决：立即旋转密钥，并清理历史与缓存

## 6. 自测题

1. `reflog` 与 `log` 的差别是什么？
2. 什么情况下必须重写历史？
3. 为什么修复密钥泄露时“清理历史”还不够？

## 7. 延伸阅读

- GitHub Secret Scanning: https://docs.github.com/en/code-security/secret-scanning
