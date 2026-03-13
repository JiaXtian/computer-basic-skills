# GitHub 完整使用指南

> **适用人群**：计算机系新生、转行入门者、需要系统掌握 GitHub 协作流程的开发者  
> **前置要求**：已安装 Git，建议已完成 Git 基础配置（用户名、邮箱、SSH 密钥）  
> **最后更新**：2026-03-13

---


## 1. GitHub 是什么，用来干什么

### 1.1 Git 与 GitHub 的关系

很多初学者会把 Git 和 GitHub 混为一谈，这会造成学习路径上的混乱。在动手之前，先把这个区别说清楚。

**Git** 是一个运行在你本地电脑上的版本控制工具。它负责记录你的代码历史、创建分支、合并代码，所有这些都可以在完全没有网络的情况下完成。

**GitHub** 是一个基于 Git 构建的云端协作平台。它把你本地的 Git 仓库托管到服务器上，并在此基础上提供了一整套团队协作工具：Pull Request、Issue、Projects、Actions、Pages……

用一个比喻来理解：Git 是你本地的"版本管理引擎"，GitHub 是这台引擎与全球开发者互联互通的"高速公路"。你在本地写代码、提交快照是 Git 的工作；你发起 Pull Request 请求他人审查代码、触发自动化测试、把文档部署成网站，这些是 GitHub 的工作。

明白了这层分工，你就不会再疑惑"为什么我有 Git 还需要 GitHub"了。

### 1.2 GitHub 能做哪些事

| 核心功能 | 说明 |
|----------|------|
| **代码托管** | 把本地 Git 仓库同步到云端，随时随地访问 |
| **Pull Request** | 代码审查与合并的标准流程，支持逐行评论 |
| **Issue** | 需求、Bug、讨论的统一管理入口 |
| **Projects** | 看板式任务追踪，可关联 Issue 和 PR |
| **GitHub Actions** | 自动化工作流：CI 测试、构建、部署等 |
| **GitHub Pages** | 免费托管静态网站，适合文档站和个人主页 |
| **Releases** | 版本发布管理，可上传构建产物 |
| **Wiki** | 项目内置文档系统 |
| **Discussions** | 社区讨论，适合开放式交流 |
| **Security** | 依赖漏洞扫描、密钥泄露检测 |

### 1.3 为什么 GitHub 是行业标准

目前全球超过 1 亿开发者在 GitHub 上托管代码。几乎所有主流开源项目——Linux、React、Vue、Python、VS Code——都把 GitHub 作为主要开发协作平台。掌握 GitHub 不仅是技术能力，更是进入开源社区和职场工程协作的通行证。

---

## 2. 账号注册与安全设置

### 2.1 注册账号

