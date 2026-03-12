---
title: Docker L1 基础
summary: Docker 镜像、容器与生命周期管理入门
level: beginner
prerequisites: ["安装 Docker Desktop 或 Docker Engine"]
updated_at: 2026-03-12
---

# Docker L1 基础

难度：L1 入门

## 1. 概念

- 镜像（Image）：只读模板
- 容器（Container）：镜像的运行实例
- 仓库（Registry）：镜像存储分发中心

## 2. 环境准备

```bash
docker version
docker info
```

预期输出示例：

```text
Client: Docker Engine - Community
Server: Docker Engine - Community
```

## 3. 常用命令

```bash
# 拉取镜像
docker pull nginx:alpine

# 启动容器
docker run -d --name web -p 8080:80 nginx:alpine

# 查看运行状态
docker ps

# 查看日志
docker logs web

# 进入容器
docker exec -it web sh
```

## 4. 实战任务

任务：启动 Nginx 并验证访问。

```bash
docker run -d --name hello-nginx -p 8081:80 nginx:alpine
curl -I http://127.0.0.1:8081
```

预期输出示例：

```text
HTTP/1.1 200 OK
```

回滚/撤销方案：

```bash
docker rm -f hello-nginx
```

## 5. 常见错误

- `Cannot connect to the Docker daemon`
  - 根因：Docker 服务未启动
  - 解决：启动 Docker Engine/Desktop
- 端口占用
  - 根因：宿主机端口冲突
  - 解决：换端口映射，如 `-p 18081:80`

## 6. 自测题

1. 镜像和容器的区别是什么？
2. 为什么容器默认是临时文件系统？
3. `docker run -d` 与 `-it` 适用场景分别是什么？

## 7. 延伸阅读

- Docker Docs: https://docs.docker.com/
