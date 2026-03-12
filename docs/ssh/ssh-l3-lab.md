---
title: SSH L3 实战
summary: GitHub 多账号隔离与远程服务器调试实战
level: intermediate
prerequisites: ["已掌握 SSH L1/L2"]
updated_at: 2026-03-12
---

# SSH L3 实战

难度：L3 实战

## 1. 概念

目标：一个开发者同时维护个人与工作账号，并安全访问远程主机。

## 2. 环境准备

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_personal -C "personal@example.com"
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_work -C "work@example.com"
```

## 3. 常用命令

```text
Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_personal

Host github-work
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_work
```

仓库远程地址示例：

```bash
git remote set-url origin git@github-work:org/repo.git
```

## 4. 实战任务

任务：完成“多账号 + 远程调试”闭环。

1. 为两个账号上传不同公钥。
2. 用 alias 主机测试连接。
3. 通过 `ssh -L` 暴露远程服务到本地调试。

```bash
ssh -T github-personal
ssh -T github-work
ssh -L 8080:127.0.0.1:80 user@server
```

回滚/撤销方案：

- 移除对应公钥并删除本地私钥
- 删除 `~/.ssh/config` 中的 alias

## 5. 常见错误

- 现象：推送代码走错账号
  - 解决：检查 `git remote -v` 与 Host alias
- 现象：连接偶发中断
  - 解决：在 config 中加 `ServerAliveInterval` 与 `ServerAliveCountMax`

## 6. 自测题

1. 如何让不同仓库自动使用不同 SSH 密钥？
2. 端口转发调试结束后应清理什么？
3. 为什么生产环境建议使用跳板机？

## 7. 延伸阅读

- GitHub SSH: https://docs.github.com/en/authentication/connecting-to-github-with-ssh