前往 [https://github.com](https://github.com) 注册账号。注册时有几点建议：

- **用户名选择**：这将出现在你所有的仓库地址中（如 `github.com/yourname/repo`），建议使用真实姓名拼音或英文名，避免使用随机字符组合，因为这也是你的公开工程档案
- **邮箱**：使用长期稳定的邮箱（推荐 Gmail），避免学校邮箱（毕业后可能失效）
- **验证邮箱**：注册后立即验证邮箱，否则无法创建仓库

### 2.2 启用双因素认证（2FA）

账号安全是第一步，强烈建议注册后立即开启双因素认证：

**设置路径**：`Settings → Password and authentication → Two-factor authentication → Enable`

推荐使用 **Authenticator App**（如 Google Authenticator 或 1Password），相比短信验证码更安全、更稳定。开启 2FA 后，每次登录除了密码，还需要输入动态验证码，即使密码泄露，账号也难以被盗用。

> **重要**：开启 2FA 后，GitHub 会给你一组恢复码（Recovery Codes），务必把它们保存在安全的地方（如密码管理器）。如果手机丢失且没有恢复码，账号将无法找回。

### 2.3 配置 SSH 密钥

使用 SSH 连接 GitHub 有两个好处：第一，不需要每次推送时输入密码；第二，比 HTTPS 更安全，适合长期工程协作。

**第一步：在本地生成 SSH 密钥**

```bash
# 生成 Ed25519 密钥（推荐，比传统 RSA 更安全）
ssh-keygen -t ed25519 -C "you@example.com"

# 按提示操作：
# Enter file in which to save the key: 直接回车使用默认路径
# Enter passphrase: 可以设置密码短语（更安全），也可以直接回车跳过
```

**第二步：查看并复制公钥**

```bash
cat ~/.ssh/id_ed25519.pub
# 输出内容类似：
# ssh-ed25519 AAAAC3Nz... you@example.com
```

将上面输出的全部内容复制到剪贴板。

**第三步：将公钥添加到 GitHub**

进入 `GitHub → Settings → SSH and GPG keys → New SSH key`，粘贴公钥内容，填写一个有意义的标题（比如"MacBook Pro 2025"），点击保存。

**第四步：验证连接**

```bash
ssh -T git@github.com
# 成功输出：
# Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

看到上面的输出，说明 SSH 连接配置成功，后续可以使用 SSH 地址克隆和推送仓库。

### 2.4 完善个人资料

这一步很多人忽略，但对开源贡献和求职展示很重要：

- **头像**：使用真实照片或一致的个人形象
- **Bio**：一句话介绍自己（方向、技术栈、在做什么）
- **个人主页 README**：创建与用户名同名的仓库（`username/username`），其中的 `README.md` 会展示在你的个人首页，是非常好的个人技术名片

---

## 3. 仓库：代码的家

### 3.1 什么是仓库

仓库（Repository，简称 Repo）是 GitHub 上存放一个项目所有文件和历史记录的地方。它不仅包含代码，还包含提交历史、分支、Issue、PR、Wiki 等所有与该项目相关的内容。你可以把仓库理解为"一个项目的完整数字档案"。

### 3.2 创建新仓库

在 GitHub 首页点击右上角的 `+` → `New repository`，进入创建页面：

| 配置项 | 说明 |
|--------|------|
| **Repository name** | 仓库名，建议使用小写字母和连字符，如 `my-project` |
| **Description** | 简短描述，一句话说明项目是做什么的 |
| **Public / Private** | 公开（任何人可见）或私有（只有被授权的人可见） |
| **Add a README** | 强烈建议勾选，这是项目的"门面" |
| **Add .gitignore** | 选择对应的语言模板，避免提交不必要的文件 |
| **Choose a license** | 开源项目建议选择（MIT 或 Apache 2.0 最常见） |

**Public 还是 Private？**

- 学习阶段的项目：选 Public，有助于积累公开的作品集，也方便向他人展示
- 业务项目、含敏感信息的项目：选 Private，默认控制访问范围
- 开源项目：一定选 Public

### 3.3 克隆仓库到本地

创建仓库后，需要把它克隆到本地才能开始开发：

```bash
# 使用 SSH（推荐，已配置 SSH 密钥的情况下）
git clone git@github.com:username/my-project.git

# 使用 HTTPS（无需配置密钥，但每次操作需要身份验证）
git clone https://github.com/username/my-project.git

# 克隆到指定文件夹名
git clone git@github.com:username/my-project.git my-folder-name

# 克隆后进入目录
cd my-project
```

### 3.4 README：项目的门面

README.md 是访问者打开你仓库时看到的第一个文件，直接决定别人对这个项目的第一印象。一个好的 README 通常包含：

```markdown
# 项目名称

> 一句话描述项目是干什么的

## 功能特性

- 功能点 1
- 功能点 2

## 快速开始

```bash
git clone ...
cd project
npm install
npm start
```

## 技术栈

- 前端：React + TypeScript
- 后端：Node.js + Express

## 贡献指南

欢迎提交 Issue 和 PR，详见 CONTRIBUTING.md

## License

MIT
```

Markdown 支持标题、代码块、表格、图片、链接等丰富格式，花 10 分钟写好 README，能让你的项目对所有读者（包括未来的自己）都更友好。

### 3.5 .gitignore：不该提交的文件

`.gitignore` 告诉 Git 哪些文件不需要追踪。GitHub 在创建仓库时可以自动生成对应语言的模板，你也可以手动编辑：

```gitignore
# Node.js 项目常见忽略项
node_modules/
dist/
.env
.env.local
*.log

# Python 项目常见忽略项
__pycache__/
*.pyc
.venv/
*.egg-info/

# 编辑器文件
.DS_Store
.idea/
.vscode/
Thumbs.db
```

> **重要**：`.env` 文件通常包含 API 密钥、数据库密码等敏感信息，**绝对不能提交到 GitHub**，尤其是公开仓库。一旦上传到公开仓库，即使立刻删除，也可能已经被爬虫抓取。

### 3.6 License：开源许可证

如果你的项目是开源的，选择合适的 License 是必要的。没有 License 的开源代码默认不允许他人使用：

| License | 主要特点 | 适用场景 |
|---------|----------|----------|
| **MIT** | 最宽松，允许任意使用和修改，只需保留版权声明 | 大多数开源项目 |
| **Apache 2.0** | 类似 MIT，额外提供专利授权保护 | 企业级开源项目 |
| **GPL v3** | 使用此代码的项目必须也开源（传染性） | 希望保持开源传递性 |
| **CC0** | 放弃所有版权，完全公共领域 | 数据集、文档 |

---

## 4. 将本地项目推送到 GitHub

### 4.1 情况一：本地已有项目，推送到新建的空仓库

先在 GitHub 创建一个**空仓库**（不勾选 README），然后在本地执行：

```bash
# 进入本地项目目录
cd my-project

# 如果还没有初始化 Git，先初始化
git init

# 确保有至少一次提交（否则无法推送）
git add .
git commit -m "feat: initial commit"

# 绑定远程仓库地址（origin 是远程的别名，可以自定义但建议保持 origin）
git remote add origin git@github.com:username/my-project.git

# 将本地 master 分支重命名为 main（与 GitHub 默认分支统一）
git branch -M main

# 推送到远程，-u 建立跟踪关系（只需第一次执行）
git push -u origin main
```

执行成功后，刷新 GitHub 仓库页面，就能看到你的代码了。之后每次推送只需执行：

```bash
git push
```

### 4.2 情况二：克隆 GitHub 仓库到本地开始开发

如果仓库已经在 GitHub 上创建好（或者你要参与别人的项目），直接克隆：

```bash
git clone git@github.com:username/my-project.git
cd my-project

# 开始开发...
git add .
git commit -m "feat: add new feature"
git push
```

这是最常见的工作起点，克隆时 Git 会自动设置好远程追踪关系，无需手动 `git remote add`。

### 4.3 管理远程地址

```bash
# 查看当前仓库绑定的远程地址
git remote -v
# 输出示例：
# origin  git@github.com:username/my-project.git (fetch)
# origin  git@github.com:username/my-project.git (push)

# 修改远程地址（比如从 HTTPS 改为 SSH）
git remote set-url origin git@github.com:username/my-project.git

# 查看某个远程仓库的详细信息
git remote show origin
```

---

## 5. 分支与 Pull Request：协作的核心

### 5.1 为什么不直接推送到 main

新手最常见的操作是：改完代码，`git push origin main`，直接推到主分支。这在个人项目的早期阶段可以接受，但一旦涉及团队协作，或者项目需要稳定发布，直接推 main 会带来几个问题：

1. **没有代码审查**：没人能在合并前发现你的错误
2. **回滚困难**：多个功能混在一起，出问题后难以定位回滚点
3. **并行开发冲突**：多人同时推 main 极易产生冲突
4. **CI 无法拦截**：自动化测试来不及运行就已经合并了

**分支 + Pull Request** 是解决这些问题的标准方案。

### 5.2 GitHub Flow：标准工作流

GitHub Flow 是 GitHub 官方推荐的工作流，规则简洁：

1. `main` 分支永远保持可发布状态
2. 所有新工作（新功能、修 Bug）都在独立的功能分支上进行
3. 功能分支推送到远程后，发起 Pull Request
4. PR 经过代码审查、CI 通过后，合并到 `main`
5. 合并即可触发部署

```bash
# 第一步：从最新的 main 创建功能分支
git switch main
git pull origin main                         # 确保 main 是最新的
git switch -c feature/user-profile-settings  # 创建并切换到新分支

# 第二步：在功能分支上开发和提交
# ... 修改代码 ...
git add -p                                   # 交互式暂存，按逻辑拆分提交
git commit -m "feat(profile): add avatar upload support"
git commit -m "feat(profile): add bio field with char limit"

# 第三步：推送功能分支到 GitHub
git push -u origin feature/user-profile-settings
# 之后再次推送只需 git push

# 第四步：在 GitHub 上创建 Pull Request（见下节）

# 第五步：PR 合并后，清理本地分支
git switch main
git pull origin main
git branch -d feature/user-profile-settings
```

### 5.3 创建 Pull Request

推送功能分支后，GitHub 通常会在仓库页面顶部显示一个提示横幅："Compare & pull request"，点击即可快速创建 PR。你也可以进入 `Pull requests` 标签页，点击 `New pull request`。

**一个高质量的 PR 描述应该包含：**

```markdown
## 变更目的
简要说明这次 PR 解决了什么问题，或者添加了什么功能。

关联 Issue：closes #42

## 变更内容
- 新增头像上传接口（/api/user/avatar）
- 添加 Bio 字段，限制 200 字符
- 更新用户资料页面 UI

## 验证方式
1. 本地运行 `npm run test:auth`，全部通过
2. 手动测试：上传 JPG/PNG/WebP 格式图片均正常
3. 边界测试：超过 200 字符的 Bio 输入被截断提示

## 风险与影响
- 用户头像存储在 /uploads 目录，确保服务器有写权限
- 旧版本客户端不受影响（向后兼容）

## 回滚方案
如需回滚，执行 `git revert <merge-commit-sha>` 即可
```

写好 PR 描述，不仅是对审阅者的尊重，也是训练自己结构化思考的好方式。

### 5.4 代码审查（Code Review）

PR 创建后，需要等待审阅者（Reviewer）评审代码。审阅者可以：

- **逐行评论**：点击代码行左侧的 `+` 图标，针对具体代码给出反馈
- **建议修改**：使用 `Suggest changes` 功能，直接提交可接受的代码改动
- **整体评价**：选择 `Comment`（只评论）、`Approve`（批准）或 `Request changes`（要求修改）

**作为 PR 作者，收到 Review 意见时：**

```bash
# 根据评论修改代码
# ... 修改 ...

git add .
git commit -m "refactor: address review comments on avatar validation"
git push
# 推送后，PR 页面会自动更新，审阅者能看到新的提交
```

修改完成后，在评论里 `@` 审阅者，或者点击 `Re-request review`，通知对方再次查看。

### 5.5 发 PR 前的最佳实践：同步主干

如果功能分支开发时间较长，main 上可能已经有了其他同事合并的新提交。在发 PR 之前，先同步主干，可以把合并冲突在本地提前解决：

```bash
# 拉取最新的远程状态
git fetch origin

# 将功能分支的提交重放到最新 main 之上
git rebase origin/main

# 如果有冲突，解决后继续
git add <resolved-file>
git rebase --continue

# 推送更新后的分支（rebase 后需要强推）
git push --force-with-lease
```

> **为什么用 `--force-with-lease` 而不是 `--force`？**  
> `--force` 会直接覆盖远程分支，即使远程有你本地没有的新提交（可能覆盖他人工作）。`--force-with-lease` 在推送前会检查远程分支是否发生过变化，如果有，推送失败并给出提示，是更安全的选择。

### 5.6 合并 PR

PR 合并有三种方式，可以在 PR 页面的 `Merge pull request` 下拉菜单中选择：

| 合并方式 | 说明 | 适用场景 |
|----------|------|----------|
| **Create a merge commit** | 保留所有提交，生成一个 merge commit | 需要完整保留分支历史 |
| **Squash and merge** | 将所有提交压缩成一个，合并到 main | 功能分支提交较杂乱时 |
| **Rebase and merge** | 将提交线性重放到 main，无 merge commit | 追求线性干净历史 |

团队应统一选择一种合并策略，避免历史结构混乱。

---

## 6. Issue：需求与缺陷的管理

### 6.1 Issue 的用途

Issue 是 GitHub 上的"任务卡"，可以用来：

- 报告 Bug：附上复现步骤和环境信息
- 提交功能请求（Feature Request）
- 记录技术讨论和决策
- 拆解需求，作为开发任务单

良好的 Issue 管理是团队高效协作的基础，也是开源项目社区运营的核心工具。

### 6.2 创建高质量的 Issue

一个规范的 Bug Report Issue 应该包含：

```markdown
## Bug 描述
用户登录后，点击"修改头像"按钮，页面崩溃并显示 500 错误。

## 复现步骤
1. 使用账号 `test@example.com` 登录
2. 进入"个人设置" → "修改资料"
3. 点击头像区域的"上传图片"按钮
4. 查看页面报错

## 预期结果
弹出文件选择器，允许用户选择图片上传。

## 实际结果
页面显示 500 Internal Server Error，控制台报错：
```
TypeError: Cannot read property 'mimetype' of undefined
  at uploadAvatar (avatar.controller.js:34)
```

## 环境信息
- 操作系统：macOS 14.3
- 浏览器：Chrome 122
- 项目版本：v2.1.0

## 相关截图
[附图]
```

功能请求 Issue 应该包含：

```markdown
## 功能描述
希望支持用户导出个人数据为 CSV 格式。

## 使用场景
用户需要将自己的历史记录导入到其他工具进行分析，目前只能手动截图，非常不便。

## 可能的实现方案
在"个人设置"页面增加"导出数据"按钮，异步生成 CSV 并发送到邮箱。

## 优先级
中等，预计影响约 20% 的活跃用户。
```

### 6.3 Issue 的标签、里程碑与指派

**标签（Labels）**：GitHub 默认提供 `bug`、`enhancement`、`documentation` 等标签，你可以在 `Labels` 页自定义颜色和名称，用来快速分类筛选。

```
bug         - 功能异常
enhancement - 功能改进或新功能
docs        - 文档相关
help wanted - 欢迎社区贡献
good first issue - 适合新手入门的任务
wontfix     - 确认不修复
duplicate   - 已有相同 Issue
```

**里程碑（Milestones）**：把多个 Issue 组织到同一个版本目标下，可以直观看到版本完成进度（如"v2.2.0 还有 3 个 Issue 待关闭"）。

**指派（Assignees）**：把 Issue 分配给具体的负责人，明确责任归属。

### 6.4 通过 PR 自动关闭 Issue

在 PR 描述或提交消息中使用特定关键词，可以在 PR 合并时自动关闭关联的 Issue：

```markdown
closes #42
fixes #38
resolves #55
```

例如，PR 描述中写 `closes #42`，当这个 PR 被合并到 main 时，#42 号 Issue 会自动关闭并记录关联关系。这是 GitHub 里非常实用的功能，能保持 Issue 和 PR 的双向可追溯性。

### 6.5 Issue 模板

团队可以为仓库配置 Issue 模板，让提交者按统一格式填写。在仓库根目录创建：

```
.github/
  ISSUE_TEMPLATE/
    bug_report.md
    feature_request.md
```

`bug_report.md` 示例：
```markdown
---
name: Bug Report
about: 报告一个问题
labels: bug
---

## 问题描述

## 复现步骤

## 预期行为

## 实际行为

## 环境信息
- OS:
- Browser:
- Version:
```

配置后，用户点击"New Issue"时，会看到模板选择界面，引导他们填写完整信息。

---

## 7. Projects：任务看板与进度追踪

### 7.1 Projects 是什么

GitHub Projects 是内置的项目管理工具，可以把 Issue 和 PR 组织成**看板（Board）**、**表格（Table）**或**路线图（Roadmap）**，用于可视化追踪团队进度。

对于中小型团队，Projects 是一个足够好的轻量级替代品，不需要额外购买 Jira 或 Trello。

### 7.2 创建看板

在仓库页面点击 `Projects` → `New project`，选择模板：

- **Board**（看板）：最常用，横向泳道展示任务状态，适合追踪进行中的迭代
- **Table**（表格）：电子表格形式，适合管理大量 Issue 并自定义字段
- **Roadmap**（路线图）：时间轴形式，适合规划季度或版本计划

**最简单的起点——三列看板：**

```
Todo（待处理）  |  In Progress（进行中）  |  Done（已完成）
──────────────────────────────────────────────────────────
Issue #42       |  Issue #38              |  Issue #29
Issue #44       |  Issue #41              |  Issue #31
Issue #47       |                         |  Issue #35
```

### 7.3 自动化看板状态

GitHub Projects 支持自动化规则，比如：

- Issue 被关闭时，自动移到 `Done` 列
- PR 被合并时，关联的 Issue 自动移到 `Done` 列
- Issue 被指派给某人时，自动移到 `In Progress` 列

在 Project 的 `Settings → Workflows` 中配置，可以大幅减少手动拖拽的维护成本。

---

## 8. 权限管理与分支保护

### 8.1 仓库权限角色

GitHub 提供五种仓库权限角色（从高到低）：

| 角色 | 权限说明 |
|------|----------|
| **Admin** | 完全控制，含删除仓库、修改设置 |
| **Maintain** | 管理仓库（分支、标签、PR 合并），但不能修改敏感设置 |
| **Write** | 推送代码、创建分支、合并 PR |
| **Triage** | 管理 Issue 和 PR（打标签、关闭），但不能推送代码 |
| **Read** | 只读，可以克隆和查看，不能写入 |

**最小权限原则**：给每个人分配刚好满足其工作需要的权限，不要无脑给所有人 Write 权限。

### 8.2 邀请协作者

**个人仓库**：`Settings → Collaborators → Add people`，输入对方 GitHub 用户名并选择权限。

**组织仓库**：通过团队（Team）管理权限，将人加入团队，再给团队分配仓库权限，更易于批量管理。

### 8.3 分支保护规则（重点！）

分支保护是把"团队约定"变成"系统约束"的关键机制。在 `Settings → Branches → Add branch protection rule` 中配置。

**对 `main` 分支，强烈建议启用以下规则：**

```
✅ Require a pull request before merging
   # 禁止直接推送 main，所有改动必须通过 PR

   ✅ Require approvals: 1
   # PR 必须至少 1 人审批

   ✅ Dismiss stale pull request approvals when new commits are pushed
   # 新推送提交后，旧的 Approve 失效，需要重新审批

✅ Require status checks to pass before merging
   # CI 检查必须全部通过才能合并
   # 在 Status checks 里选择你的 Actions 工作流名称

✅ Require conversation resolution before merging
   # 所有评论都必须被标记为 Resolved 才能合并

✅ Restrict who can push to matching branches
   # 只有指定角色（如 Admin）才能绕过 PR 直接推送

✅ Require linear history（可选）
   # 强制使用 Squash 或 Rebase 合并，保持线性历史
```

**配置后的效果**：任何人（包括仓库 Owner）尝试直接 `git push origin main` 都会被拒绝，必须通过 PR 流程。这把质量门禁从"靠自觉"升级为"靠系统"。

### 8.4 CODEOWNERS 文件

`CODEOWNERS` 文件可以为特定目录或文件指定必须参与审查的责任人：

```
.github/           CODEOWNERS 文件位置
```

文件内容示例（`.github/CODEOWNERS`）：

```
# 默认所有文件需要 @alice 审批
*                   @alice

# 支付模块需要 @bob 审批
/src/payment/       @bob @carol

# 基础设施配置需要运维团队审批
/infra/             @ops-team

# 文档可以由任何人审批
/docs/              @alice @bob @carol
```

配置后，当 PR 改动涉及对应文件时，GitHub 会自动将 CODEOWNERS 中的人员添加为必须审批者。

---

## 9. GitHub Actions：自动化工作流

### 9.1 Actions 是什么

GitHub Actions 是 GitHub 内置的 CI/CD 自动化平台。你可以用 YAML 文件定义工作流，当特定事件发生时（如 push、PR、定时任务），自动在云端执行一系列操作：运行测试、构建代码、部署应用、发送通知等。

理解 Actions 的三个核心概念：

- **触发器（on）**：什么事件触发这个工作流？
- **运行环境（runs-on）**：在什么系统上执行？（如 `ubuntu-latest`、`macos-latest`、`windows-latest`）
- **步骤（steps）**：具体执行哪些操作？

工作流文件放在 `.github/workflows/` 目录下，扩展名为 `.yml`。

### 9.2 一个最小可用的工作流

```yaml
# .github/workflows/ci.yml

name: CI                          # 工作流名称（显示在 Actions 页面）

on:                               # 触发条件
  push:
    branches: [main]              # 推送到 main 时触发
  pull_request:                   # 任何 PR 创建或更新时触发

jobs:                             # 定义任务
  build-and-test:                 # 任务 ID（可自定义）
    runs-on: ubuntu-latest        # 运行在 Ubuntu 最新版

    steps:
      - name: 检出代码
        uses: actions/checkout@v4  # 官方 Action：将代码拉到运行环境

      - name: 安装 Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: 安装依赖
        run: npm ci                # npm ci 比 npm install 更快更稳定

      - name: 运行 Lint
        run: npm run lint

      - name: 运行测试
        run: npm test

      - name: 构建项目
        run: npm run build
```

### 9.3 常用触发条件

```yaml
on:
  # 推送到指定分支时触发
  push:
    branches: [main, develop]

  # 指定分支的 PR 事件触发
  pull_request:
    branches: [main]

  # 定时触发（Cron 语法）：每天 UTC 0:00
  schedule:
    - cron: '0 0 * * *'

  # 手动触发（在 Actions 页面点击按钮）
  workflow_dispatch:

  # 其他工作流完成后触发
  workflow_run:
    workflows: ['CI']
    types: [completed]
```

### 9.4 实用的 Actions 工作流示例

**示例一：Node.js 多版本矩阵测试**

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]    # 同时在三个 Node.js 版本上测试

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm ci
      - run: npm test
