---
title: SSH L1 基础
summary: 密钥生成、远程登录与主机信任基础
level: beginner
prerequisites: ["已安装 OpenSSH 客户端"]
updated_at: 2026-03-12
---

# SSH L1 基础

难度：L1 入门

## 1. 概念

SSH 通过加密通道实现远程命令执行与文件传输。

核心组成：

- 私钥：保存在本地，绝不外泄
- 公钥：放到服务器或 Git 平台
- `known_hosts`：记录已信任主机指纹

## 2. 环境准备

```bash
ssh -V
ls -al ~/.ssh
```

生成密钥（推荐 ed25519）：

```bash
ssh-keygen -t ed25519 -C "you@example.com"
```

预期输出示例：

```text
Your identification has been saved in /Users/.../.ssh/id_ed25519
Your public key has been saved in /Users/.../.ssh/id_ed25519.pub
```

## 3. 常用命令

```bash
# 启动 agent 并加载密钥
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# 首次连接远程主机
ssh user@server.example.com

# 复制公钥到服务器（Linux）
ssh-copy-id user@server.example.com
```

## 4. 实战任务

任务：配置 GitHub SSH 登录。

1. 复制公钥内容。
2. 添加到 GitHub SSH Keys。
3. 测试连接。

```bash
cat ~/.ssh/id_ed25519.pub
ssh -T git@github.com
```

预期输出示例：

```text
Hi <username>! You've successfully authenticated...
```

回滚/撤销方案：

```bash
# 从 agent 移除密钥
ssh-add -d ~/.ssh/id_ed25519
```

## 5. 常见错误

- `Permission denied (publickey)`
  - 根因：公钥未正确上传或私钥未加载
  - 解决：检查 `ssh-add -l` 与平台公钥配置
- 主机指纹变更告警
  - 根因：服务器重装或中间人风险
  - 解决：核对管理员提供的新指纹后更新 `known_hosts`

## 6. 自测题

1. 为什么推荐 `ed25519`？
2. `known_hosts` 文件作用是什么？
3. 为什么私钥不应该通过聊天工具发送？

## 7. 延伸阅读

- OpenSSH Manual: https://www.openssh.com/manual.html
