# 计算机基础技能文档站

这是一个基于 **MkDocs + Material** 的计算机基础技能教程项目，使用 Markdown 作为唯一内容源，目标部署到 GitHub Pages。

## 教程目标

- 提供从零基础到进阶的系统化学习路径
- 覆盖 Shell、Git、SSH、Docker 等核心技能
- 每章包含：概念、环境准备、命令、实战、排错、自测、延伸阅读
- 支持本地预览、容器预览、CI 质量门禁、自动发布

## 快速开始

### 1) 本地运行

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
mkdocs serve
```

打开 `http://127.0.0.1:8000`。

### 2) Docker 运行

```bash
docker compose up --build
```

### 3) 构建站点

```bash
mkdocs build --strict
```

## 项目结构

```text
.
├── docs/
│   ├── shell/ git/ ssh/ docker/ linux/ network/ ci/
│   ├── labs/                     # 实验与综合项目
│   ├── cheatsheets/              # 速查表
│   ├── standards/                # 写作规范
│   └── guides/                   # 章节模板
├── .github/workflows/            # CI 与 Pages 发布
├── mkdocs.yml
├── Dockerfile
└── docker-compose.yml
```

## 发布到 GitHub Pages

1. 将仓库推送到 GitHub。
2. 在仓库 `Settings -> Pages` 中选择 `GitHub Actions` 作为 Source。
3. 将 `mkdocs.yml` 中的 `<YOUR_GITHUB_USERNAME>` 替换为你的 GitHub 用户名。
4. 向 `main` 分支推送后，`Deploy Docs to GitHub Pages` 工作流会自动发布。

## 分支与提交规范

- 分支：`main` + `feature/*`
- 提交前缀：`feat`、`docs`、`fix`、`chore`
- 使用 PR 合并，必须包含章节变更说明与验证结果

详细规则见 [CONTRIBUTING.md](CONTRIBUTING.md)。
