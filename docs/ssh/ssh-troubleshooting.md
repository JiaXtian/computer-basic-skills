---
title: SSH 排错手册
summary: SSH 连接失败、认证失败与转发异常诊断
level: intermediate
prerequisites: ["已掌握 SSH 基础"]
updated_at: 2026-03-12
---

# SSH 排错手册

难度：L3 实战

## 1. 概念

SSH 排错首要手段是打开详细日志并分层排查：网络层、认证层、权限层。

## 2. 环境准备

```bash
ssh -vvv user@host
```

## 3. 常用排错命令

```bash
# 查看 agent 中已加载的密钥
ssh-add -l

# 检查最终生效配置
ssh -G host_alias

# 清理已知主机记录
ssh-keygen -R host.example.com
```

## 4. 实战任务

任务：定位 `Permission denied (publickey)`。

排查顺序：

1. 确认私钥权限 `chmod 600`。
2. 确认 agent 已加载目标密钥。
3. 确认服务端 `authorized_keys` 包含对应公钥。
4. 使用 `ssh -vvv` 观察客户端尝试了哪个密钥。

回滚/撤销方案：

- 恢复被修改前的 `~/.ssh/config` 备份
- 重新加载已知可用的密钥

## 5. 常见错误

- `Host key verification failed`
  - 根因：主机指纹不匹配
  - 解决：验证后更新 `known_hosts`
- `Connection timed out`
  - 根因：端口/防火墙/路由问题
  - 解决：先 `ping`/`nc -zv host 22` 验证连通性

## 6. 自测题

1. 为什么 `-vvv` 是 SSH 排错第一步？
2. 何时需要删除 `known_hosts` 条目？
3. 认证失败时如何区分“密钥问题”和“权限问题”？

## 7. 延伸阅读

- ssh_config 文档: https://man.openbsd.org/ssh_config
