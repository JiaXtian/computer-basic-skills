---
title: SSH 完整指南
summary: 从密钥认证原理到安全加固与端口转发，完整掌握 SSH 的连接、协作与排错能力
level: beginner
prerequisites: ["掌握基础命令行", "理解远程主机概念"]
updated_at: 2026-03-13
---

# SSH 完整指南

![SSH 连接链路示意图](assets/diagrams/ssh-flow.svg)

SSH 经常被理解成“远程登录命令”，但它真正的价值是“在不可信网络中建立可信通道”。你输入 `ssh user@host` 的那一刻，背后发生的是一套完整安全协议：客户端先验证服务器身份，协商加密算法，再用密钥证明“我是合法用户”，最后才开始传输命令与数据。理解这条链路后，你面对 `Permission denied (publickey)` 或 `Host key verification failed` 时会更冷静，因为你知道问题一定出在某一环，而不是“SSH 很玄学”。

先明确三个角色。第一，**私钥**在你本地，必须严格保密；第二，**公钥**放在服务器 `authorized_keys` 或 Git 平台账号里；第三，`known_hosts` 保存你信任过的服务器指纹，用于防中间人攻击。SSH 不是“公私钥配对就完事”，还包含“你是否连接到正确主机”的身份确认。很多用户为了省事把 `StrictHostKeyChecking` 关闭，这是高风险做法，尤其在公共网络环境中。

创建密钥时，建议优先 `ed25519`，它在现代系统上兼顾安全性与性能。常用命令如下：

```bash
ssh-keygen -t ed25519 -C "you@example.com"
```

参数解释：`-t` 指定算法，`-C` 写注释方便后续识别。你可以加 `-f` 指定输出文件名，避免覆盖默认密钥：

```bash
ssh-keygen -t ed25519 -C "work@example.com" -f ~/.ssh/id_ed25519_work
```

