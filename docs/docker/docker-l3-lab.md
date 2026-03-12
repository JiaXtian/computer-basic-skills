---
title: Docker L3 实战
summary: 多阶段构建、镜像优化与生产发布前检查
level: intermediate
prerequisites: ["已掌握 Docker L1/L2"]
updated_at: 2026-03-12
---

# Docker L3 实战

难度：L3 实战

## 1. 概念

L3 关注“可发布镜像”：

- 体积可控
- 构建可重复
- 安全基线可检查

## 2. 环境准备

```bash
docker buildx version || true
```

## 3. 常用命令

多阶段 Dockerfile 示例：

```Dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
```

构建与检查：

```bash
docker build -t myapp:local .
docker images | grep myapp
docker history myapp:local
```

## 4. 实战任务

任务：将镜像体积从“开发镜像”优化到“生产镜像”。

建议步骤：

1. 先构建单阶段镜像并记录大小。
2. 改为多阶段构建。
3. 复测镜像大小与启动时间。

回滚/撤销方案：

```bash
# 删除测试镜像
docker rmi myapp:local || true
```

## 5. 常见错误

- 构建缓存失效导致慢构建
  - 根因：`COPY . .` 太早
  - 解决：先复制依赖声明文件再安装依赖
- 容器启动即退出
  - 根因：主进程结束
  - 解决：确保 CMD/ENTRYPOINT 为前台长期进程

## 6. 自测题

1. 多阶段构建如何降低镜像体积？
2. 为什么不建议把编译工具链放进最终镜像？
3. 如何验证镜像中是否包含敏感文件？

## 7. 延伸阅读

- Dockerfile Best Practices: https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
