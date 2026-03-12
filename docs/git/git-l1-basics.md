---
title: Git L1 基础
summary: Git 基础命令与版本快照模型
level: beginner
prerequisites: ["完成 Shell L1"]
updated_at: 2026-03-12
---

# Git L1 基础

难度：L1 入门

## 1. 概念

Git 保存的是“快照”而非简单差异。每次提交都记录当前项目状态。

核心对象：

- 工作区（Working Tree）
- 暂存区（Index/Staging）
- 仓库（Repository）

## 2. 环境准备

```bash
git --version
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

预期输出示例：

```text
git version 2.x.x
```

## 3. 常用命令

```bash
mkdir git-demo && cd git-demo
git init

echo "# demo" > README.md
git status
git add README.md
git commit -m "feat: init demo"

git log --oneline --graph --decorate
```

关键命令说明：

- `git add`：把变更加入暂存区
- `git commit`：把暂存区快照写入历史
- `git restore --staged <file>`：取消暂存
- `git restore <file>`：丢弃工作区修改

## 4. 实战任务

任务：完成 3 次提交并回看差异。

```bash
echo "line1" >> notes.txt
git add notes.txt && git commit -m "docs: add notes line1"

echo "line2" >> notes.txt
git add notes.txt && git commit -m "docs: add notes line2"

git show HEAD~1
git diff HEAD~1 HEAD
```

回滚/撤销方案：

```bash
# 撤销最后一次提交但保留改动
git reset --soft HEAD~1
```

## 5. 常见错误

- 现象：提交了不该提交的文件
  - 解决：`git rm --cached <file>` 并更新 `.gitignore`
- 现象：`Author identity unknown`
  - 解决：配置 `user.name` 和 `user.email`

## 6. 自测题

1. `git add` 和 `git commit` 的区别是什么？
2. `git restore` 与 `git reset` 作用边界是什么？
3. 为什么推荐使用语义化 commit message？

## 7. 延伸阅读

- Pro Git Book: https://git-scm.com/book/zh/v2