```

**示例二：PR 自动分配 Label**

```yaml
name: Auto Label PR

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  label:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/labeler@v4
        with:
          repo-token: ${{ secrets.GITHUB_TOKEN }}
```

**示例三：构建后自动发布到 GitHub Releases**

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'    # 推送 v1.0.0 这样的 tag 时触发

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci && npm run build

      - name: 创建 Release
        uses: softprops/action-gh-release@v1
        with:
          files: dist/**
          generate_release_notes: true
```

### 9.5 Secrets：安全存储敏感信息

工作流中可能需要访问 API 密钥、服务器密码等敏感信息，**绝对不能直接写在 YAML 文件里**。GitHub 提供了 Secrets 机制：

**添加 Secret**：`Settings → Secrets and variables → Actions → New repository secret`

输入名称（如 `DEPLOY_API_KEY`）和值，保存后值不可查看，只能覆盖或删除。

**在工作流中使用 Secret**：

```yaml
- name: 部署到服务器
  run: ./deploy.sh
  env:
    API_KEY: ${{ secrets.DEPLOY_API_KEY }}
    SERVER_HOST: ${{ secrets.SERVER_HOST }}
```

GitHub 会自动在日志中将 Secret 的值替换为 `***`，防止泄露。

### 9.6 查看工作流执行结果

