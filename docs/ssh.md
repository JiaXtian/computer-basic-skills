# SSH 完整指南

> **适用人群**：计算机系新生、转行入门者、需要系统掌握 SSH 远程连接与安全通信的开发者  
> **前置要求**：掌握基础命令行操作，理解远程主机（服务器）的基本概念  
> **最后更新**：2026-03-13

---

## 目录

1. [SSH 是什么，用来干什么](#1-ssh-是什么用来干什么)
2. [SSH 的工作原理：连接背后发生了什么](#2-ssh-的工作原理连接背后发生了什么)
3. [安装与环境准备](#3-安装与环境准备)
4. [密钥对：SSH 认证的核心](#4-密钥对ssh-认证的核心)
5. [基础连接：第一次登录远程主机](#5-基础连接第一次登录远程主机)
6. [SSH Config：让复杂连接变简单](#6-ssh-config让复杂连接变简单)
7. [ssh-agent：免重复输入密码短语](#7-ssh-agent免重复输入密码短语)
8. [跳板机与多级跳转：ProxyJump](#8-跳板机与多级跳转proxyjump)
9. [端口转发：SSH 的隧道能力](#9-端口转发ssh-的隧道能力)
10. [SSH 与 Git：在 GitHub 等平台使用密钥](#10-ssh-与-git在-github-等平台使用密钥)
11. [多账号管理：同一台机器使用多套密钥](#11-多账号管理同一台机器使用多套密钥)
12. [服务端安全加固：sshd_config](#12-服务端安全加固sshd_config)
13. [排错与诊断：遇到问题怎么办](#13-排错与诊断遇到问题怎么办)
14. [命令速查总表](#14-命令速查总表)
15. [延伸阅读](#15-延伸阅读)

---

## 1. SSH 是什么，用来干什么

### 1.1 从一个真实场景出发

你租用了一台云服务器，想要登录上去配置环境、部署代码。服务器没有显示器、没有键盘，远在数据中心的机房里，你要怎么"操作"它？

最直观的想法是：通过网络把命令发过去，让服务器执行，再把结果传回来。但问题随之而来：网络是不可信的，你的命令和服务器的响应在传输过程中可能被人拦截、篡改。如果传输的是数据库密码或系统配置，那就危险了。

**SSH（Secure Shell）** 正是为了解决这个问题而生的协议。它的核心价值不是"远程登录"，而是"在不可信网络上建立可信、加密的通信通道"。SSH 会对传输的所有数据进行加密，同时通过密钥机制验证"服务器是你要连接的那台服务器"和"你是有权限登录的用户"，从根本上防止窃听和中间人攻击。

### 1.2 SSH 能做哪些事

很多人只把 SSH 当成"登录服务器的工具"，但它的能力远不止于此：

| 用途 | 说明 |
|------|------|
| **远程命令行登录** | 最基础用途，在本地终端操作远程服务器 |
| **文件传输** | `scp` 和 `sftp` 基于 SSH 协议安全传输文件 |
| **端口转发（隧道）** | 把远程端口映射到本地，或反向映射，用于访问内网服务 |
| **代码托管认证** | GitHub、GitLab 等平台用 SSH 密钥替代密码认证 |
| **跳板机访问** | 通过中间主机访问内网的高安全性环境 |
| **远程命令执行** | 不登录终端，直接执行单条命令并获取结果 |
| **Git 远程操作** | `git push`、`git pull` 底层通过 SSH 传输 |
| **加密代理** | 通过 SSH 动态转发建立 SOCKS5 代理 |

### 1.3 SSH 与 Telnet、FTP 的区别

在 SSH 出现之前，远程管理使用 Telnet，文件传输使用 FTP。这两个协议都以**明文**传输所有数据，包括用户名和密码。在今天看来，这是完全不可接受的安全风险。SSH 在 1995 年诞生，如今已彻底取代了这些明文协议，成为远程管理的行业标准。

---

## 2. SSH 的工作原理：连接背后发生了什么

理解原理不是为了考试，而是为了让你遇到问题时能快速定位是哪个环节出了错。

### 2.1 连接建立的三个阶段

当你执行 `ssh user@host` 时，背后发生了三件事：

**第一阶段：建立加密通道（服务器身份验证）**

客户端连接服务器后，服务器会发送自己的**主机公钥（Host Key）**。客户端检查本地 `~/.ssh/known_hosts` 文件：

- 如果该服务器的公钥指纹已存在且匹配：信任该服务器，继续连接
- 如果是第一次连接（指纹不存在）：提示用户确认，是否信任该指纹
- 如果已有记录但指纹不匹配：**警告！可能存在中间人攻击，拒绝连接**

这一步解决的是"我连接的是正确的服务器吗？"的问题。

**第二阶段：协商加密算法**

双方协商使用哪种加密算法（如 AES-256、ChaCha20 等）进行后续通信，确保即使数据包被拦截，也无法被破解。

**第三阶段：用户身份认证**

加密通道建立后，服务器要验证"你是有权限登录的用户吗？"主要有两种方式：

- **密码认证**：发送密码（通过加密通道传输），服务器比对。不推荐，容易被暴力破解
- **公钥认证（推荐）**：服务器用存储的公钥加密一段随机数据，发给客户端；客户端用私钥解密并返回结果，服务器验证结果正确则认证通过

### 2.2 三个关键文件

```
客户端（你的电脑）                    服务器
─────────────────                    ──────────────────────
~/.ssh/id_ed25519     （私钥）        ~/.ssh/authorized_keys  （存放你的公钥）
~/.ssh/id_ed25519.pub （公钥）        /etc/ssh/ssh_host_*     （服务器主机密钥）
~/.ssh/known_hosts    （信任的服务器指纹）
```

- **私钥**：只存在你本地，永远不要传给任何人或任何服务器
- **公钥**：可以公开，放在服务器的 `authorized_keys` 文件里
- **known_hosts**：记录你已信任的服务器指纹，防止中间人伪装

---

## 3. 安装与环境准备

### 3.1 检查 SSH 是否已安装

现代操作系统通常已预装 SSH 客户端：

```bash
# 检查 SSH 客户端版本
ssh -V
# 输出示例：OpenSSH_9.6p1, LibreSSL 3.3.6
```

**macOS**：系统自带 OpenSSH，无需额外安装。

**Linux（Debian/Ubuntu）**：

```bash
# 检查是否已安装
which ssh

# 安装 SSH 客户端（通常已预装）
sudo apt update && sudo apt install openssh-client

# 如果你需要把这台机器作为 SSH 服务器（允许别人连进来）
sudo apt install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

**Windows**：

Windows 10 1809 及以上版本已内置 OpenSSH 客户端。在"设置 → 应用 → 可选功能"中搜索"OpenSSH 客户端"安装，或者使用 PowerShell：

```powershell
# 在 PowerShell 中安装 OpenSSH 客户端
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
```

也可以安装 [Git for Windows](https://git-scm.com/download/win)，它会附带完整的 OpenSSH 工具集和 Git Bash 终端环境，是 Windows 开发者最实用的选择。

### 3.2 确认 SSH 服务端状态（Linux 服务器）

如果你管理一台 Linux 服务器，需要确认 SSH 服务（sshd）正在运行：

```bash
# 查看 sshd 服务状态
sudo systemctl status ssh        # Ubuntu/Debian
sudo systemctl status sshd       # CentOS/RHEL

# 启动 SSH 服务
sudo systemctl start sshd

# 设置开机自启
sudo systemctl enable sshd

# 查看 SSH 服务监听的端口（默认 22）
sudo ss -tlnp | grep sshd
# 输出示例：LISTEN  0  128  0.0.0.0:22  ...
```

---

## 4. 密钥对：SSH 认证的核心

### 4.1 为什么要用密钥而不是密码

密码认证有两个根本缺陷：第一，密码可以被暴力猜测，只要攻击者有足够时间；第二，密码需要人工记忆，复杂密码难记，简单密码不安全。

公钥认证从根本上解决了这两个问题：

- 私钥是数学上近乎不可伪造的（Ed25519 密钥破解在现实中不可行）
- 认证过程中，私钥本身不传输到网络上，只传输用私钥签名的验证信息
- 一旦配置好，登录体验比输密码更流畅

### 4.2 生成密钥对

```bash
# 推荐方式：生成 Ed25519 密钥
ssh-keygen -t ed25519 -C "you@example.com"
```

参数说明：
- `-t ed25519`：指定密钥类型为 Ed25519（推荐，安全性高、密钥短、速度快）
- `-C "you@example.com"`：为密钥添加注释，方便在 `authorized_keys` 中识别来源

执行后会有交互提示：

```
Generating public/private ed25519 key pair.
Enter file in which to save the key (~/.ssh/id_ed25519):   ← 直接回车使用默认路径
Enter passphrase (empty for no passphrase):                ← 建议设置密码短语
Enter same passphrase again:
```

**关于密码短语（Passphrase）**：

密码短语是对私钥文件本身的加密保护。即使有人盗取了你的私钥文件，没有密码短语也无法使用它。这是纵深防御的体现：

- 设置密码短语：更安全，配合 `ssh-agent` 可以只需输入一次
- 不设置密码短语：方便，适合自动化脚本场景（但私钥文件若泄露则无保护）

**生成不同用途的密钥**（推荐）：

```bash
# 工作用途的密钥
ssh-keygen -t ed25519 -C "work@company.com" -f ~/.ssh/id_ed25519_work

# 个人 GitHub 用途
ssh-keygen -t ed25519 -C "personal@gmail.com" -f ~/.ssh/id_ed25519_personal

# 生产服务器专用
ssh-keygen -t ed25519 -C "prod-server-2026" -f ~/.ssh/id_ed25519_prod
```

为不同用途分离密钥的好处是：一套密钥泄露，不影响其他场景；轮换密钥时只需替换对应的那一套。

### 4.3 密钥文件权限

这是 SSH 最容易被新手忽略的问题。OpenSSH 对密钥文件的权限有严格要求，权限过宽会直接导致认证失败，并报错 `WARNING: UNPROTECTED PRIVATE KEY FILE!`

```bash
# 设置正确权限
chmod 700 ~/.ssh                   # SSH 目录：仅所有者可读写执行
chmod 600 ~/.ssh/id_ed25519        # 私钥：仅所有者可读写
chmod 600 ~/.ssh/id_ed25519_work
chmod 644 ~/.ssh/id_ed25519.pub    # 公钥：可以让他人读取
chmod 600 ~/.ssh/authorized_keys   # 服务器端认证文件
chmod 600 ~/.ssh/known_hosts
chmod 600 ~/.ssh/config

# 一次性修复 .ssh 目录下所有私钥的权限
chmod 600 ~/.ssh/id_*
```

> **记忆技巧**：私钥永远是 `600`（只有我能读），目录是 `700`（只有我能进），公钥可以 `644`（别人能读）。

### 4.4 将公钥复制到服务器

配置密钥认证时，需要把公钥内容追加到服务器的 `~/.ssh/authorized_keys` 文件：

**方式一：使用 `ssh-copy-id`（推荐，最简单）**

```bash
# 将默认公钥复制到服务器
ssh-copy-id user@server.example.com

# 指定公钥文件
ssh-copy-id -i ~/.ssh/id_ed25519_work.pub user@server.example.com

# 指定非标准端口
ssh-copy-id -i ~/.ssh/id_ed25519_work.pub -p 2222 user@server.example.com
```

执行时会要求输入服务器密码（这是最后一次需要用密码登录），之后就可以用密钥免密登录了。

**方式二：手动复制（无 `ssh-copy-id` 时）**

```bash
# 查看并复制公钥内容
cat ~/.ssh/id_ed25519.pub

# 登录服务器，手动追加
ssh user@server.example.com
mkdir -p ~/.ssh
echo "粘贴公钥内容" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

**方式三：通过管道一行命令完成**

```bash
cat ~/.ssh/id_ed25519.pub | ssh user@server.example.com "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
```

---

## 5. 基础连接：第一次登录远程主机

### 5.1 最基础的连接命令

```bash
# 基本格式：ssh 用户名@主机地址
ssh ubuntu@203.0.113.10

# 指定端口（默认 22，如果服务器修改了端口则需要指定）
ssh -p 2222 ubuntu@203.0.113.10

# 指定私钥文件（当你有多个密钥时）
ssh -i ~/.ssh/id_ed25519_work ubuntu@203.0.113.10

# 组合使用
ssh -p 2222 -i ~/.ssh/id_ed25519_work ubuntu@203.0.113.10
```

### 5.2 第一次连接时的主机指纹确认

第一次连接新服务器时，会看到类似如下提示：

```
The authenticity of host '203.0.113.10 (203.0.113.10)' can't be established.
ED25519 key fingerprint is SHA256:abc123xyz...
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

这是 SSH 在问你：你确认要信任这台服务器吗？如果你能通过其他安全渠道（如云服务商控制台）核实该指纹，输入 `yes` 确认。之后该服务器的指纹会被记录在 `~/.ssh/known_hosts`，后续连接不再询问。

> **不要无脑输入 yes**：如果你在不确定的情况下直接接受了伪造的服务器指纹，后续所有通信对攻击者都是透明的。在正规公司的服务器管理流程中，指纹应该通过安全渠道提前验证。

### 5.3 执行远程命令（不进入交互终端）

```bash
# 在远程主机执行单条命令，获取结果后自动断开
ssh user@host "ls -la /var/log"
ssh user@host "df -h"
ssh user@host "sudo systemctl status nginx"

# 执行多条命令
ssh user@host "cd /var/www && git pull && sudo systemctl reload nginx"

# 把本地脚本传到远程执行（不用先上传文件）
ssh user@host 'bash -s' < deploy.sh
```

### 5.4 文件传输：scp 与 sftp

**scp（安全复制）**：

```bash
# 上传本地文件到服务器
scp localfile.txt user@host:/remote/path/

# 下载服务器文件到本地
scp user@host:/remote/path/file.txt ./

# 上传整个目录（-r 递归）
scp -r ./dist/ user@host:/var/www/html/

# 指定端口
scp -P 2222 localfile.txt user@host:/remote/path/
```

**sftp（交互式文件传输）**：

```bash
# 进入交互式 sftp 会话
sftp user@host

# 常用 sftp 命令
sftp> ls              # 查看远程目录
sftp> lls             # 查看本地目录
sftp> cd /remote/dir  # 切换远程目录
sftp> lcd /local/dir  # 切换本地目录
sftp> get file.txt    # 下载文件
sftp> put file.txt    # 上传文件
sftp> mget *.log      # 批量下载
sftp> exit            # 退出
```

---

## 6. SSH Config：让复杂连接变简单

### 6.1 为什么需要 SSH Config

当你管理多台服务器时，每次输入完整的 `ssh -p 2222 -i ~/.ssh/id_ed25519_work ubuntu@203.0.113.10` 不仅繁琐，还容易出错。`~/.ssh/config` 文件允许你把这些参数配置成有意义的别名，把复杂命令简化成 `ssh prod-api` 这样清晰的入口。

### 6.2 Config 文件基础语法

```bash
# 创建或编辑配置文件
mkdir -p ~/.ssh
touch ~/.ssh/config
chmod 600 ~/.ssh/config
```

基础配置结构：

```text
Host <别名>
    HostName <真实IP或域名>
    User <用户名>
    Port <端口号>
    IdentityFile <私钥路径>
    IdentitiesOnly <yes/no>
```

每个 `Host` 块定义一个主机配置，`Host` 后面是你起的别名（可以是任意字符串）。

### 6.3 实用配置示例

**单台服务器配置**：

```text
Host prod-web
    HostName 203.0.113.10
    User ubuntu
    Port 22
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
    ServerAliveInterval 30
    ServerAliveCountMax 3
```

配置后，连接只需：

```bash
ssh prod-web
scp file.txt prod-web:/tmp/
sftp prod-web
```

**配置一组服务器（通配符）**：

```text
# 所有 *.corp 主机共用这套配置
Host *.corp
    User ops
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
    ServerAliveInterval 30
    ServerAliveCountMax 2
    ForwardAgent no

# 具体服务器只需写差异化部分
Host prod-web.corp
    HostName 10.20.1.15
    ProxyJump bastion.corp

Host prod-db.corp
    HostName 10.20.1.20
    ProxyJump bastion.corp
```

**完整的多环境配置示例**：

```text
# ─── 跳板机 ───────────────────────────────────
Host bastion
    HostName bastion.example.com
    User ops
    Port 22
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

# ─── 生产环境（通过跳板机访问）────────────────
Host prod-api
    HostName 10.0.1.10
    User ubuntu
    ProxyJump bastion
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

Host prod-db
    HostName 10.0.1.20
    User dbadmin
    ProxyJump bastion
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

# ─── 开发测试服务器 ───────────────────────────
Host dev
    HostName dev.example.com
    User developer
    Port 2222
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes

# ─── 全局默认设置（对所有主机生效）──────────
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    AddKeysToAgent yes
    IdentitiesOnly yes
```

### 6.4 重要参数详解

| 参数 | 说明 | 推荐值 |
|------|------|--------|
| `HostName` | 真实的 IP 或域名 | — |
| `User` | 登录用户名 | — |
| `Port` | SSH 端口 | 默认 22 |
| `IdentityFile` | 指定私钥路径 | `~/.ssh/id_ed25519` |
| `IdentitiesOnly yes` | 只使用指定的密钥，不尝试其他 | **强烈推荐** |
| `ServerAliveInterval 30` | 每 30 秒发一次保活包，防止连接因空闲被断开 | `30`~`60` |
| `ServerAliveCountMax 3` | 保活包发送失败 3 次后断开 | `2`~`5` |
| `ForwardAgent no` | 禁止 agent 转发（除非明确需要） | `no` |
| `AddKeysToAgent yes` | 首次使用密钥时自动加入 agent | `yes` |
| `ProxyJump` | 跳板机地址 | — |
| `StrictHostKeyChecking` | 主机指纹验证策略 | 保持默认（`ask`）|

### 6.5 调试配置：查看最终生效参数

```bash
# 打印指定别名最终生效的所有配置参数（非常有用！）
ssh -G prod-api

# 输出示例：
# hostname 10.0.1.10
# user ubuntu
# port 22
# identityfile ~/.ssh/id_ed25519_work
# identitiesonly yes
# proxyjump bastion
# ...
```

`ssh -G` 会合并所有匹配的 `Host` 块（包括通配符规则），展示最终的完整配置，是排查"为什么密钥没有生效"问题的首选工具。

---

## 7. ssh-agent：免重复输入密码短语

### 7.1 问题与解决思路

如果你给私钥设置了密码短语（Passphrase），每次使用密钥都需要输入，这在频繁连接的场景下很繁琐。`ssh-agent` 是一个运行在内存中的守护进程，它把解锁状态的私钥缓存起来，在当前会话内不需要重复输入密码短语。

### 7.2 启动与使用 ssh-agent

```bash
# 启动 ssh-agent（在当前 Shell 会话中）
eval "$(ssh-agent -s)"
# 输出示例：Agent pid 12345

# 将私钥添加到 agent（此时需要输入一次密码短语）
ssh-add ~/.ssh/id_ed25519
ssh-add ~/.ssh/id_ed25519_work

# 查看已加载的密钥列表
ssh-add -l
# 输出示例：
# 256 SHA256:abc123... you@example.com (ED25519)
# 256 SHA256:xyz789... work@company.com (ED25519)

# 从 agent 中移除某个密钥
ssh-add -d ~/.ssh/id_ed25519_work

# 移除所有已加载的密钥
ssh-add -D
```

### 7.3 macOS 的持久化配置

在 macOS 上，可以让 agent 在系统启动时自动运行，并把密钥存入系统钥匙串，实现真正的"一劳永逸"：

在 `~/.ssh/config` 中加入：

```text
Host *
    AddKeysToAgent yes
    UseKeychain yes          # 仅 macOS 有效
    IdentityFile ~/.ssh/id_ed25519
```

这样第一次使用密钥时，系统会弹出对话框要求输入密码短语，之后存入钥匙串，重启也不需要重新输入。

### 7.4 Linux 的持久化方案

在 Linux 上，可以将 agent 启动命令加入 `~/.bashrc` 或 `~/.zshrc`：

```bash
# 加入 ~/.bashrc 或 ~/.zshrc
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi
```

或者使用 `systemd` 用户服务管理 agent（更规范的方式，适合长期运行的桌面 Linux）。

---

## 8. 跳板机与多级跳转：ProxyJump

### 8.1 为什么需要跳板机

在生产环境中，核心服务器（数据库、应用服务器）通常不对公网开放 SSH 端口，只允许从特定的"跳板机"（也叫堡垒机、Bastion Host）进行访问。这种架构的安全价值在于：

- 只需要保护一台跳板机的安全，而不是所有服务器
- 所有访问记录集中在跳板机上，便于审计
- 内网服务器完全不暴露于公网，攻击面极大减小

### 8.2 ProxyJump：最简洁的跳转方式

老式的跳板机方式是先手动 SSH 到跳板机，再从跳板机 SSH 到目标主机，两次登录很繁琐。`ProxyJump` 让这个过程完全自动化：

**命令行方式**：

```bash
# -J 参数：通过 bastion.example.com 跳转到 10.0.1.20
ssh -J ops@bastion.example.com ubuntu@10.0.1.20

# 多级跳转（通过多台跳板机）
ssh -J user@jump1.example.com,user@jump2.example.com ubuntu@target.example.com
```

**Config 文件方式（推荐）**：

```text
Host bastion
    HostName bastion.example.com
    User ops
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

Host prod-api
    HostName 10.0.1.10
    User ubuntu
    ProxyJump bastion
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

Host prod-db
    HostName 10.0.1.20
    User dbadmin
    ProxyJump bastion
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
```

配置后，执行 `ssh prod-db`，SSH 会自动先连接 `bastion`，再从 bastion 跳转到 `prod-db`，整个过程对你透明。`scp`、`sftp` 等工具同样遵守 Config 配置，可以直接 `scp file.txt prod-db:/tmp/`，无需手动管理跳转。

### 8.3 Agent 转发：在跳板机上使用本地密钥

在跳板机跳转到内网主机时，你可能需要用本地的私钥进行第二次认证（而不是把私钥复制到跳板机上）。这时可以使用 **Agent 转发（ForwardAgent）**：

```text
Host bastion
    HostName bastion.example.com
    User ops
    IdentityFile ~/.ssh/id_ed25519_work
    ForwardAgent yes     # 允许在 bastion 上使用本地 agent 的密钥
```

> **安全提示**：`ForwardAgent yes` 存在安全风险——如果跳板机被攻破，攻击者可以利用转发的 agent 代表你访问其他主机。`ProxyJump` 是更安全的替代方案，它在本地直接建立到目标主机的隧道，不需要 agent 转发。优先使用 `ProxyJump`。

---

## 9. 端口转发：SSH 的隧道能力

### 9.1 什么是端口转发

端口转发（Port Forwarding）是 SSH 最被低估的功能之一。它本质上是通过已建立的 SSH 加密连接，在本地和远程之间建立一条"隧道"，让不加密的 TCP 流量借道 SSH 传输。

这在以下场景中极为实用：
- 在本地调试远程数据库，而不需要把数据库端口暴露到公网
- 访问只能从内网进入的 Web 界面（如监控面板、管理后台）
- 临时让远程服务器访问你本地正在运行的服务

### 9.2 本地端口转发（-L）

**场景**：远程数据库（PostgreSQL，端口 5432）只允许本机访问，你想在本地的数据库客户端连接它。

```bash
# 语法：ssh -L [本地地址:]本地端口:目标主机:目标端口 跳转主机
ssh -L 5433:127.0.0.1:5432 ubuntu@db-server.example.com

# 之后在本地就可以连接数据库（访问本地的 5433，数据被转发到远程的 5432）
psql -h 127.0.0.1 -p 5433 -U postgres mydatabase
```

```bash
# 后台运行（-N 不执行远程命令，-f 后台运行）
ssh -N -f -L 5433:127.0.0.1:5432 ubuntu@db-server.example.com

# 访问远程内网中的另一台服务器（通过 jump-server 访问内网的 internal-server）
ssh -L 8080:internal-server.local:80 ubuntu@jump-server.example.com
# 之后访问 http://127.0.0.1:8080 即可访问内网的 Web 服务
```

**理解本地转发的方向**：
```
你的电脑:5433  ──SSH隧道──►  db-server  ──本机访问──►  db-server:5432
```

### 9.3 远程端口转发（-R）

**场景**：你本地运行了一个 Web 服务（端口 3000），想让远程服务器（或互联网）能临时访问它（比如演示给客户看）。

```bash
# 语法：ssh -R [远程地址:]远程端口:本地主机:本地端口 远程服务器
ssh -R 8080:localhost:3000 ubuntu@public-server.example.com

# 之后访问 http://public-server.example.com:8080 就能访问你本地的 3000 端口
```

```
互联网用户  ──►  public-server:8080  ──SSH隧道──►  你的电脑:3000
```

> 注意：远程服务器的 `sshd_config` 需要开启 `GatewayPorts yes` 才能让外部网络访问转发端口，否则只有服务器本机能访问。

### 9.4 动态端口转发（-D，SOCKS5 代理）

**场景**：通过 SSH 建立一个 SOCKS5 代理，让浏览器的流量通过远程服务器转发，访问受地域限制的资源或内网服务。

```bash
# 在本地 1080 端口建立 SOCKS5 代理
ssh -D 1080 -N -f ubuntu@proxy-server.example.com

# 之后配置浏览器或系统代理：
# 代理类型：SOCKS5
# 地址：127.0.0.1
# 端口：1080
```

### 9.5 结合 Config 文件使用转发

可以把常用的端口转发写入 SSH Config：

```text
Host db-tunnel
    HostName db-server.example.com
    User ubuntu
    IdentityFile ~/.ssh/id_ed25519_work
    LocalForward 5433 127.0.0.1:5432
    LocalForward 6380 127.0.0.1:6379     # 同时转发 Redis
    ExitOnForwardFailure yes
    ServerAliveInterval 30
```

执行 `ssh -N db-tunnel` 即可同时建立数据库和 Redis 的本地转发通道。

---

## 10. SSH 与 Git：在 GitHub 等平台使用密钥

### 10.1 为什么 Git 平台使用 SSH

GitHub、GitLab、Bitbucket 等平台支持两种认证方式：HTTPS 和 SSH。使用 HTTPS 每次推送都需要输入账号密码（或配置凭证管理器），而 SSH 密钥一次配置、长期有效，是更推荐的方式。

### 10.2 将公钥添加到 GitHub

```bash
# 第一步：查看并复制公钥
cat ~/.ssh/id_ed25519.pub
# 复制输出的全部内容（以 ssh-ed25519 开头，以邮箱结尾）
```

进入 `GitHub → Settings → SSH and GPG keys → New SSH key`：

- **Title**：给这个密钥起个名字，方便识别（如"MacBook Pro 2026"）
- **Key type**：选 Authentication Key
- **Key**：粘贴公钥内容

保存后，验证连接：

```bash
ssh -T git@github.com
# 成功输出：Hi username! You've successfully authenticated...
```

### 10.3 克隆仓库时使用 SSH 地址

```bash
# SSH 方式克隆（需配置好密钥）
git clone git@github.com:username/repo.git

# 将已有仓库的远程地址从 HTTPS 改为 SSH
git remote set-url origin git@github.com:username/repo.git

# 验证
git remote -v
# origin  git@github.com:username/repo.git (fetch)
# origin  git@github.com:username/repo.git (push)
```

---

## 11. 多账号管理：同一台机器使用多套密钥

### 11.1 使用场景

开发者经常遇到的情况：个人 GitHub 账号和公司 GitHub 账号（或 GitLab）都需要在同一台电脑上使用。由于 GitHub 不允许同一个公钥被添加到多个账号，你需要为每个账号生成独立的密钥，并告诉 SSH 在连接不同账号时使用哪个密钥。

### 11.2 生成多套密钥

```bash
# 个人账号密钥
ssh-keygen -t ed25519 -C "personal@gmail.com" -f ~/.ssh/id_ed25519_personal

# 工作账号密钥
ssh-keygen -t ed25519 -C "work@company.com" -f ~/.ssh/id_ed25519_work
```

分别将两个公钥添加到对应的 GitHub 账号（步骤见上节）。

### 11.3 通过 SSH Config 隔离账号

```text
# 个人 GitHub 账号
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes

# 工作 GitHub 账号
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
```

### 11.4 在不同仓库中使用不同账号

配置好之后，关键在于使用 **Host 别名** 而不是真实域名来设置仓库的 remote 地址：

```bash
# 个人项目：使用 github-personal 别名
git clone git@github-personal:your-personal-username/repo.git

# 工作项目：使用 github-work 别名
git clone git@github-work:company-org/repo.git

# 修改已有仓库的 remote
git remote set-url origin git@github-work:company-org/repo.git

# 验证
git remote -v
# origin  git@github-work:company-org/repo.git (fetch)
```

验证各账号是否正确：

```bash
# 测试个人账号
ssh -T git@github-personal
# 输出：Hi personal-username! You've successfully authenticated...

# 测试工作账号
ssh -T git@github-work
# 输出：Hi work-username! You've successfully authenticated...
```

这种方式的优点是"默认正确"——不同仓库的 remote 地址决定了使用哪套密钥，无需手动切换，减少误操作。

---

## 12. 服务端安全加固：sshd_config

### 12.1 服务端配置文件位置

SSH 服务端的配置文件是 `/etc/ssh/sshd_config`，修改后需要重启服务生效。**修改前务必保持一个已登录的 SSH 会话作为备份，防止配置错误导致锁定自己。**

```bash
# 编辑配置文件
sudo nano /etc/ssh/sshd_config

# 修改后测试配置是否有语法错误（不要跳过这一步！）
sudo sshd -t

# 确认无误后重启 SSH 服务
sudo systemctl restart sshd
```

### 12.2 推荐的安全加固配置

```text
# /etc/ssh/sshd_config 推荐配置

# ─── 端口设置 ───────────────────────────────────────────
Port 2222                        # 修改默认端口（减少自动化扫描攻击）
# 注意：修改端口是"减少噪音"而非"真正安全"，不能替代其他安全措施

# ─── 认证方式 ───────────────────────────────────────────
PasswordAuthentication no        # 禁用密码登录（强烈推荐！）
PubkeyAuthentication yes         # 启用公钥认证
AuthorizedKeysFile .ssh/authorized_keys

# ─── 禁止危险登录方式 ────────────────────────────────────
PermitRootLogin no               # 禁止 root 直接登录
PermitEmptyPasswords no          # 禁止空密码

# ─── 连接安全限制 ────────────────────────────────────────
MaxAuthTries 3                   # 最多尝试 3 次认证（防暴力破解）
MaxSessions 10                   # 每个连接最多 10 个会话
LoginGraceTime 30                # 30 秒内未完成认证则断开
ClientAliveInterval 300          # 300 秒无活动则发送保活包
ClientAliveCountMax 2            # 发送 2 次保活无响应则断开

# ─── 限制可登录用户（按需配置）────────────────────────────
AllowUsers ubuntu ops deploy     # 只允许指定用户登录
# AllowGroups sshusers           # 或者只允许指定用户组

# ─── 禁用不需要的功能 ────────────────────────────────────
X11Forwarding no                 # 禁用 X11 图形转发（服务器通常不需要）
AllowAgentForwarding no          # 禁用 Agent 转发（除非明确需要）
AllowTcpForwarding no            # 禁用端口转发（若不需要可关闭）
```

> **最重要的三条**：`PasswordAuthentication no`（关闭密码登录）、`PermitRootLogin no`（禁止 root 登录）、`MaxAuthTries 3`（限制重试次数）。这三条能抵御绝大多数针对 SSH 的自动化攻击。

### 12.3 管理 authorized_keys

```bash
# 查看已授权的公钥
cat ~/.ssh/authorized_keys

# 每行对应一个允许登录的公钥，格式为：
# ssh-ed25519 AAAAC3... user@host

# 删除不再需要的公钥：直接编辑文件，删除对应行
nano ~/.ssh/authorized_keys

# 确认权限正确
chmod 600 ~/.ssh/authorized_keys
```

定期审计 `authorized_keys` 是一个好习惯：删除离职员工的密钥、删除不再使用的机器密钥，保持最小授权原则。

---

## 13. 排错与诊断：遇到问题怎么办

### 13.1 分层排查思路

SSH 问题可以分为三类，依次排查：

```
层级 1：网络连通性   →  能否到达目标主机的 SSH 端口？
层级 2：服务器身份   →  known_hosts 指纹是否匹配？
层级 3：用户认证     →  密钥是否正确？权限是否正确？
```

不要把三类问题混在一起排查，先确认网络层没问题，再看认证层。

### 13.2 检查网络连通性

```bash
# 检查目标主机的 SSH 端口是否可达
nc -zv server.example.com 22
# 输出：Connection to server.example.com 22 port [tcp/ssh] succeeded!

# 如果用了非标准端口
nc -zv server.example.com 2222

# 或者用 telnet 测试（更通用）
telnet server.example.com 22
```

如果网络不通，检查：服务器防火墙、云服务商安全组规则、本地网络策略。

### 13.3 使用 -vvv 查看详细日志

`-vvv` 是排错的核心工具，它展示 SSH 连接的每一个步骤：

```bash
ssh -vvv user@host

# 关键日志片段解读：
# debug1: Connecting to host [ip] port 22.       ← 网络连接
# debug1: Server host key: ED25519 SHA256:...    ← 服务器指纹
# debug1: Host 'host' is known...                ← 指纹验证通过
# debug1: Trying private key: ~/.ssh/id_ed25519  ← 尝试密钥
# debug1: Authentication succeeded               ← 认证成功
```

常见失败模式：

```bash
# 1. 密钥未被服务器接受
debug1: Offering public key: ~/.ssh/id_ed25519
debug1: Authentications that can continue: publickey
# 服务器没有接受这个密钥 → 检查服务器 authorized_keys

# 2. 没有可用密钥
debug1: No more authentication methods to try.
Permission denied (publickey).
# → 检查 IdentityFile 配置，或用 ssh-add 加载密钥

# 3. 权限问题
debug1: bad ownership or modes for file ~/.ssh/config
# → 修复文件权限
```

### 13.4 常见错误与解决方案

**错误 1：`Permission denied (publickey)`**

```bash
# 排查步骤：
# 1. 确认服务器上 authorized_keys 包含你的公钥
cat ~/.ssh/id_ed25519.pub        # 本地公钥内容
ssh user@host cat ~/.ssh/authorized_keys  # 服务器端（需要先能登录）

# 2. 检查服务器端权限
ssh user@host "ls -la ~/.ssh/"
# .ssh 应该是 700，authorized_keys 应该是 600

# 3. 检查本地密钥权限
ls -la ~/.ssh/
chmod 600 ~/.ssh/id_ed25519

# 4. 确认使用了正确的密钥
ssh -vvv user@host 2>&1 | grep "Trying\|Offering\|succeeded"
```

**错误 2：`Host key verification failed`**

```bash
# 含义：服务器指纹与 known_hosts 中记录不符
# 可能原因：服务器重装了系统（合法）或存在中间人攻击（危险）

# 如果确认是合法的服务器重装：
ssh-keygen -R server.example.com   # 删除旧指纹
ssh user@server.example.com        # 重新连接，确认新指纹
```

**错误 3：`WARNING: UNPROTECTED PRIVATE KEY FILE!`**

```bash
# 原因：私钥文件权限过宽（不是 600）
chmod 600 ~/.ssh/id_ed25519
```

**错误 4：`Connection refused`**

```bash
# 原因：SSH 服务未运行，或端口不对
nc -zv host 22         # 检查 22 端口是否开放
nc -zv host 2222       # 检查自定义端口
sudo systemctl status sshd  # 在服务器上检查服务状态
```

**错误 5：`Connection timed out`**

```bash
# 原因：防火墙或安全组规则阻断了连接
# 检查云服务商安全组是否开放了对应端口
# 检查服务器的 iptables / ufw 规则
sudo ufw status
sudo iptables -L INPUT -n
```

### 13.5 实用排错命令组合

```bash
# 综合诊断工具箱
ssh -vvv user@host                    # 最详细的连接日志
ssh -G host_alias                     # 查看最终生效的配置
ssh-add -l                            # 列出 agent 中已加载的密钥
ssh-keygen -F server.example.com      # 在 known_hosts 中查找服务器指纹
ssh-keygen -R server.example.com      # 删除 known_hosts 中的旧指纹
ssh-keygen -lf ~/.ssh/id_ed25519.pub  # 查看公钥指纹（用于与服务器对比）
nc -zv host 22                        # 测试端口连通性
```

---

## 14. 命令速查总表

### 密钥管理

| 命令 | 说明 |
|------|------|
| `ssh-keygen -t ed25519 -C "mail"` | 生成 Ed25519 密钥（推荐） |
| `ssh-keygen -t ed25519 -C "mail" -f ~/.ssh/id_name` | 生成并指定文件名 |
| `ssh-keygen -lf ~/.ssh/id_ed25519.pub` | 查看密钥指纹 |
| `ssh-copy-id -i ~/.ssh/id.pub user@host` | 将公钥复制到服务器 |
| `chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_*` | 修复密钥权限 |

### ssh-agent

| 命令 | 说明 |
|------|------|
| `eval "$(ssh-agent -s)"` | 启动 ssh-agent |
| `ssh-add ~/.ssh/id_ed25519` | 加载私钥到 agent |
| `ssh-add -l` | 列出已加载密钥 |
| `ssh-add -d ~/.ssh/id_name` | 从 agent 移除密钥 |
| `ssh-add -D` | 清空 agent 中所有密钥 |

### 连接与认证

| 命令 | 说明 |
|------|------|
| `ssh user@host` | 基本连接 |
| `ssh -p 2222 user@host` | 指定端口 |
| `ssh -i ~/.ssh/id_name user@host` | 指定私钥 |
| `ssh -T git@github.com` | 测试 GitHub SSH 连接 |
| `ssh -J user@jump user@target` | 通过跳板机连接 |
| `ssh user@host "command"` | 远程执行命令 |

### 文件传输

| 命令 | 说明 |
|------|------|
| `scp file.txt user@host:/path/` | 上传文件 |
| `scp user@host:/path/file.txt ./` | 下载文件 |
| `scp -r ./dir/ user@host:/path/` | 上传目录（递归） |
| `scp -P 2222 file.txt user@host:/path/` | 指定端口上传 |
| `sftp user@host` | 进入交互式文件传输 |

### 端口转发

| 命令 | 说明 |
|------|------|
| `ssh -L 本地端口:目标主机:目标端口 user@host` | 本地端口转发 |
| `ssh -R 远程端口:localhost:本地端口 user@host` | 远程端口转发 |
| `ssh -D 1080 user@host` | 动态代理（SOCKS5） |
| `ssh -N -f -L 5433:127.0.0.1:5432 user@host` | 后台运行转发 |

### 排错与诊断

| 命令 | 说明 |
|------|------|
| `ssh -vvv user@host` | 最详细调试日志 |
| `ssh -G host_alias` | 查看最终生效配置 |
| `ssh-keygen -F host` | 在 known_hosts 中查找指纹 |
| `ssh-keygen -R host` | 删除 known_hosts 中的旧指纹 |
| `nc -zv host 22` | 测试端口连通性 |

### 服务端管理

| 命令 | 说明 |
|------|------|
| `sudo sshd -t` | 测试 sshd 配置文件语法 |
| `sudo systemctl restart sshd` | 重启 SSH 服务 |
| `sudo systemctl status sshd` | 查看 SSH 服务状态 |
| `sudo ss -tlnp \| grep sshd` | 查看 SSH 监听端口 |

---

## 15. 延伸阅读

### 官方文档

- [**OpenSSH 官方文档**](https://www.openssh.com/manual.html)：`ssh`、`scp`、`sftp`、`ssh-keygen`、`sshd_config` 所有命令的权威参考手册
- [**ssh_config 手册（man 页）**](https://man.openbsd.org/ssh_config)：客户端配置文件所有参数的完整说明
- [**sshd_config 手册**](https://man.openbsd.org/sshd_config)：服务端配置文件所有参数的完整说明

### 平台集成

- [**GitHub SSH 使用指南**](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)：GitHub 官方 SSH 配置教程，含图文步骤
- [**GitLab SSH 配置文档**](https://docs.gitlab.com/ee/user/ssh.html)：GitLab 平台的 SSH 密钥使用说明

### 深入学习

- [**SSH Academy：SSH Tunneling 介绍**](https://www.ssh.com/academy/ssh/tunneling)：端口转发与隧道技术的详细解释，含原理图示
- [**SSH Academy：Public Key Authentication**](https://www.ssh.com/academy/ssh/public-key-authentication)：公钥认证机制的深度讲解
- [**Arch Linux Wiki：SSH Keys**](https://wiki.archlinux.org/title/SSH_keys)：全面的 SSH 密钥使用指南，包含各种场景的详细说明

### 安全实践

- [**Mozilla SSH 安全指南**](https://infosec.mozilla.org/guidelines/openssh)：Mozilla 安全团队整理的 OpenSSH 服务端和客户端安全配置建议，可直接参考

---

*本文档持续维护更新。如有错误或建议，欢迎提交 Issue 或 PR。*