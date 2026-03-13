# Git 完整指南

> **最后更新**：2026-03-13

---


## 1. Git 是什么，用来干什么

### 1.1 版本控制的本质需求

想象你正在写一篇毕业论文。你改了初稿、二稿、三稿，某一天突然发现三稿把一个重要的论证删掉了，而你已经找不到那段内容。于是你开始手动备份：`论文_v1.docx`、`论文_v2.docx`、`论文_终稿.docx`、`论文_终稿_最终版.docx`……

这种做法在个人项目中勉强可行，但放到团队软件开发中会立刻崩溃：

- 十个人同时改同一份代码，最后谁的版本算数？
- 某个功能上线出了 Bug，怎么快速回到三天前的状态？
- A 同学的新功能还没写完，B 同学的紧急修复怎么先发布？

**版本控制系统（VCS）** 就是为了解决这些问题而生的工具。Git 是目前世界上使用最广泛的分布式版本控制系统，由 Linux 内核作者 Linus Torvalds 于 2005 年开发，如今几乎已成为软件开发的行业标准。

### 1.2 Git 能做哪些事

| 场景 | Git 的解决方案 |
|------|----------------|
| 保存每次有意义的改动 | `commit` 生成不可篡改的历史快照 |
| 对比两个版本的差异 | `diff` 显示具体改动了哪些行 |
| 回退到某个历史状态 | `reset` / `revert` 撤销到指定版本 |
| 并行开发互不干扰 | `branch` 创建独立开发线 |
| 多人协作共享代码 | `push` / `pull` 同步远程仓库 |
| 追溯某行代码的来历 | `blame` 查看每一行的提交者与时间 |
| 快速发布和回滚 | `tag` 打版本标签，随时切回 |

### 1.3 分布式意味着什么

Git 是"分布式"的：每一个开发者的本地机器上都保存着**完整的仓库历史**，而不仅仅是当前文件。这意味着：

- 即使断网，你也可以完整地提交、查看历史、切换分支
- 没有"中央服务器宕机就全员停工"的单点风险
- GitHub / GitLab 只是托管远程副本的平台，不是 Git 本身

---

## 2. 核心概念：Git 的工作模型

学 Git 命令之前，先花五分钟理解它的工作模型。很多人踩坑，根源都是对"现在改动在哪里"不清楚。

### 2.1 三个区域

Git 把你的工作划分为三个区域：

```
┌─────────────────┐    git add     ┌─────────────────┐    git commit    ┌─────────────────┐
│                 │ ─────────────► │                 │ ───────────────► │                 │
│   工作区         │                │   暂存区         │                  │   提交历史       │
│  Working Dir    │                │   Staging Area  │                  │   Repository    │
│  (你正在编辑的) │ ◄───────────── │  (准备提交的)   │                  │  (已确认快照)   │
│                 │  git restore   │                 │                  │                 │
└─────────────────┘                └─────────────────┘                  └─────────────────┘
```

- **工作区（Working Directory）**：你在文件系统上直接看到和编辑的文件，尚未被 Git 记录
- **暂存区（Staging Area / Index）**：你通过 `git add` 明确告诉 Git "这部分内容要放入下一次提交"
- **提交历史（Repository）**：通过 `git commit` 永久写入的快照链，每个快照有唯一哈希值

这个三层模型解释了为什么修改文件之后 `git status` 会提示 "Changes not staged for commit"——你改的在工作区，还没有 `add` 到暂存区。

### 2.2 提交是"快照"而非"差异"

很多人以为 Git 每次提交只记录"改了什么"。实际上，Git 记录的是**整个项目在这一时刻的完整状态（快照）**，并通过内容哈希（SHA-1）来标识。

```
commit a3f9c1d (HEAD -> main)
│
commit 7b2e0aa
│
commit 1d4f823
│
(root commit)
```

每个提交节点包含：
- 该时刻所有文件的快照（通过 tree 对象存储）
- 指向父提交的指针
- 作者、时间、提交消息等元数据

`main`、`feature/x`、`v1.0.0` 这些名字，**本质上只是指向某个提交对象的可移动引用（指针）**。这解释了为什么"切换分支"瞬间完成——Git 只是移动了 HEAD 指针。

### 2.3 HEAD 是什么

`HEAD` 是一个特殊的引用，永远指向"你当前所在的位置"。通常 HEAD 指向某个分支，该分支再指向最新提交：

```
HEAD -> main -> commit_a3f9c1d
```

当你 `git switch feature/x` 时，HEAD 改为指向 `feature/x`。当你 `git commit` 时，`feature/x` 前进到新提交，HEAD 跟着走。

