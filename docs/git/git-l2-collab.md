---
title: Git L2 协作
summary: 分支模型、合并策略与团队工作流
level: intermediate
prerequisites: ["已掌握 Git L1"]
updated_at: 2026-03-12
---

# Git L2 协作

难度：L2 进阶

## 1. 概念

团队协作的关键是：

- 分支隔离开发
- 通过 PR 审核合并
- 保持主分支可发布

## 2. 环境准备

```bash
git branch
git remote -v
```

## 3. 常用命令

```bash
# 新建并切换功能分支
git switch -c feature/login-page

# 开发后提交
git add .
git commit -m "feat: add login page skeleton"

# 同步主分支并变基
git fetch origin
git rebase origin/main

# 推送分支
git push -u origin feature/login-page
```

冲突处理流程：

```bash
# 发生冲突后
# 1) 编辑冲突文件
# 2) git add <resolved-files>
git rebase --continue
```

## 4. 实战任务

任务：模拟两人协作并解决一次冲突。

1. A 分支修改同一行内容并提交。
2. B 分支修改同一行内容并提交。
3. B 执行 `rebase main`，解决冲突后继续。
4. 创建 PR，补充变更说明与验证结果。

回滚/撤销方案：

```bash
# 中止变基
git rebase --abort

# 清理最近一次错误合并（仅本地示例）
git reset --hard HEAD~1
```

## 5. 常见错误

- 现象：`non-fast-forward`
  - 根因：远程分支比本地新
  - 解决：`git pull --rebase` 后再推送
- 现象：冲突多且难定位
  - 解决：缩小提交粒度，按功能拆分提交

## 6. 自测题

1. `merge` 和 `rebase` 的核心区别是什么？
2. 为什么 PR 前建议 `rebase origin/main`？
3. 什么情况下不应该强推远程分支？

## 7. 延伸阅读

- GitHub Flow: https://docs.github.com/en/get-started/using-github/github-flow
