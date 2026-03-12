---
title: Linux 模块总览
summary: Linux 文件系统、权限、进程与日志基础
level: beginner
prerequisites: ["掌握 Shell L1"]
updated_at: 2026-03-12
---

# Linux 模块总览

难度：L2 进阶

## 1. 概念

Linux 是大多数服务器环境的基础。本模块帮助你建立系统层面的认知。

## 2. 环境准备

最低要求：可访问一台 Linux 主机（本机虚拟机/云主机均可）。

```bash
uname -a
cat /etc/os-release
```

## 3. 常用命令

```bash
# 权限与属主
ls -l
chmod 644 file.txt
chown user:group file.txt

# 进程
ps aux | head -n 5
kill -15 <pid>

# 日志
journalctl -xe
```

## 4. 实战任务

任务：定位某服务异常退出根因。

1. 查看服务状态：`systemctl status <service>`
2. 查看日志：`journalctl -u <service> -n 100`
3. 修复后重启服务并验证。

回滚/撤销方案：恢复配置备份并重启服务。

## 5. 常见错误

- 权限不够：使用最小必要权限，不直接依赖 root。
- 日志量过大：按时间窗口与关键字筛选。

## 6. 自测题

1. `chmod 755` 与 `644` 适用对象有何区别？
2. `SIGTERM` 与 `SIGKILL` 区别是什么？
3. 如何查看某服务最近 1 小时日志？

## 7. 延伸阅读

- Linux man pages: https://man7.org/linux/man-pages/
