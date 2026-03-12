# 贡献指南

## 分支策略

- `main`：稳定发布分支（GitHub Pages 来源）
- `feature/*`：内容和工程配置开发分支
- 所有变更通过 Pull Request 合并

## Commit 规范

建议前缀：

- `feat:` 新增功能
- `docs:` 教程内容变更
- `fix:` 错误修复
- `chore:` 工具链和配置维护

示例：

```text
docs(git): refine rebase and conflict resolution narrative
```

## 文档写作规范（当前站点）

- 每种技术使用“单页长章节”形式，不拆分 L1/L2/L3 子页面。
- 章节正文应连贯叙述，减少碎片化条目堆砌。
- 禁止使用“实战任务”与“自测题”作为固定小节标题。
- 每章建议包含：技术目的、原理解释、命令演示、参数说明、排障思路、完整命令清单、延伸阅读链接。
- 代码块必须标注语言（`bash` / `zsh` / `fish` / `powershell`）。

## 验证要求

PR 提交前建议执行：

```bash
make build
```

如本地已安装 lint/linkcheck 工具，可额外执行：

```bash
make lint
make linkcheck
```

## Pull Request 填写要求

- 变更目标与章节范围
- 命令或参数变更说明
- 本地验证结果（至少构建通过）
- 风险与回滚说明（如有）
