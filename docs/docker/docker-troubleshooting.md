---
title: Docker 排错手册
summary: 容器运行、构建与网络问题的定位方法
level: intermediate
prerequisites: ["已掌握 Docker 基础"]
updated_at: 2026-03-12
---

# Docker 排错手册

难度：L3 实战

## 1. 概念

Docker 排错应按层次排查：镜像层 -> 容器层 -> 网络层 -> 存储层。

## 2. 环境准备

```bash
docker ps -a
docker images
```

## 3. 常用排错命令

```bash
# 查看容器详情
docker inspect <container>

# 查看资源占用
docker stats

# 查看网络
docker network ls
docker network inspect bridge
```

## 4. 实战任务

任务：定位“容器能启动但服务不可访问”。

排查步骤：

1. 确认容器状态为 `Up`。
2. 检查端口映射是否正确。
3. 进入容器内检查进程与监听端口。
4. 检查宿主机防火墙与端口占用。

```bash
docker ps
docker port <container>
docker exec -it <container> sh
```

回滚/撤销方案：

```bash
docker compose down
docker container prune -f
```

## 5. 常见错误

- `no space left on device`
  - 根因：镜像与卷堆积
  - 解决：`docker system df` 后清理无用资源
- `exec format error`
  - 根因：镜像架构与宿主机不匹配
  - 解决：指定平台构建，如 `--platform linux/amd64`

## 6. 自测题

1. `docker inspect` 在排错中解决什么问题？
2. 为什么容器日志为空也不代表服务正常？
3. 清理资源时如何避免误删生产数据卷？

## 7. 延伸阅读

- Docker Networking: https://docs.docker.com/network/