进入仓库 `Actions` 标签页，可以看到所有工作流的执行历史。点击某次执行可以看到：

- 每个 Job 的执行状态（通过 / 失败 / 跳过）
- 每个 Step 的详细日志
- 执行耗时

**排查失败的原则**：

1. 找到第一条红色报错，而不是最后一条（第一条通常是根本原因）
2. 展开失败的 Step，查看完整的错误输出
3. 关注 `Error`、`FAILED`、`Exit code` 等关键词
4. 本地复现相同的命令，在本地先修好再推送

---

## 10. GitHub Pages：一键发布静态网站

### 10.1 Pages 能做什么

GitHub Pages 是 GitHub 提供的免费静态网站托管服务。你可以用它来：

- 发布项目文档（如你正在看的这个教程站）
- 搭建个人主页（`username.github.io`）
- 展示作品集、博客、技术笔记

Pages 只支持**静态内容**（HTML、CSS、JavaScript），不支持服务端代码（如 Node.js、Python 服务）。

### 10.2 手动发布：直接从分支部署

最简单的方式，适合纯 HTML 项目：

1. 把网站文件（`index.html` 等）推送到仓库
2. 进入 `Settings → Pages`
3. `Source` 选择 `Deploy from a branch`
4. 选择 `main` 分支，目录选 `/ (root)` 或 `/docs`
5. 点击保存，等待几分钟后访问 `https://username.github.io/repo-name/`