---

## 3. 安装与初始配置

### 3.1 安装 Git

**macOS**：
```bash
# 方式一：Xcode Command Line Tools（推荐，系统内置）
xcode-select --install

# 方式二：Homebrew
brew install git
```

**Windows**：
前往 [https://git-scm.com/download/win](https://git-scm.com/download/win) 下载安装包，安装时建议勾选"Git Bash"和"Use Git from the Windows Command Prompt"。

**Linux（Debian / Ubuntu）**：
```bash
sudo apt update && sudo apt install git
```

验证安装：
```bash
git --version
# 输出示例：git version 2.43.0
```

### 3.2 全局身份配置

每次 `git commit` 都会记录作者信息，配置一次即可全局生效：

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

> **为什么要配邮箱**：GitHub / GitLab 用邮箱匹配你的账号，从而在提交记录里显示头像和主页链接。请使用与平台账号一致的邮箱。

### 3.3 推荐的全局配置

```bash
# 默认分支名使用 main（与 GitHub 统一）
git config --global init.defaultBranch main

# 拉取时自动变基，减少多余 merge commit
git config --global pull.rebase true

# 配置默认编辑器（以 VS Code 为例）
git config --global core.editor "code --wait"

# 开启彩色输出，让终端更易读
git config --global color.ui auto

# 查看当前所有全局配置
git config --global --list
```

### 3.4 生成 SSH 密钥（推荐用于 GitHub）

使用 SSH 而非 HTTPS，可以避免每次推送都输入密码：

```bash
# 生成 Ed25519 密钥（比传统 RSA 更安全）
ssh-keygen -t ed25519 -C "you@example.com"
# 一路回车使用默认路径和无密码短语（适合个人机器）

# 查看公钥内容，复制到 GitHub → Settings → SSH Keys
cat ~/.ssh/id_ed25519.pub

# 测试连接
ssh -T git@github.com
# 成功输出：Hi username! You've successfully authenticated...
```

---

## 4. 基础操作：提交你的第一个快照

### 4.1 初始化仓库

**从零开始新项目**：
```bash
mkdir my-project && cd my-project
git init
# 输出：Initialized empty Git repository in .../my-project/.git/
```

**已有项目接入 Git**：
```bash
cd existing-project
git init
```

**从远程克隆已有仓库**：
```bash
git clone https://github.com/username/repo.git
# 或 SSH 方式
git clone git@github.com:username/repo.git

# 克隆到指定文件夹名
git clone git@github.com:username/repo.git my-folder
```

### 4.2 查看仓库状态

`git status` 是你最常用的命令，随时使用它来了解"现在仓库里发生了什么"：

```bash
git status

# 简洁模式（推荐日常使用）
git status -s -b
```

输出含义解读：
```
On branch main
Changes to be committed:       # 暂存区中，下次 commit 会包含
  modified:   src/auth.ts

Changes not staged for commit: # 工作区改动，还没 add
  modified:   README.md

Untracked files:               # 全新文件，Git 尚未追踪
  config.local.json
```

### 4.3 将文件加入暂存区

```bash
# 暂存单个文件
git add src/auth.ts

# 暂存目录下所有改动
git add src/

# 暂存所有改动（慎用，容易把测试文件、密钥等加进去）
git add .

# 交互式暂存（推荐！逐块选择要提交的内容）
git add -p
```

**`git add -p` 详解**：当你一次改动了多个功能，但想拆成多个逻辑独立的提交时，`-p` 会逐个代码块（hunk）询问你：

```
Stage this hunk [y,n,q,a,d,s,?]?
  y - stage this hunk
  n - do not stage this hunk
  s - split this hunk into smaller hunks
  q - quit; do not stage this hunk or any remaining
```

### 4.4 创建提交

```bash
git commit -m "feat(auth): add token refresh handler"
```

**好的提交信息格式**（推荐 Conventional Commits 规范）：

```
<类型>(<范围>): <简短描述>

[可选的详细说明]

[可选的 footer，例如关闭 Issue]
```

常用类型：
- `feat`：新功能
- `fix`：Bug 修复
- `docs`：文档变更
- `refactor`：重构（不影响功能）
- `test`：测试相关
- `chore`：构建配置、依赖更新等

示例：
```bash
git commit -m "fix(login): prevent duplicate form submission on slow networks"
git commit -m "docs: update API authentication section"
git commit -m "feat(cart): add promo code validation"
```

**为什么提交信息很重要**：六个月后你或同事翻历史时，`git log --oneline` 的可读性决定了定位 Bug 要花 30 秒还是 30 分钟。

### 4.5 配置 .gitignore

`.gitignore` 文件告诉 Git 哪些文件不需要追踪（不要提交到仓库）：

```bash
# 创建 .gitignore
touch .gitignore
```

常见内容示例：
```gitignore
# 依赖目录
node_modules/
vendor/

# 构建产物
dist/
build/
*.o
*.pyc

# 环境变量与密钥（绝对不要提交！）
.env
.env.local
*.pem
config/secrets.yml

# 编辑器和操作系统文件
.DS_Store
.idea/
.vscode/
Thumbs.db
```

> **注意**：已经被 Git 追踪的文件，加入 `.gitignore` 不会自动取消追踪。需要先执行 `git rm --cached <file>` 从追踪中移除，再提交。

### 4.6 完整的日常开发流程示例

```bash
# 1. 查看当前状态
git status -s -b

# 2. 确认改动内容
git diff

# 3. 有选择地暂存
git add -p

# 4. 再次确认暂存内容
git diff --staged

# 5. 提交
git commit -m "feat(user): add avatar upload endpoint"

# 6. 推送到远程
git push -u origin feature/user-avatar
```

---

## 5. 查看历史：读懂项目演进轨迹

### 5.1 查看提交日志

```bash
# 基础查看
git log

# 最常用的简洁图形化视图
git log --oneline --graph --decorate -n 20

# 搜索特定作者的提交
git log --author="Alice"

# 搜索提交信息中含某关键词的提交
git log --grep="fix"

# 查看某个文件的修改历史
git log --oneline -- src/auth/login.ts

# 查看某段日期范围内的提交
git log --since="2026-01-01" --until="2026-03-01" --oneline
```

`--graph` 效果示例：
```
* a3f9c1d (HEAD -> main, origin/main) feat: add payment module
* 7b2e0aa fix: resolve race condition in cache
| * d4c1234 (feature/search) feat: add full-text search
|/
* 1d4f823 refactor: extract auth middleware
```

### 5.2 查看具体改动

```bash
# 查看某次提交的详细内容
git show a3f9c1d

# 查看工作区与暂存区的差异
git diff

# 查看暂存区与最新提交的差异
git diff --staged

# 比较两个分支的差异
git diff main feature/search

# 只看改动了哪些文件（不看具体行）
git diff --stat main feature/search
```

### 5.3 追踪某一行代码的来源

```bash
# 查看 login.ts 每一行的最后修改者和提交
git blame src/auth/login.ts

# 只看第 50 到 80 行
git blame -L 50,80 src/auth/login.ts
```

输出示例：
```
7b2e0aa (Alice  2026-02-14 10:23:45 +0800 52)   if (!token) {
a3f9c1d (Bob    2026-03-01 09:11:02 +0800 53)     return res.status(401).json({ error: 'Unauthorized' });
```

---

## 6. 撤销与修复：出错了怎么办

这一节是 Git 学习中最容易混淆的部分。记住：**先确认"我要改的是哪一层"，再选命令**。

### 6.1 撤销工作区改动（未 add）

你修改了文件，但还没 `add`，想放弃这次修改，回到上一次提交的状态：

```bash
# 撤销单个文件的工作区改动
git restore src/auth.ts

# 撤销所有工作区改动（谨慎！不可恢复）
git restore .
```

> ⚠️ `git restore` 撤销的工作区改动**无法恢复**，执行前请确认。

### 6.2 从暂存区撤回（已 add，未 commit）

你已经 `git add` 了一个文件，但想把它从暂存区撤出（不影响工作区内容）：

```bash
# 把文件从暂存区撤回到工作区
git restore --staged src/auth.ts

# 撤回所有暂存文件
git restore --staged .
```

### 6.3 修改最近一次提交（未推送）

提交之后发现消息写错了，或者漏加了一个文件：

```bash
# 修改提交消息
git commit --amend -m "fix(auth): correct token validation logic"

# 追加文件到上一次提交（不改消息）
git add forgotten-file.ts
git commit --amend --no-edit
```

> ⚠️ `--amend` 会**重写**上一次提交（产生新的 SHA），因此只能用于**尚未推送**到远程的提交。已推送的提交不要 amend，否则会导致他人历史冲突。

### 6.4 回退提交：reset 三种模式

`git reset` 用于将 HEAD（及当前分支指针）回退到某个历史提交，有三种力度：

```bash
# --soft：只回退提交，改动保留在暂存区
# 场景：想重新组织这几次提交
git reset --soft HEAD~1

# --mixed（默认）：回退提交，暂存区清空，改动保留在工作区
# 场景：想重新选择提交内容
git reset HEAD~1
git reset --mixed HEAD~1

# --hard：完全回退，工作区和暂存区都恢复到目标提交状态
# 场景：彻底放弃这些改动
# ⚠️ 高风险：工作区改动会丢失！
git reset --hard HEAD~1
git reset --hard a3f9c1d
```

`HEAD~1` 表示"当前提交的上一个提交"，`HEAD~3` 表示回退三步。

### 6.5 安全撤销：revert（已推送到共享分支）

对于已经推送到 `main` 等共享分支的提交，**不要用 reset**，应该使用 `revert`——它会生成一个"反向提交"来抵消之前的改动，保留完整审计历史：

```bash
# 撤销指定提交（生成新的 revert 提交）
git revert a3f9c1d

# 撤销但不自动创建提交（可以修改后再 commit）
git revert --no-commit a3f9c1d

# 撤销后推送
git push origin main
```

**reset vs revert 对比**：

| | `reset` | `revert` |
|---|---|---|
| 历史改动 | 删除提交记录 | 新增反向提交，保留原记录 |
| 适用场景 | 本地未推送的提交 | 已推送的共享提交 |
| 团队影响 | 会导致他人历史冲突 | 对他人无影响 |
| 可审计性 | 低（历史被清除） | 高（全程可追溯） |

### 6.6 用 stash 临时保存现场

你正在开发功能，突然需要切换分支修一个紧急 Bug，但当前改动还不值得提交：

```bash
# 把当前工作区和暂存区的改动全部临时保存
git stash

# 保存时附加说明
git stash push -m "WIP: user profile form validation"

# 查看所有 stash
git stash list
# 输出示例：
# stash@{0}: On feature/profile: WIP: user profile form validation
# stash@{1}: WIP on main: hotfix before feature branch

# 切去修 Bug，修完后回来恢复现场
git switch feature/profile
git stash pop          # 恢复最新 stash 并删除记录
git stash apply        # 恢复最新 stash 但保留记录（可反复使用）

# 恢复指定 stash
git stash apply stash@{1}

# 删除某个 stash
git stash drop stash@{0}

# 清空所有 stash
git stash clear
```

---

## 7. 分支：并行开发的核心机制

### 7.1 分支的本质

分支是 Git 最强大的特性之一。它允许你在不影响主线代码的情况下，在独立的"副本"上开发新功能、修复 Bug，完成后再合并回主线。

Git 的分支切换**几乎瞬间完成**，因为"切换分支"只是移动 HEAD 指针，而不是复制文件系统。

### 7.2 分支的基本操作

```bash
# 查看所有本地分支（* 表示当前分支）
git branch

# 查看所有分支（包含远程），并显示跟踪关系
git branch -vv

# 查看包括远程在内的所有分支
git branch -a

# 创建分支（不切换）
git branch feature/payment

# 创建并切换到新分支（推荐方式）
git switch -c feature/payment

# 切换到已有分支
git switch main
git switch feature/payment

# 删除已合并的分支（安全删除）
git branch -d feature/payment

# 强制删除分支（未合并也删除，谨慎）
git branch -D feature/payment-abandoned
```

### 7.3 推荐的分支命名规范

| 前缀 | 用途 | 示例 |
|------|------|------|
| `feature/` | 新功能开发 | `feature/user-auth` |
| `fix/` | Bug 修复 | `fix/login-race-condition` |
| `hotfix/` | 线上紧急修复 | `hotfix/payment-overflow` |
| `refactor/` | 代码重构 | `refactor/auth-middleware` |
| `docs/` | 文档更新 | `docs/api-v2-readme` |
| `release/` | 版本发布准备 | `release/v2.1.0` |

### 7.4 GitHub Flow：推荐的团队工作流

**GitHub Flow** 是适合大多数团队的轻量级工作流：

1. `main` 分支永远保持可发布状态
2. 所有新工作从 `main` 创建功能分支
3. 功能分支通过 Pull Request 合并回 `main`
4. PR 合并即可发布

```bash
# 步骤一：确保从最新主干创建分支
git switch main
git pull origin main

# 步骤二：创建功能分支
git switch -c feature/profile-settings

# 步骤三：开发、提交
# ... 修改代码 ...
git add -p
git commit -m "feat(profile): add avatar upload"
git commit -m "feat(profile): add bio field with 200-char limit"

# 步骤四：推送到远程
git push -u origin feature/profile-settings
# 之后再次推送不需要 -u
git push

# 步骤五：在 GitHub 上创建 Pull Request，等待 Code Review

# 步骤六：PR 合并后，清理本地分支
git switch main
git pull origin main
git branch -d feature/profile-settings
```

---

## 8. 远程协作：与团队共享代码

### 8.1 远程仓库基础

```bash
# 查看当前配置的远程仓库
git remote -v
# 输出示例：
# origin  git@github.com:username/repo.git (fetch)
# origin  git@github.com:username/repo.git (push)

# 添加远程仓库（通常在 git init 后执行）
git remote add origin git@github.com:username/repo.git

# 修改远程仓库地址（比如从 HTTPS 改为 SSH）
git remote set-url origin git@github.com:username/repo.git

# 删除远程仓库配置
git remote remove origin
```

### 8.2 推送与拉取

```bash
# 首次推送并建立跟踪关系（-u 设置上游）
git push -u origin feature/payment

# 之后只需
git push

# 推送所有本地分支
git push --all origin

# 拉取远程变更（fetch + merge）
git pull

# 拉取并变基（推荐，配合 pull.rebase=true 使用）
git pull --rebase origin main
```

### 8.3 fetch vs pull

```bash
# fetch：只下载远程变更，不自动合并到当前分支
# 安全，不影响工作区，可先检查再决定如何整合
git fetch origin

# 查看 fetch 下来的变更
git log HEAD..origin/main --oneline

# 再决定如何整合
git merge origin/main  # 或
git rebase origin/main

# pull = fetch + merge（或 rebase，取决于配置）
git pull origin main
```

> **最佳实践**：在向主干同步之前，建议先 `git fetch`，检查远程有哪些变更，再决定整合方式。直接 `git pull` 简便但不够透明。

### 8.4 管理远程分支

```bash
# 查看所有远程分支
git branch -r

# 同步远程状态并删除本地已不存在的远程追踪引用
git fetch origin --prune

# 删除远程分支（有两种写法）
git push origin --delete feature/old-branch
git push origin :feature/old-branch

# 从远程分支创建本地追踪分支
git switch -c feature/remote-branch origin/feature/remote-branch
# 或简写（Git 会自动检测）
git switch feature/remote-branch
```

---

## 9. 合并与变基：整合代码的两种策略

### 9.1 merge：保留完整历史

`git merge` 将两个分支的历史合并，生成一个"合并提交（merge commit）"：

```bash
# 把 feature/payment 合并到当前分支（main）
git switch main
git merge feature/payment
```

合并后的历史：
```
*   e4f2a1b (HEAD -> main) Merge branch 'feature/payment'
|\
| * 9c3d0f2 feat(payment): add refund endpoint
| * 7a1b2c3 feat(payment): add checkout flow
|/
* 1d4f823 refactor: extract auth middleware
```

**优点**：完整保留了分支的并行开发历史，真实反映项目演进过程。  
**缺点**：历史图形复杂，产生额外 merge commit。

**Fast-forward merge**（无分叉时的特殊情况）：

```bash
# 如果 main 没有新提交，Git 会直接把指针前移（快进合并）
git merge feature/simple-fix

# 强制生成 merge commit（即使可以 fast-forward）
git merge --no-ff feature/simple-fix
```

### 9.2 rebase：整理线性历史

`git rebase` 将当前分支的提交"重放"到目标分支的顶端，结果是一条线性的提交历史：

```bash
# 在 feature/payment 分支上，把提交重放到 main 的最新位置
git switch feature/payment
git rebase main
```

变基前：
```
main:    A - B - C
                  \
feature:           D - E
```

变基后：
```
main:    A - B - C
                  \
feature:           D' - E'  （D、E 被重写，有了新的 SHA）
```

**优点**：历史线性清晰，`git log` 一目了然。  
**缺点**：会**重写提交哈希**，因此**绝对不要对已推送到共享分支的提交做 rebase**。

**发 PR 前同步主干（推荐流程）**：

```bash
git fetch origin
git rebase origin/main
# 如果有冲突，解决后：
git add <resolved-files>
git rebase --continue
# 如果想放弃 rebase：
git rebase --abort
```

### 9.3 交互式变基：整理提交历史

在合并 PR 之前，你可能想把混乱的提交整理一下：

```bash
# 整理最近 5 次提交
git rebase -i HEAD~5
```

会弹出编辑器，列出最近 5 次提交：
```
pick 7a1b2c3 feat(payment): add checkout flow
pick 9c3d0f2 feat(payment): add refund endpoint
pick a1b2c3d fix: typo in payment module
pick b2c3d4e WIP: payment tests
pick c3d4e5f feat(payment): add payment receipt
```

常用操作指令：
- `pick`：保留此提交
- `reword`（`r`）：保留提交，但修改提交消息
- `squash`（`s`）：合并到上一个提交，保留消息
- `fixup`（`f`）：合并到上一个提交，丢弃本提交消息
- `drop`（`d`）：删除此提交

整理后：
```
pick 7a1b2c3 feat(payment): add checkout flow
squash 9c3d0f2 feat(payment): add refund endpoint
fixup  a1b2c3d fix: typo in payment module
drop   b2c3d4e WIP: payment tests
pick   c3d4e5f feat(payment): add payment receipt
```

---

## 10. 冲突处理：遇到冲突不要慌

### 10.1 冲突是什么

当两个分支对**同一文件的同一区域**做了不同修改，Git 无法自动判断保留哪个，就会产生冲突。冲突不是 Bug，是 Git 在要求你做出判断。

### 10.2 冲突文件长什么样

```
<<<<<<< HEAD（当前分支的内容）
const timeout = 5000;
=======
const timeout = 3000;
>>>>>>> feature/faster-timeout（要合并的分支的内容）
```

三个区域的含义：
- `<<<<<<< HEAD` 到 `=======`：你当前分支的版本
- `=======` 到 `>>>>>>>`：要合并进来的分支的版本

### 10.3 正确的冲突处理流程

```bash
# 1. 查看哪些文件有冲突
git status
# 输出：both modified: src/config.ts

# 2. 查看该文件的修改历史，理解两侧的意图
git log --oneline -- src/config.ts

# 3. 打开文件，手动决定最终内容
# 可以选择保留一侧、保留另一侧、或者合并两侧
# 删除所有冲突标记（<<<、===、>>>）

# 4. 标记冲突已解决
git add src/config.ts

# 5. 继续 rebase 或 merge
git rebase --continue   # 如果是 rebase 过程中的冲突
git merge --continue    # 如果是 merge 过程中的冲突

# 如果想放弃整个合并/变基操作
git rebase --abort
git merge --abort
```

### 10.4 使用合并工具

```bash
# 调用配置的合并工具（如 VS Code、vimdiff 等）
git mergetool

# 配置 VS Code 为合并工具
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'
```

### 10.5 冲突处理的思维原则

1. **先理解，再动手**：不要盲目接受一侧，要读懂两侧改动分别解决了什么问题
2. **语义优先于语法**：删掉冲突标记只是开始，保证行为正确才是目标
3. **跑测试验证**：解决冲突后，至少运行一次关键测试，确认功能未被破坏
4. **复杂冲突找人讨论**：如果两个改动涉及同一业务逻辑且不可兼容，回到需求层面决定取舍

---

## 11. 标签与发布管理

### 11.1 标签的作用

标签（Tag）是指向某个提交的**不可移动的引用**，通常用于标记版本发布节点。与分支不同，标签一旦创建就不会随着新提交移动。

### 11.2 创建与查看标签

```bash
# 查看所有标签
git tag

# 查看匹配某模式的标签
git tag -l "v1.*"

# 创建轻量标签（只是提交的别名，无额外信息）
git tag v1.2.0

# 创建附注标签（推荐！包含作者、日期和说明）
git tag -a v1.2.0 -m "release: v1.2.0 - add payment module"

# 给历史某次提交打标签
git tag -a v1.1.0 7b2e0aa -m "release: v1.1.0"

# 查看标签详细信息
git show v1.2.0
```

### 11.3 推送与删除标签

```bash
# 推送单个标签到远程
git push origin v1.2.0

# 推送所有本地标签（慎用，避免推送不完整标签）
git push origin --tags

# 删除本地标签
git tag -d v1.2.0

# 删除远程标签
git push origin --delete v1.2.0
```

### 11.4 基于标签回滚

```bash
# 查看某个版本的代码（进入 detached HEAD 状态）
git checkout v1.1.0

# 从某个标签创建新分支（推荐，避免 detached HEAD）
git switch -c hotfix/v1.1.1 v1.1.0
```

---

## 12. 高级技巧：效率与历史治理

### 12.1 cherry-pick：精准拣选提交

当你只想把某个分支的某一次提交应用到当前分支，而不是整个合并：

```bash
# 拣选单个提交
git cherry-pick a3f9c1d

# 拣选但不自动提交（可先检查再提交）
git cherry-pick --no-commit a3f9c1d

# 拣选一段范围的提交（不含起点）
git cherry-pick 7b2e0aa..a3f9c1d
```

**常见场景**：在 `develop` 分支上有一个 Bug fix，你需要把这个 fix 也应用到 `release/v1.x` 维护分支，但不想把其他 `develop` 上的内容一并带入。

### 12.2 reflog：从"误操作"中找回数据

`reflog` 是 Git 的"黑匣子"，记录了 HEAD 和分支引用的每一次移动，即使提交被 `reset` 掉，也通常能在这里找到：

```bash
# 查看 HEAD 的移动历史
git reflog

# 查看某个分支的 reflog
git reflog show feature/payment

# 查看最近 20 条
git reflog -n 20
```

输出示例：
```
a3f9c1d (HEAD -> main) HEAD@{0}: commit: feat: add payment
7b2e0aa HEAD@{1}: reset: moving to HEAD~1
9c3d0f2 HEAD@{2}: commit: feat: add refund
...
```

**恢复被误删的提交**：

```bash
# 找到目标 SHA
git reflog -n 30

# 方式一：创建新分支指向该提交
git branch recover/lost-work 9c3d0f2

# 方式二：cherry-pick 到当前分支
git cherry-pick 9c3d0f2

# 方式三：直接 reset（如果是当前分支的丢失）
git reset --hard 9c3d0f2
```

> **关键原则**：误操作之后，**立即停下来，先跑 `reflog`**，不要继续执行更多命令，否则可能覆盖恢复证据。

### 12.3 处理大文件与历史清理

**不慎提交了密钥或大文件的处置顺序**：

1. **先旋转凭证**：假设密钥已泄露，立刻在对应平台（GitHub、AWS、Google Cloud 等）撤销并重新生成
2. **再清理历史**：使用 `git filter-repo`（推荐，比 `filter-branch` 更快更安全）

```bash
# 安装 git-filter-repo
pip install git-filter-repo

# 从所有历史中删除某个文件
git filter-repo --path secrets.yml --invert-paths

# 强制推送清理后的历史（所有协作者需要重新克隆）
git push --force --all
git push --force --tags
```

> ⚠️ **安全提示**：清理历史不等于凭证安全。GitHub、npm 等平台会缓存历史版本，曾经公开的密钥必须视为已泄露，务必旋转。

### 12.4 实用诊断命令组合

把以下命令组合做成别名（alias），用于快速诊断仓库状态：

```bash
# 添加到 ~/.gitconfig
[alias]
  s   = status -sb
  lg  = log --oneline --graph --decorate -n 20
  ld  = log --oneline --graph --decorate --all
  st  = stash list
  bv  = branch -vv
  rv  = remote -v
```

之后只需执行：
```bash
git s     # 快速看状态
git lg    # 图形化历史
git bv    # 分支跟踪关系
```

---

## 13. 命令速查总表

### 配置

| 命令 | 说明 |
|------|------|
| `git config --global user.name "Name"` | 设置全局用户名 |
| `git config --global user.email "x@x.com"` | 设置全局邮箱 |
| `git config --global init.defaultBranch main` | 设置默认分支名 |
| `git config --global pull.rebase true` | 拉取时自动变基 |
| `git config --global --list` | 查看所有全局配置 |

### 初始化与克隆

| 命令 | 说明 |
|------|------|
| `git init` | 初始化新仓库 |
| `git clone <url>` | 克隆远程仓库 |
| `git clone <url> <dir>` | 克隆到指定目录 |

### 查看状态与历史

| 命令 | 说明 |
|------|------|
| `git status` | 查看当前状态 |
| `git status -s -b` | 简洁状态，含分支信息 |
| `git log --oneline --graph --decorate -n 20` | 图形化历史 |
| `git log --author="Name"` | 按作者过滤 |
| `git log --grep="keyword"` | 按提交信息过滤 |
| `git log --oneline -- <file>` | 某文件的修改历史 |
| `git show <sha>` | 查看某次提交详情 |
| `git diff` | 工作区 vs 暂存区 |
| `git diff --staged` | 暂存区 vs 上次提交 |
| `git diff <branch1> <branch2>` | 两分支差异 |
| `git blame <file>` | 每行代码的修改者 |

### 暂存与提交

| 命令 | 说明 |
|------|------|
| `git add <file>` | 暂存指定文件 |
| `git add .` | 暂存所有改动 |
| `git add -p` | 交互式按块暂存 |
| `git commit -m "msg"` | 提交 |
| `git commit --amend` | 修改最近一次提交 |
| `git commit --amend --no-edit` | 修改提交内容不改消息 |

### 撤销与恢复

| 命令 | 说明 |
|------|------|
| `git restore <file>` | 撤销工作区改动 |
| `git restore --staged <file>` | 从暂存区撤回 |
| `git reset --soft HEAD~1` | 回退提交，保留暂存区 |
| `git reset --mixed HEAD~1` | 回退提交，清空暂存区 |
| `git reset --hard HEAD~1` | 完全回退（高风险） |
| `git revert <sha>` | 生成反向提交（安全） |
| `git stash` | 临时保存当前改动 |
| `git stash pop` | 恢复最新 stash |
| `git stash list` | 查看所有 stash |
| `git reflog` | 查看 HEAD 移动历史 |

### 分支

| 命令 | 说明 |
|------|------|
| `git branch` | 查看本地分支 |
| `git branch -vv` | 查看分支及跟踪关系 |
| `git branch -a` | 查看所有分支（含远程） |
| `git switch -c <branch>` | 创建并切换分支 |
| `git switch <branch>` | 切换分支 |
| `git branch -d <branch>` | 删除已合并分支 |
| `git branch -D <branch>` | 强制删除分支 |

### 合并与变基

| 命令 | 说明 |
|------|------|
| `git merge <branch>` | 合并分支 |
| `git merge --no-ff <branch>` | 强制生成 merge commit |
| `git merge --abort` | 取消合并 |
| `git rebase <branch>` | 变基到目标分支 |
| `git rebase -i HEAD~N` | 交互式整理最近 N 次提交 |
| `git rebase --continue` | 解决冲突后继续 |
| `git rebase --abort` | 取消变基 |
| `git cherry-pick <sha>` | 拣选指定提交 |

### 远程操作

| 命令 | 说明 |
|------|------|
| `git remote -v` | 查看远程仓库 |
| `git remote add origin <url>` | 添加远程仓库 |
| `git fetch origin` | 拉取远程变更（不合并） |
| `git fetch origin --prune` | 拉取并清理失效引用 |
| `git pull` | 拉取并合并（或变基） |
| `git pull --rebase origin main` | 拉取并变基到主干 |
| `git push -u origin <branch>` | 首次推送并设置上游 |
| `git push` | 推送当前分支 |
| `git push origin --delete <branch>` | 删除远程分支 |

### 标签

| 命令 | 说明 |
|------|------|
| `git tag` | 查看所有标签 |
| `git tag -a v1.0.0 -m "msg"` | 创建附注标签 |
| `git tag v1.0.0` | 创建轻量标签 |
| `git push origin v1.0.0` | 推送指定标签 |
| `git push origin --tags` | 推送所有标签 |
| `git tag -d v1.0.0` | 删除本地标签 |
| `git push origin --delete v1.0.0` | 删除远程标签 |

---

## 14. 延伸阅读

### 官方文档

- [**Pro Git（中文版）**](https://git-scm.com/book/zh/v2)：最权威的 Git 学习资料，免费开源，涵盖从基础到底层原理
- [**Git 官方文档**](https://git-scm.com/docs)：所有命令的完整参数说明，适合查阅

### 工作流与团队实践

- [**GitHub Flow**](https://docs.github.com/en/get-started/using-github/github-flow)：GitHub 官方推荐的轻量级工作流
- [**Atlassian Git Tutorials**](https://www.atlassian.com/git/tutorials)：图文并茂的教程系列，适合入门和进阶
- [**Conventional Commits**](https://www.conventionalcommits.org/zh-hans/)：提交消息规范，与 CHANGELOG 自动生成工具配合使用

### 工具与可视化

- [**Git Graph（VS Code 插件）**](https://marketplace.visualstudio.com/items?itemName=mhutchie.git-graph)：在 VS Code 中可视化查看分支历史
- [**Oh My Zsh git 插件**](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git)：为 Zsh 用户提供大量 Git 命令别名，大幅提升效率
- [**git-filter-repo**](https://github.com/newren/git-filter-repo)：清理 Git 历史的最佳工具（密钥泄露/大文件处理）

### 深入理解 Git 原理

- [**Git Internals（Pro Git 第 10 章）**](https://git-scm.com/book/zh/v2/Git-%E5%86%85%E9%83%A8%E5%8E%9F%E7%90%86-%E5%BA%95%E5%B1%82%E5%91%BD%E4%BB%A4%E4%B8%8E%E4%B8%8A%E5%B1%82%E5%91%BD%E4%BB%A4)：了解 blob、tree、commit 对象和 `.git` 目录结构
- [**Learn Git Branching（交互式练习）**](https://learngitbranching.js.org/?locale=zh_CN)：通过可视化动画学习分支和变基，强烈推荐新手

---

*本文档持续维护更新。如有错误或建议，欢迎提交 Issue 或 PR。*