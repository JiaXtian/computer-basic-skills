---
title: 写作与标注规范
summary: 教程结构、Frontmatter、代码块和难度标签规范
level: beginner
prerequisites: ["了解 Markdown 基础语法"]
updated_at: 2026-03-12
---

# 写作与标注规范

## Frontmatter 最小字段

每个页面必须包含：

```yaml
title: 页面标题
summary: 页面摘要
level: beginner|intermediate
prerequisites: ["前置条件1", "前置条件2"]
updated_at: YYYY-MM-DD
```

## 章节结构

统一顺序：

1. 概念
2. 环境准备
3. 常用命令
4. 实战任务
5. 常见错误
6. 自测题
7. 延伸阅读

## 难度标签

- `L1 入门`：理解概念并完成基础命令
- `L2 进阶`：能组合命令解决问题
- `L3 实战`：可独立搭建或排障

建议在每章开头增加一行：`难度：Lx`。

## 代码块语言标注

必须显式标注：

- `bash`
- `zsh`
- `fish`
- `powershell`

错误示例：未标注语言的裸代码块。

## 命令说明要求

每组命令都要包含：

- 命令作用
- 预期输出（关键字段）
- 回滚或撤销方式
