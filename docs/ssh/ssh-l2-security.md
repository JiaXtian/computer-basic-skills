---
title: SSH L2 安全与转发
summary: 最小权限、安全加固、跳板机和端口转发
level: intermediate
prerequisites: ["已掌握 SSH L1"]
updated_at: 2026-03-12
---

# SSH L2 安全与转发

难度：L2 进阶

## 1. 概念

本章目标：让 SSH 从“可用”变成“安全可控”。

关键主题：

- 最小权限与密钥轮换
- 禁用密码登录（服务端）
- 跳板机访问
- 端口转发（本地/远程/动态）

## 2. 环境准备

```bash
# 客户端配置文件
mkdir -p ~/.ssh && chmod 700 ~/.ssh
touch ~/.ssh/config && chmod 600 ~/.ssh/config
```

## 3. 常用命令

`~/.ssh/config` 示例：

```text
Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_personal

Host prod
  HostName 203.0.113.10
  User ubuntu
  IdentityFile ~/.ssh/id_ed25519_work
  ServerAliveInterval 30
```

端口转发示例：

```bash
# 本地转发：本地5433 -> 远程5432
ssh -L 5433:127.0.0.1:5432 user@server

# 动态转发（SOCKS5）
ssh -D 1080 user@server
```

## 4. 实战任务

任务：通过跳板机连接内网主机。

```text
Host bastion
  HostName bastion.example.com
  User ops

Host inner-db
  HostName 10.0.10.20
  User dbadmin
  ProxyJump bastion
```

连接测试：

```bash
ssh inner-db
```

回滚/撤销方案：

- 删除新增 Host 配置段
- 执行 `ssh -G inner-db` 验证配置是否仍生效

## 5. 常见错误

- `Bad owner or permissions on ~/.ssh/config`
  - 解决：`chmod 600 ~/.ssh/config`
- 转发端口被占用
  - 解决：更换本地端口，如 `-L 15433:...`

## 6. 自测题

1. `-L`、`-R`、`-D` 有何区别？
2. 为什么 `~/.ssh` 权限必须严格？
3. 跳板机模式如何降低暴露面？

## 7. 延伸阅读

- SSH Tunneling: https://www.ssh.com/academy/ssh/tunneling
