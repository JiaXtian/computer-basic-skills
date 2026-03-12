# 贡献指南

## 分支策略

- `main`：稳定发布分支（GitHub Pages 来源）
- `feature/*`：功能与内容开发分支
- 所有改动通过 Pull Request 合并

## Commit 规范

推荐使用以下前缀：

- `feat:` 新增功能或新章节结构
- `docs:` 文档内容更新
- `fix:` 错误修复
- `chore:` 构建、配置、工具链维护

示例：

```text
docs(shell): add L2 advanced piping and process chapter
```

## 内容规范

每个教程页面需要包含：

1. 概念
2. 环境准备
3. 常用命令
4. 实战任务
5. 常见错误
6. 自测题
7. 延伸阅读

每一章必须给出：

- 最低环境要求
- 可复制命令块
- 预期输出示例
- 回滚/撤销方案

## 验证要求

PR 提交前建议执行：

```bash
make lint
make build
```

## Pull Request 内容要求

- 修改的章节与目的
- 新增或更新的练习题
- 本地验证结果（构建、lint、链接检查）
- 风险与回滚说明（若有）