### 10.3 使用 GitHub Actions 自动构建部署

对于需要构建步骤的项目（如 MkDocs、Jekyll、Vue、React），推荐使用 Actions 自动化部署流程：

**第一步：配置 Pages 使用 Actions**

`Settings → Pages → Source` 选择 `GitHub Actions`

**第二步：编写部署工作流（以 MkDocs 为例）**

```yaml
# .github/workflows/deploy-docs.yml

name: Deploy Documentation

on:
  push:
    branches: [main]     # 推送到 main 时自动部署

permissions:
  contents: read
  pages: write           # 必须授予 Pages 写权限
  id-token: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: 安装 Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: 安装 MkDocs
        run: pip install mkdocs-material

      - name: 构建文档
        run: mkdocs build --strict

      - name: 上传构建产物
        uses: actions/upload-pages-artifact@v3
        with:
          path: site/              # MkDocs 默认输出目录

  deploy:
    needs: build                   # 依赖 build job 完成
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}

    steps:
      - name: 部署到 Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

**第三步：推送触发部署**

```bash
git add .
git commit -m "docs: update deployment workflow"
git push origin main
```

推送后，进入 `Actions` 页面可以看到工作流正在运行，完成后点击输出的 URL 即可访问网站。

### 10.4 自定义域名

如果你有自己的域名，可以配置到 GitHub Pages：

1. 在域名服务商处添加 CNAME 记录，指向 `username.github.io`
2. 在仓库 `Settings → Pages → Custom domain` 填写你的域名
3. 勾选 `Enforce HTTPS`

配置生效通常需要几分钟到 24 小时（DNS 传播时间）。

---

## 11. 参与开源：Fork 与贡献

### 11.1 Fork 是什么

Fork 是把别人的仓库完整复制一份到你自己的 GitHub 账号下。这样你就有了一个完整可写的副本，可以自由修改，而不影响原仓库。

**Fork 的典型使用场景**：

- 想给某个开源项目提交修复或改进
- 想基于某个项目做定制化二次开发
- 想学习某个项目的代码并做实验

### 11.2 贡献开源项目的完整流程

```bash
# 第一步：在 GitHub 页面点击 Fork，将仓库复制到自己名下

