---
title: SSH 速查
summary: SSH 高频连接、配置与排错命令速查表
level: beginner
prerequisites: ["无"]
updated_at: 2026-03-12
---

# SSH 速查

| 场景 | 命令 |
|---|---|
| 查看版本 | `ssh -V` |
| 生成密钥 | `ssh-keygen -t ed25519 -C "mail@example.com"` |
| 加载密钥 | `ssh-add ~/.ssh/id_ed25519` |
| 测试 GitHub | `ssh -T git@github.com` |
| 本地端口转发 | `ssh -L 5433:127.0.0.1:5432 user@host` |
| 详细日志 | `ssh -vvv user@host` |
