# 计算机基础技能文档站

这是一个基于 **MkDocs + Material** 的静态教程站点，目标是提供“从零上手到可独立实操”的完整技术文档。站点采用“每种技术一个长章节”的结构，避免碎片化页面跳转，便于连续阅读。

## 核心章节

- Shell 与各类 Shell（Bash/Zsh/Fish/PowerShell）
- Git 完整教程
- SSH 完整教程
- Docker 完整教程
- Linux 基础与运维
- 网络诊断与排障
- CI/CD 自动化发布
- GitHub 使用指南

## 项目特点

- 章节内容连贯，包含原理解释与命令参数说明
- 每章配套本地流程图（SVG）提升阅读直观性
- 使用 GitHub Actions 执行构建、Markdown 检查与链接检查
- 合并 `main` 后自动发布至 GitHub Pages

## 本地运行

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
mkdocs serve
```

打开 `http://127.0.0.1:8000`。

## Docker 运行

```bash
docker compose up --build
```

## 构建验证

```bash
mkdocs build --strict
```

## 发布到 GitHub Pages

1. 将仓库推送到 GitHub。
2. 在仓库 `Settings -> Pages` 中选择 `GitHub Actions`。
3. 将 `mkdocs.yml` 中的 `<YOUR_GITHUB_USERNAME>` 替换为你的 GitHub 用户名。
4. 向 `main` 推送后，`Deploy Docs to GitHub Pages` 工作流会自动发布。

## 分支与提交规范

- 分支：`main` + `feature/*`
- 提交前缀：`feat`、`docs`、`fix`、`chore`
- 变更通过 PR 合并并保留验证记录

详细规则见 [CONTRIBUTING.md](CONTRIBUTING.md)。