# 第二步：克隆 Fork 后的仓库
git clone git@github.com:your-username/open-source-project.git
cd open-source-project

# 第三步：添加原仓库为 upstream（上游），保持同步
git remote add upstream git@github.com:original-author/open-source-project.git
git remote -v
# 输出：
# origin    git@github.com:your-username/open-source-project.git
# upstream  git@github.com:original-author/open-source-project.git

# 第四步：从最新的上游主干创建功能分支
git fetch upstream
git switch -c fix/typo-in-readme upstream/main

# 第五步：修改代码、提交
# ... 修改 ...
git add .
git commit -m "docs: fix typo in README installation section"

# 第六步：推送到自己的 Fork
git push -u origin fix/typo-in-readme

# 第七步：在 GitHub 上创建 PR，目标是原仓库的 main 分支
# GitHub 会自动识别 Fork 关系，你会看到"Compare across forks"提示
```

### 11.3 保持 Fork 与上游同步

如果原仓库持续更新，你需要定期同步上游变更到自己的 Fork：

```bash
# 拉取上游最新变更
git fetch upstream

# 将 main 分支同步到最新上游状态
git switch main
git merge upstream/main

# 推送同步后的 main 到自己的 Fork
git push origin main
```

### 11.4 寻找适合贡献的项目

- 搜索 `good first issue` 标签：这些 Issue 被项目维护者标记为适合新手入门
- 在 GitHub Explore 页面发现感兴趣的项目
- 关注自己日常使用的工具或库，从修复文档的小错误开始
- 加入 Hacktoberfest 等开源活动（每年 10 月），有固定的贡献激励机制

---

## 12. 常用操作命令速查表

### 仓库连接与同步

| 命令 | 说明 |
|------|------|
| `git clone git@github.com:user/repo.git` | 通过 SSH 克隆仓库 |
| `git clone https://github.com/user/repo.git` | 通过 HTTPS 克隆仓库 |
| `git remote -v` | 查看远程仓库地址 |
| `git remote add origin <url>` | 绑定远程仓库 |
| `git remote set-url origin <new-url>` | 修改远程地址 |
| `git remote add upstream <url>` | 添加上游仓库（Fork 场景） |

