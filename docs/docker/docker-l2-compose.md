---
title: Docker L2 Compose
summary: 多服务编排、网络与卷管理实战
level: intermediate
prerequisites: ["已掌握 Docker L1"]
updated_at: 2026-03-12
---

# Docker L2 Compose

难度：L2 进阶

## 1. 概念

Compose 用声明式方式管理多容器系统，适合本地开发与集成测试。

关键点：

- 服务定义（services）
- 网络（networks）
- 数据卷（volumes）
- 环境变量（env）

## 2. 环境准备

```bash
docker compose version
```

## 3. 常用命令

`docker-compose.yml` 示例：

```yaml
services:
  app:
    image: nginx:alpine
    ports:
      - "8080:80"
    depends_on:
      - redis

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  redis_data:
```

执行命令：

```bash
docker compose up -d
docker compose ps
docker compose logs -f
```

## 4. 实战任务

任务：启动 `web + redis` 并确认 Redis 持久化卷存在。

```bash
docker compose up -d
docker volume ls | grep redis_data
```

回滚/撤销方案：

```bash
docker compose down
# 若要删除卷
docker compose down -v
```

## 5. 常见错误

- `depends_on` 已启动但服务不可用
  - 根因：启动顺序不等于就绪
  - 解决：加健康检查或重试机制
- 环境变量未生效
  - 根因：`.env` 路径错误或变量名不一致
  - 解决：使用 `docker compose config` 查看最终配置

## 6. 自测题

1. 为什么 `depends_on` 不能保证服务“可用”？
2. 什么场景应该 `down -v`？
3. 如何检查 Compose 合并后的实际配置？

## 7. 延伸阅读

- Compose Spec: https://compose-spec.io/
