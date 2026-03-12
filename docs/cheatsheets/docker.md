---
title: Docker 速查
summary: Docker 构建、运行、排错高频命令速查表
level: beginner
prerequisites: ["无"]
updated_at: 2026-03-12
---

# Docker 速查

| 场景 | 命令 |
|---|---|
| 查看容器 | `docker ps -a` |
| 构建镜像 | `docker build -t app:local .` |
| 启动容器 | `docker run -d --name app -p 8080:80 app:local` |
| 查看日志 | `docker logs -f app` |
| Compose 启动 | `docker compose up -d` |
| 清理资源 | `docker system prune` |