### 分支操作

| 命令 | 说明 |
|------|------|
| `git switch -c feature/topic` | 创建并切换到新分支 |
| `git switch main` | 切换到 main 分支 |
| `git branch -vv` | 查看分支及远程跟踪关系 |
| `git push -u origin feature/topic` | 首次推送并建立追踪 |
| `git branch -d feature/topic` | 删除已合并的本地分支 |
| `git push origin --delete feature/topic` | 删除远程分支 |

### 同步与提交

| 命令 | 说明 |
|------|------|
| `git fetch origin --prune` | 拉取远程变更并清理失效引用 |
| `git pull --rebase origin main` | 拉取并变基到最新主干 |
| `git push` | 推送当前分支 |
| `git push --force-with-lease` | 安全强推（rebase 后使用） |

### 查看历史与差异

| 命令 | 说明 |
|------|------|
| `git log --oneline --graph --decorate -n 20` | 图形化提交历史 |
| `git log --oneline -- <file>` | 某文件的修改历史 |
| `git diff main feature/topic` | 两分支的差异 |
| `git diff --stat main feature/topic` | 只看改动了哪些文件 |

### 常用 GitHub 网页操作要点

| 操作 | 要点 |
|------|------|
| **New Issue** | 明确背景、复现步骤、预期结果、实际结果 |
| **New Pull Request** | 写清楚变更目的、验证方法、风险与回滚方案 |
| **Code Review** | 针对具体代码给出可执行建议，避免抽象评价 |
| **Merge PR** | CI 通过且所有评论 Resolved 后再合并 |
| **Draft PR** | 草稿 PR，适合先讨论方案再正式审查 |