密钥生成后，权限是底线。`~/.ssh` 目录建议 `700`，私钥文件 `600`，公钥可 `644`。如果权限过宽，OpenSSH 会拒绝使用密钥并直接报错。常见修复：

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519*
chmod 644 ~/.ssh/*.pub
```

接下来是 agent。`ssh-agent` 的作用是把私钥解锁状态缓存在内存里，避免每次连接都重复输入 passphrase。你可以把常用密钥加入 agent：

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_work
ssh-add -l
```

`ssh-add -l` 会列出当前已加载密钥指纹。若连接走错密钥，优先检查这里，再看 `~/.ssh/config` 的 `IdentityFile` 与 `IdentitiesOnly` 配置是否匹配。

`~/.ssh/config` 是 SSH 真正的效率入口。很多人一直用 `ssh -i ... -p ...` 临时参数，短期可用，长期难维护。把主机配置写成别名后，你可以把复杂连接抽象成可读入口：

```text
Host prod-api
  HostName 203.0.113.10
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/id_ed25519_work
  IdentitiesOnly yes
  ServerAliveInterval 30
  ServerAliveCountMax 3
```

有了这段配置后，你只需 `ssh prod-api`。`ServerAliveInterval` 和 `ServerAliveCountMax` 能显著降低长连接因网络抖动被静默断开的概率，特别适合远程维护任务。

当你需要经过跳板机访问内网主机时，推荐 `ProxyJump`。这不仅简化命令，还能把访问路径固定在配置中，便于审计与复用：

```text
Host bastion
  HostName bastion.example.com
  User ops
  IdentityFile ~/.ssh/id_ed25519_work

Host inner-db
  HostName 10.0.10.20
  User dbadmin
  ProxyJump bastion
  IdentityFile ~/.ssh/id_ed25519_work
```

现在你执行 `ssh inner-db`，客户端会自动先连 bastion 再跳转。对于团队来说，这种显式路径比口头交接“先连 A 再连 B”稳定得多。

端口转发是 SSH 另一个高价值能力。你可以把它理解为“加密隧道映射”：本地端口映射到远程服务，或者远程端口映射回本地服务。最常见的是本地转发 `-L`，用于在本地调试远程数据库：

```bash
ssh -L 5433:127.0.0.1:5432 user@db-host
```

这条命令表示：本地访问 `127.0.0.1:5433`，数据会被安全转发到远程主机的 `127.0.0.1:5432`。如果你需要把本地服务暴露给远程主机调试，则使用远程转发 `-R`；需要临时代理通道则用动态转发 `-D`。参数虽然不同，但本质一致：通过 SSH 加密链路转运 TCP 流量。

在 Git 场景下，SSH 最常见用法是替代 HTTPS 认证。配置完成后你可以测试：

```bash
ssh -T git@github.com
```

如果你需要同机管理个人与工作两个 GitHub 账号，推荐用 Host 别名隔离密钥：

```text
Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_personal
  IdentitiesOnly yes

Host github-work
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_work
  IdentitiesOnly yes
```

然后在不同仓库设置不同 remote：

```bash
git remote set-url origin git@github-work:org/repo.git
```

这种方式的优势是“默认正确”。当你切换项目时，不需要手动切密钥，连接策略由仓库 remote 决定，减少人为失误。

SSH 排错时，优先打开详细日志 `-vvv`。它会清晰展示：客户端尝试了哪些密钥、服务器接受了什么算法、在哪一步失败。你可以把日志解析思路固定为三段：网络是否连通、主机身份是否可信、用户认证是否通过。常用组合：

```bash
ssh -vvv user@host
ssh -G host_alias
ssh-add -l
ssh-keygen -R host.example.com
```

`ssh -G` 会打印最终生效配置，非常适合检查多层配置叠加后的真实结果。很多“我明明写了 IdentityFile 但没生效”的问题，靠它一眼就能定位。

在安全策略上，建议把 SSH 当成“入口系统”而不是单条命令。你至少应建立四个习惯：第一，为不同用途分离密钥；第二，启用 passphrase；第三，定期轮换密钥并删除无效公钥；第四，生产环境优先跳板机并限制来源 IP。技术上都不复杂，但长期执行需要纪律。

如果你是团队维护者，还应和服务器配置联动。常见最小加固包括：关闭 root 直登、关闭密码登录、限制认证重试次数、启用审计日志。客户端安全和服务端安全是一个闭环，只做一半很难稳。

下面给出一个常用的 SSH 运维连接模板，兼顾可读性与稳定性：

```text
Host *.corp
  User ops
  IdentityFile ~/.ssh/id_ed25519_work
  IdentitiesOnly yes
  ServerAliveInterval 30
  ServerAliveCountMax 2
  ForwardAgent no

Host prod-web.corp
  HostName 10.20.1.15
  ProxyJump bastion.corp
```

你可以把所有服务器都放入可预测命名体系（如 `env-role.region`），一旦规模扩大，这套命名和配置规范会直接影响排障速度。

## 常用命令与参数清单（可直接查阅）

### 连接与认证

- `ssh user@host`：基础连接。
- `ssh -p 2222 user@host`：`-p` 指定端口。
- `ssh -i ~/.ssh/key user@host`：`-i` 指定私钥。
- `ssh -T git@github.com`：`-T` 禁用伪终端，常用于 Git 平台测试。
- `ssh -o StrictHostKeyChecking=accept-new user@host`：首次连接自动接受新主机指纹（谨慎使用）。

### 密钥与 agent

- `ssh-keygen -t ed25519 -C "mail" -f ~/.ssh/id_x`：生成密钥。
- `ssh-add ~/.ssh/id_x`：加载私钥到 agent。
- `ssh-add -l`：列出已加载密钥。
- `ssh-add -d ~/.ssh/id_x`：从 agent 移除密钥。

### 转发与隧道

- `ssh -L local:target_host:target_port user@jump`：本地转发。
- `ssh -R remote:localhost:local_port user@host`：远程转发。
- `ssh -D 1080 user@host`：动态代理（SOCKS5）。
- `ssh -N -f ...`：`-N` 不执行远程命令，`-f` 后台运行。

### 排错与诊断

- `ssh -vvv user@host`：最详细调试日志。
- `ssh -G alias`：打印合并后的最终配置。
- `ssh-keygen -F host`：查询 `known_hosts` 条目。
- `ssh-keygen -R host`：删除旧主机指纹。

## 延伸阅读

- [OpenSSH 官方文档](https://www.openssh.com/manual.html)
- [ssh_config 手册](https://man.openbsd.org/ssh_config)
- [GitHub SSH 指南](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [SSH Tunneling 介绍](https://www.ssh.com/academy/ssh/tunneling)
