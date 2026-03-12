---
title: Git L3 实战
summary: 完整分支协作、发布打标与回滚演练
level: intermediate
prerequisites: ["已掌握 Git L1/L2"]
updated_at: 2026-03-12
---

# Git L3 实战

难度：L3 实战

## 1. 概念

L3 目标是模拟真实团队流程：需求开发 -> 代码审查 -> 合并发布 -> 紧急回滚。

## 2. 环境准备

```bash
git status
git branch -a
git tag
```

## 3. 常用命令

```bash
# 打发布标签
git tag -a v1.0.0 -m "release: v1.0.0"
git push origin v1.0.0

# 快速回滚到指定提交（生成新提交，不改历史）
git revert <commit-id>
```

## 4. 实战任务

任务：完成一次小版本发布并执行回滚演练。

1. 在 `feature/*` 分支完成需求并提交。
2. 合并至 `main`，打标签 `v0.1.0`。
3. 模拟线上缺陷，执行 `git revert`。
4. 记录复盘：缺陷根因、检测缺口、改进项。

预期结果：

- 历史中存在发布标签
- 回滚通过新提交完成
- 主分支始终可构建

回滚/撤销方案：

```bash
# 删除本地标签
git tag -d v0.1.0

# 删除远程标签
git push origin :refs/tags/v0.1.0
```

## 5. 常见错误

- 现象：`detached HEAD`
  - 根因：直接 checkout 到某个提交
  - 解决：`git switch -c fix/from-detached`
- 现象：错误使用 `reset --hard` 导致改动丢失
  - 解决：优先 `revert`，必要时从 `reflog` 恢复

## 6. 自测题

1. 为什么线上回滚优先 `revert` 而非 `reset`？
2. 标签和分支在发布中的职责有何不同？
3. 如何通过 `reflog` 找回误删提交？

## 7. 延伸阅读

- Git Reflog: https://git-scm.com/docs/git-reflog