### GitHub Actions 相关

| 操作 | 说明 |
|------|------|
| 查看工作流日志 | `Actions` → 点击具体执行记录 → 展开 Step |
| 手动触发工作流 | `Actions` → 选择工作流 → `Run workflow` |
| 添加 Secret | `Settings → Secrets and variables → Actions → New secret` |
| 调试失败 | 找第一条红色错误，而不是最后一条 |

---

## 13. 新手常见误区与改进路径

### 误区一：把 GitHub 当网盘用

**表现**：只会上传代码，不写 README，不用 Issue，PR 描述留空。结果是项目"能看不能用"，他人无法理解也无法参与。

**改进方法**：养成两个习惯——每次提交写清楚 commit message（用 Conventional Commits 规范），每次 PR 填写"目的 - 变更 - 验证 - 风险"四段式描述。

### 误区二：主分支直接开发

**表现**：所有改动直接 `git push origin main`，没有功能分支，没有 PR，没有代码审查。

**改进方法**：哪怕是个人项目，也养成从 `main` 拉分支、PR 合并的习惯。一旦出现需要回滚的情况，功能分支的独立历史会让你感谢当初的选择。

### 误区三：只看成功，不看失败日志

**表现**：CI 失败后反复推送提交"试运气"，不去认真看错误日志，不理解为什么失败。

**改进方法**：每次 CI 失败，都打开 Actions 日志，找到第一条错误信息，在本地重现并修复后再推送。这个习惯让你快速积累排错能力。

### 误区四：权限设置太松

**表现**：所有协作者都给 Admin 权限，main 分支没有保护，任何人可以直接推送。

**改进方法**：遵循最小权限原则，为 `main` 配置分支保护规则，要求 PR + CI 通过才能合并。这把团队协作质量从"靠自觉"升级到"靠系统"。

### 误区五：忽视安全设置

**表现**：没有开启 2FA，把 API 密钥直接写在代码里并推送到公开仓库，不检查 `.gitignore` 是否生效。

**改进方法**：立即开启 2FA；配置 `.gitignore` 屏蔽所有包含敏感信息的文件；使用 GitHub Secrets 存储工作流中需要的密钥。一旦密钥被推送到公开仓库，即使立刻删除，也应视为已泄露，立即旋转。

---

## 14. 延伸阅读

### 官方文档

- [**GitHub Docs**](https://docs.github.com/)：GitHub 所有功能的权威文档，可以搜索任何具体问题
- [**Managing Pull Requests**](https://docs.github.com/en/pull-requests)：PR 功能的完整指南
- [**About Issues**](https://docs.github.com/en/issues/tracking-your-work-with-issues/about-issues)：Issue 功能详细说明
- [**GitHub Actions 快速入门**](https://docs.github.com/en/actions/quickstart)：15 分钟上手第一个工作流
- [**GitHub Pages 文档**](https://docs.github.com/en/pages)：Pages 配置与使用完整指南

### 工作流与最佳实践

- [**GitHub Flow 官方指南**](https://docs.github.com/en/get-started/using-github/github-flow)：GitHub 推荐的协作工作流
- [**Conventional Commits**](https://www.conventionalcommits.org/zh-hans/)：提交消息规范，与自动化 CHANGELOG 工具配合使用
- [**Semantic Versioning**](https://semver.org/lang/zh-CN/)：版本号规范（`v1.2.3` 的命名约定）

### 工具与效率

- [**GitHub CLI（`gh`）**](https://cli.github.com/)：在终端中直接操作 GitHub，创建 PR、查看 Issue，无需打开浏览器
- [**GitHub Mobile**](https://github.com/mobile)：手机端 App，随时查看 PR 通知、参与 Review
- [**act**](https://github.com/nektos/act)：在本地运行 GitHub Actions 工作流，方便调试

### 开源参与

- [**First Contributions**](https://github.com/firstcontributions/first-contributions)：专为新手设计的开源贡献练习仓库，逐步引导完成第一次 PR
- [**Good First Issues**](https://goodfirstissues.com/)：聚合各大开源项目的新手友好 Issue

---

*本文档持续维护更新。如有错误或建议，欢迎提交 Issue 或 PR。*