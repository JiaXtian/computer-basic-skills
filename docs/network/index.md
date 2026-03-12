---
title: 网络模块总览
summary: DNS、TCP/UDP、端口与连通性排查基础
level: beginner
prerequisites: ["掌握 Linux/Shell 基础命令"]
updated_at: 2026-03-12
---

# 网络模块总览

难度：L2 进阶

## 1. 概念

网络排障核心是定位“哪一层”出问题：DNS、路由、端口、应用协议。

## 2. 环境准备

```bash
ip addr || ifconfig
nslookup example.com || dig example.com
```

## 3. 常用命令

```bash
# 连通性
ping -c 4 example.com
traceroute example.com

# 端口
telnet example.com 443 || nc -zv example.com 443

# HTTP 请求
curl -I https://example.com

# 套接字
ss -tulpen
```

## 4. 实战任务

任务：定位“服务返回 502”问题。

1. 验证 DNS 是否正确。
2. 验证目标端口是否可达。
3. 检查上游服务健康状态。
4. 验证负载均衡与后端连通性。

回滚/撤销方案：恢复最近一次网络配置变更。

## 5. 常见错误

- DNS 缓存未刷新
- 防火墙策略遗漏
- TLS 证书过期

## 6. 自测题

1. `ping` 正常但业务不可用可能是什么原因？
2. `curl -I` 能帮助验证哪些信息？
3. 如何区分“DNS 问题”和“端口问题”？

## 7. 延伸阅读

- Cloudflare Learning Center: https://www.cloudflare.com/learning/
