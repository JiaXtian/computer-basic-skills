# Docker 完整指南（含 Kubernetes 入门）

> **适用人群**：计算机系新生、转行入门者、需要系统掌握容器化工程实践的开发者和运维人员
> **前置要求**：掌握基础命令行与文件结构，了解应用运行的基本概念
> **最后更新**：2026-03-13

---


# Docker 基础篇

## 1. Docker 是什么，解决了什么问题

### 1.1 软件交付的"环境地狱"

在 Docker 出现之前，开发团队有一个几乎人人都经历过的痛苦："在我电脑上是好的。"应用在开发机上运行完美，一部署到测试服务器就报错，测试通过后上生产又出现新问题。根源往往是：

- 开发机装了 Node.js 18，服务器是 14
- 依赖库版本不一致（package-lock.json 被忽略）
- 系统库缺失（如 libssl.so.1.1 版本不对）
- 环境变量配置差异
- 操作系统不同（macOS vs Linux）

这个问题被称为"环境地狱"（Dependency Hell），每次解决都靠手工排查，既耗时又不可复现。

### 1.2 Docker 的核心价值

Docker 的解法是：**把应用和它所有的运行依赖打包在一起**，形成一个可移植的"容器镜像"。这个镜像在任何安装了 Docker 的机器上，都以完全相同的方式运行。

它不是虚拟机——虚拟机模拟整套硬件，包含完整的操作系统内核，启动慢、占用大。Docker 容器**共享宿主机的 Linux 内核**，只隔离用户空间的进程、文件系统、网络、资源，启动时间以秒甚至毫秒计，资源开销极小。

```
虚拟机架构：                    Docker 架构：
┌──────────┐                  ┌──────┬──────┬──────┐
│  App A   │                  │App A │App B │App C │
├──────────┤                  ├──────┴──────┴──────┤
│  Guest   │                  │    Docker Engine    │
│   OS     │                  ├────────────────────┤
├──────────┤                  │      Host OS        │
│Hypervisor│                  ├────────────────────┤
├──────────┤                  │      Hardware       │
│ Host OS  │                  └────────────────────┘
└──────────┘
（每个 VM 有完整 OS）          （容器共享内核，只隔离用户空间）
```

### 1.3 Docker 能做哪些事

| 场景 | Docker 的价值 |
|------|--------------|
| **开发环境统一** | 团队所有人用同一个容器开发，消除"我电脑上可以"问题 |
| **持续集成/交付** | CI 服务器与生产环境使用同一镜像，确保测试结果可信 |
| **微服务部署** | 每个服务独立打包，独立部署，互不干扰 |
| **快速搭建依赖** | 一行命令启动 MySQL、Redis、Nginx，无需安装配置 |
| **应用沙箱隔离** | 不同版本的 Python、Node.js 在同一机器并行运行 |
| **云原生基础** | Kubernetes 等容器编排平台的基础单元 |

---

## 2. 核心概念：镜像、容器、仓库

### 2.1 三个核心概念的关系

理解 Docker 只需要牢记三个类比：

```
镜像（Image）     →  配方/模板（只读，可复用）
容器（Container） →  根据配方跑起来的实例（有生命周期）
仓库（Registry）  →  存储和分发镜像的平台（如 Docker Hub）
```

**镜像**是静态的、只读的文件系统快照。你可以从镜像创建任意多个容器实例，就像从同一个模板克隆出多份完全相同的环境。

**容器**是镜像运行起来的实例，有自己的进程、网络、文件系统（在镜像只读层之上加了一个可写层）。容器删除后，可写层的数据也随之消失，这就是为什么需要单独管理数据持久化。

**仓库**是镜像的分发平台，`docker pull nginx:alpine` 就是从 Docker Hub 拉取 nginx 镜像的 alpine 标签版本。

### 2.2 镜像的分层结构

Docker 镜像不是一个整体文件，而是多个只读层（Layer）叠加的结果，每一层对应 Dockerfile 中的一条指令：

```
最终镜像
├── Layer 4: COPY ./src /app/src     ← 每次源码变化都会重建此层
├── Layer 3: RUN npm run build
├── Layer 2: RUN npm ci              ← 依赖没变就直接用缓存
├── Layer 1: COPY package*.json ./
└── Layer 0: FROM node:20-alpine     ← 基础镜像层（已在本地缓存）
```

**构建缓存机制**：构建时，Docker 从上到下检查每一层，如果该层的指令和上下文没有变化，就直接使用缓存而不重新执行。这解释了为什么 Dockerfile 的指令顺序非常重要——把变化频繁的指令放后面，变化少的放前面，能最大化缓存命中率，大幅缩短构建时间。

---

## 3. 安装与初始配置

### 3.1 安装 Docker

**macOS / Windows**：安装 [Docker Desktop](https://www.docker.com/products/docker-desktop/)，这是官方提供的图形化工具包，内含 Docker Engine、Docker Compose、Kubernetes 单节点集群。安装后从应用程序启动即可。

**Linux（Ubuntu/Debian）**：

```bash
# 方法一：官方一键安装脚本（适合快速上手）
curl -fsSL https://get.docker.com | sh

# 方法二：手动安装（生产环境推荐）
sudo apt update
sudo apt install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| sudo tee /etc/apt/sources.list.d/docker.list

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

**Linux（CentOS/RHEL）**：

```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker && sudo systemctl enable docker
```

### 3.2 初始配置

```bash
# 将当前用户加入 docker 组（避免每次都要 sudo）
sudo usermod -aG docker $USER
newgrp docker    # 立即生效（或重新登录）

# 验证安装
docker version
docker info
docker compose version

# 运行第一个容器
docker run hello-world
```

> **安全提示**：将用户加入 `docker` 组等同于给予接近 root 的权限。生产服务器上建议考虑 rootless Docker 模式，或严格审计哪些用户可以访问 Docker socket。

### 3.3 配置优化

```bash
# 配置国内镜像加速 + 日志限制（防止日志撑爆磁盘）
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json << 'EOF'
{
  "registry-mirrors": ["https://mirror.ccs.tencentyun.com"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
EOF
sudo systemctl daemon-reload && sudo systemctl restart docker
```

---

## 4. 容器的生命周期管理

### 4.1 运行容器

```bash
# 最基础：前台运行（Ctrl+C 停止）
docker run nginx

# 后台运行（-d）
docker run -d nginx

# 完整生产启动示例
docker run -d \
  --name web \                         # 命名容器，便于后续操作
  -p 8080:80 \                         # 端口映射：宿主机:容器
  --restart unless-stopped \           # 重启策略
  nginx:alpine

# 临时交互式容器（退出后自动删除）
docker run --rm -it ubuntu:22.04 bash
# -i 保持 stdin 开放  -t 分配伪终端  --rm 退出后自动删除

# 传入环境变量
docker run -d --name db \
  -e MYSQL_ROOT_PASSWORD=secret \
  -e MYSQL_DATABASE=myapp \
  -p 3306:3306 \
  mysql:8.0

# 重启策略说明：
# no              不自动重启（默认）
# on-failure:3    退出码非 0 时重启，最多 3 次
# always          总是重启（包括 Docker 服务重启后）
# unless-stopped  除非手动 stop，否则总是重启（生产推荐）
```

### 4.2 查看和管理容器

```bash
# 查看运行中的容器
docker ps

# 查看所有容器（包括已停止的）
docker ps -a

# 查看容器日志（排障第一入口）
docker logs web
docker logs --tail 200 web              # 最后 200 行
docker logs -f web                      # 实时跟踪
docker logs -f --tail 100 --since 1h web

# 进入运行中的容器
docker exec -it web bash               # 如果有 bash
docker exec -it web sh                 # alpine 镜像用 sh

# 在容器内执行单条命令
docker exec web nginx -t               # 检查 Nginx 配置语法

# 停止和删除
docker stop web                        # 优雅停止（SIGTERM）
docker stop -t 30 web                  # 最多等 30 秒
docker start web
docker restart web
docker rm web                          # 删除已停止的容器
docker rm -f web                       # 强制删除（即使运行中）

# 查看容器详细信息
docker inspect web
docker inspect -f '{{.State.Status}}' web    # 格式化输出
docker inspect web | grep IPAddress

# 实时资源监控
docker stats
docker stats --no-stream               # 只看一次

# 查看端口映射
docker port web
```

---

## 5. 镜像管理：拉取、查看与清理

### 5.1 拉取与查看镜像

```bash
# 拉取镜像
docker pull nginx                      # 拉取 latest（不推荐生产）
docker pull nginx:alpine               # 指定标签
docker pull nginx:1.25.3-alpine        # 固定精确版本（生产推荐）

# 查看本地镜像
docker images
docker images | grep nginx

# 查看镜像分层历史
docker history nginx:alpine

# 查看镜像详细信息
docker inspect nginx:alpine
```

**镜像标签选择建议**：

| 标签 | 示例 | 推荐场景 |
|------|------|---------|
| `latest` | `nginx:latest` | 本地快速测试 |
| 大版本号 | `node:20` | 跟随大版本更新 |
| 精确版本 | `node:20.11.0` | 生产环境（确保完全一致） |
| `-alpine` | `node:20-alpine` | 生产首选，体积极小 |
| `-slim` | `python:3.12-slim` | 比 alpine 兼容性好 |

### 5.2 镜像清理

```bash
# 查看 Docker 磁盘占用
docker system df

# 删除指定镜像
docker rmi nginx:alpine
docker rmi -f nginx:alpine             # 强制删除

# 清理悬空镜像（无标签、无容器使用）
docker image prune

# 清理所有未被容器使用的镜像
docker image prune -a

# 清理所有未使用资源（容器、网络、镜像）
docker system prune

# 同时清理数据卷（高危：确认无重要数据！）
docker system prune -a --volumes
```

---

# Dockerfile 篇

## 6. 编写 Dockerfile：从零构建镜像

### 6.1 常用指令详解

```dockerfile
# FROM：指定基础镜像（必须是第一条指令）
FROM node:20-alpine

# LABEL：添加元数据
LABEL maintainer="team@example.com" version="1.0.0"

# WORKDIR：设置工作目录（不存在时自动创建）
WORKDIR /app

# ENV：设置环境变量（构建时和运行时都有效）
ENV NODE_ENV=production PORT=3000

# ARG：仅在构建时有效的参数（不会保留在最终镜像）
ARG BUILD_VERSION=unknown

# COPY：复制文件到镜像（推荐，功能简洁）
COPY package*.json ./
COPY src/ ./src/

# RUN：在构建时执行命令（生成新的镜像层）
# 多条命令用 && 连接，减少层数
RUN npm ci --only=production \
    && npm cache clean --force \
    && rm -rf /tmp/*

# EXPOSE：声明容器监听的端口（仅文档作用）
EXPOSE 3000

# USER：指定运行进程的用户（安全最佳实践）
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# CMD：容器启动时的默认命令（可被 docker run 参数覆盖）
CMD ["node", "src/server.js"]

# ENTRYPOINT：固定启动命令（docker run 参数会追加到后面）
# ENTRYPOINT ["node", "src/server.js"]
```

### 6.2 一个完整的 Node.js 应用 Dockerfile

```dockerfile
FROM node:20-alpine

# 安装 dumb-init 作为 PID 1 管理进程信号
RUN apk add --no-cache dumb-init

WORKDIR /app

# 先复制依赖描述文件（充分利用层缓存）
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# 再复制源码（频繁变化，放在依赖安装之后）
COPY src/ ./src/

# 创建非 root 用户并设置归属
RUN addgroup -S appgroup && adduser -S appuser -G appgroup \
    && chown -R appuser:appgroup /app
USER appuser

EXPOSE 3000

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "src/server.js"]
```

### 6.3 .dockerignore 文件

`.dockerignore` 告诉 Docker 构建上下文时忽略哪些文件，减小上下文体积，避免敏感文件进入镜像：

```dockerignore
node_modules/
__pycache__/
.venv/
dist/
build/
.git/
.env
.env.local
*.log
test/
coverage/
README.md
.idea/
.vscode/
```

---

## 7. 多阶段构建：减小镜像体积

### 7.1 为什么需要多阶段构建

构建应用需要编译器、构建工具、开发依赖，但运行应用时完全不需要这些工具。如果把它们都打包进最终镜像，会导致镜像体积庞大、攻击面增大、拉取和部署变慢。

多阶段构建把"构建阶段"和"运行阶段"分开，最终镜像只包含运行所必需的内容。

### 7.2 Node.js 前端项目示例

```dockerfile
# ── 阶段一：构建 ──────────────────────────────────────────────
FROM node:20-alpine AS build

WORKDIR /app
COPY package*.json ./
RUN npm ci                             # 安装包含 devDependencies 的完整依赖
COPY . .
RUN npm run build                      # 编译，生成 dist/

# ── 阶段二：运行 ──────────────────────────────────────────────
FROM nginx:alpine
# 全新基础镜像，不包含任何第一阶段的内容
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### 7.3 Go 应用示例（静态二进制）

```dockerfile
# ── 阶段一：编译 ──────────────────────────────────────────────
FROM golang:1.22-alpine AS build

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
# CGO_ENABLED=0 生成静态二进制
RUN CGO_ENABLED=0 GOOS=linux go build -o server ./cmd/server

# ── 阶段二：运行（scratch 空镜像）─────────────────────────────
FROM scratch
COPY --from=build /app/server /server
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
EXPOSE 8080
ENTRYPOINT ["/server"]
# 最终镜像只有几 MB！
```

### 7.4 Python 应用示例

```dockerfile
# ── 阶段一：安装依赖 ──────────────────────────────────────────
FROM python:3.12-slim AS dependencies
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# ── 阶段二：运行 ──────────────────────────────────────────────
FROM python:3.12-slim
WORKDIR /app
COPY --from=dependencies /root/.local /root/.local
COPY src/ ./src/
ENV PATH=/root/.local/bin:$PATH

RUN adduser --disabled-password --gecos "" appuser
USER appuser
EXPOSE 8000
CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## 8. Dockerfile 最佳实践与性能优化

### 8.1 层缓存优化

```dockerfile
# 错误：先复制所有文件，任何改动都导致 npm ci 重跑
FROM node:20-alpine
WORKDIR /app
COPY . .                               # 源码变化 → 后续所有层失效
RUN npm ci

# 正确：变化少的放前面
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./                  # package.json 不变 → npm ci 命中缓存
RUN npm ci
COPY . .                               # 只有源码变化影响这层之后
```

**核心原则：变化频率低的指令放前面，变化频率高的放后面。**

### 8.2 减小镜像体积

```dockerfile
# 1. 用 alpine 或 slim 基础镜像
FROM python:3.12-alpine                # ~50MB vs python:3.12 的 ~1GB

# 2. 合并 RUN 指令并在同一层内清理
# 错误：分开写，清理对上一层无效
RUN apt update
RUN apt install -y curl git
RUN rm -rf /var/lib/apt/lists/*

# 正确：合并，真正减小体积
RUN apt update \
    && apt install -y --no-install-recommends curl git \
    && rm -rf /var/lib/apt/lists/*

# Alpine 的等效写法
RUN apk add --no-cache curl git bash

# 3. 使用 --no-install-recommends 避免安装不必要的推荐包
```

### 8.3 安全最佳实践

```dockerfile
# 1. 使用精确版本标签
FROM node:20.11.0-alpine3.19          # 可重现构建

# 2. 不以 root 运行
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# 3. 不在镜像中硬编码密钥
# 错误：
ENV API_KEY=sk-abc123-secret
# 正确：运行时通过环境变量注入
# docker run -e API_KEY="$API_KEY" my-app

# 4. 最小化安装的包
```

---

# 数据与网络篇

## 9. 数据持久化：Volume 与 Bind Mount

### 9.1 为什么容器内的数据会丢失

容器有一个可写层，但当容器被删除时，这个可写层也随之消失。数据库数据、用户上传文件、日志——所有写入容器内部的数据都会丢失。解决方案是把需要持久化的目录挂载到容器外部的存储。

### 9.2 Named Volume（命名卷）

Docker 管理卷的生命周期，数据存储在 Docker 内部（Linux 上在 `/var/lib/docker/volumes/`），与容器完全解耦。推荐用于数据库和生产环境持久化数据。

```bash
# 创建命名卷
docker volume create myapp_data

# 查看所有卷
docker volume ls

# 查看卷详情
docker volume inspect myapp_data

# 挂载卷启动容器
docker run -d \
  --name postgres \
  -v pgdata:/var/lib/postgresql/data \    # 卷名:容器内路径
  -e POSTGRES_PASSWORD=secret \
  postgres:16-alpine

# 删除卷（先确认数据已备份！）
docker volume rm myapp_data

# 删除所有未被容器使用的卷（高危！）
docker volume prune
```

### 9.3 Bind Mount（绑定挂载）

把宿主机的具体目录或文件直接挂载进容器，宿主机和容器实时共享文件变更。适合开发时热更新代码。

```bash
# 挂载当前目录（开发热更新）
docker run -d \
  --name dev-server \
  -v $(pwd):/app \                        # 宿主机路径:容器内路径
  -p 3000:3000 \
  node:20-alpine \
  sh -c "cd /app && npm run dev"

# 只读挂载配置文件
docker run -d \
  --name nginx \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  -p 80:80 nginx:alpine

# 挂载日志目录到宿主机
docker run -d --name api \
  -v /var/log/myapp:/app/logs \
  my-api:latest
```

**Volume vs Bind Mount 选择指南**：

| | Named Volume | Bind Mount |
|--|-------------|------------|
| 数据管理 | Docker 管理 | 用户管理 |
| 跨平台性 | 好 | 路径依赖宿主机 |
| 性能 | 更优 | 较好（macOS 上较慢）|
| 适用场景 | 数据库、生产持久化 | 开发时代码热更新 |

---

## 10. 容器网络：服务间通信

### 10.1 Docker 网络模式

```bash
# 查看所有网络
docker network ls
# bridge（默认）、host（共享宿主机网络）、none（无网络）

# 创建自定义 bridge 网络（推荐！）
docker network create myapp-network

# 查看网络详情
docker network inspect myapp-network
```

### 10.2 容器间通信

```bash
# 推荐：自定义网络 + 服务名通信
docker network create myapp-net

docker run -d --name db --network myapp-net \
  -e POSTGRES_PASSWORD=secret postgres:16-alpine

docker run -d --name app --network myapp-net \
  -e DATABASE_URL=postgresql://postgres:secret@db:5432/mydb \
  # 用容器名 "db" 作为主机名，自定义网络内自动 DNS 解析
  -p 8080:3000 \
  my-app:latest

# 把现有容器加入网络
docker network connect myapp-net existing-container
```

**关键点**：在自定义网络中，容器名会自动作为 DNS 名称，可以直接用 `db`、`cache` 等容器名访问其他服务。默认 bridge 网络不具备这个能力。

---

# Docker Compose 篇

## 11. Docker Compose：多容器编排

### 11.1 为什么需要 Compose

当应用需要多个协作的服务（Web + DB + Cache + Worker）时，手动执行多条 `docker run` 命令不仅繁琐，还容易遗漏参数。Docker Compose 用一个 YAML 文件描述整个应用的服务架构，一条命令拉起所有服务。

### 11.2 完整的 Compose 文件结构

```yaml
# docker-compose.yml
services:

  # Web 服务
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: my-app:latest
    ports:
      - "8080:3000"
    environment:
      NODE_ENV: production
      DATABASE_URL: postgresql://dbuser:dbpass@db:5432/mydb
      REDIS_URL: redis://cache:6379
    env_file:
      - .env                          # 从文件加载（不要提交 .env 到 git！）
    depends_on:
      db:
        condition: service_healthy    # 等到 db 健康检查通过再启动
      cache:
        condition: service_started
    restart: unless-stopped
    networks:
      - backend
    volumes:
      - app_logs:/app/logs

  # 数据库
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: mydb
      POSTGRES_USER: dbuser
      POSTGRES_PASSWORD: ${DB_PASSWORD}   # 从 .env 读取
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U dbuser -d mydb"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    restart: unless-stopped
    networks:
      - backend

  # 缓存
  cache:
    image: redis:7-alpine
    command: redis-server --appendonly yes --maxmemory 256mb
    volumes:
      - redis_data:/data
    restart: unless-stopped
    networks:
      - backend

  # 反向代理
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    depends_on:
      - app
    restart: unless-stopped
    networks:
      - backend

networks:
  backend:
    driver: bridge

volumes:
  pgdata:
  redis_data:
  app_logs:
```

### 11.3 Compose 常用命令

```bash
# 后台启动所有服务
docker compose up -d

# 启动并重新构建镜像
docker compose up -d --build

# 查看服务状态
docker compose ps

# 查看服务日志
docker compose logs -f app
docker compose logs -f --tail 100 app

# 停止（保留容器和卷）
docker compose stop

# 停止并删除容器、网络
docker compose down

# 停止并删除一切（含数据卷！慎用）
docker compose down -v

# 在服务容器内执行命令
docker compose exec app bash
docker compose exec db psql -U dbuser -d mydb

# 运行一次性任务
docker compose run --rm app node scripts/migrate.js

# 查看合并后的最终配置
docker compose config

# 扩展服务实例数
docker compose up -d --scale app=3
```

---

## 12. Compose 进阶：健康检查、依赖与环境管理

### 12.1 健康检查配置

`depends_on` 只保证启动顺序，不保证服务"已就绪"。配合 `healthcheck` 和 `condition: service_healthy`，才能真正有序启动：

```yaml
services:
  db:
    image: postgres:16-alpine
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s    # 启动后 30 秒内失败不计入重试次数

  app:
    depends_on:
      db:
        condition: service_healthy   # 等待 db 通过健康检查

# 其他常用健康检查命令
# HTTP: ["CMD", "curl", "-f", "http://localhost:3000/health"]
# Redis: ["CMD", "redis-cli", "ping"]
# MySQL: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
```

### 12.2 多环境配置管理

```bash
# 开发环境（自动合并 override 文件）
docker compose up -d
# = docker-compose.yml + docker-compose.override.yml

# 生产环境（显式指定配置文件）
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 使用不同的 .env 文件
docker compose --env-file .env.staging up -d
```

`docker-compose.override.yml`（开发专用，加入 .gitignore）：

```yaml
services:
  app:
    volumes:
      - .:/app                       # 开发时挂载源码（热更新）
      - /app/node_modules            # 避免覆盖容器内 node_modules
    environment:
      NODE_ENV: development
    command: npm run dev             # 覆盖为热更新模式
    ports:
      - "9229:9229"                  # Node.js 调试端口
```

---

# 安全与运维篇

## 13. 容器安全：不容忽视的基础实践

### 13.1 以非 root 用户运行

容器内的进程默认以 root 身份运行。如果容器被攻破，攻击者可能利用 root 权限逃逸到宿主机。

```dockerfile
# Debian/Ubuntu
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
RUN chown -R appuser:appgroup /app
USER appuser

# Alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

### 13.2 敏感信息管理

```bash
# 永远不要做：将密钥写入 Dockerfile
ENV API_KEY=sk-abc123secret          # 错！在镜像层里永久保留！

# 正确方式一：运行时通过环境变量注入
docker run -e API_KEY="$API_KEY" my-app

# 正确方式二：通过 .env 文件（.env 必须在 .gitignore 中！）
docker compose --env-file .env up -d
```

### 13.3 镜像安全扫描

```bash
# 使用 trivy 扫描镜像漏洞
trivy image nginx:alpine
trivy image --severity HIGH,CRITICAL my-app:latest

# 扫描 Dockerfile
trivy config ./Dockerfile
```

---

## 14. 资源限制与运行稳定性

没有资源限制的容器可以无限制消耗宿主机内存和 CPU，一个内存泄漏的容器会拖垮整台机器。

```bash
docker run -d \
  --name api \
  --memory="512m" \                  # 最多 512MB 内存
  --memory-swap="512m" \             # 与 memory 相同 = 禁用 swap
  --cpus="1.5" \                     # 最多 1.5 个 CPU 核心
  --pids-limit=200 \                 # 最多 200 个进程（防止 fork 炸弹）
  --restart=unless-stopped \
  my-api:latest

# 查看资源使用
docker stats api
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

在 Compose 中：

```yaml
services:
  app:
    image: my-app:latest
    deploy:
      resources:
        limits:
          cpus: '1.5'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
    restart: unless-stopped
```

---

## 15. 排错指南：系统化诊断容器问题

### 15.1 排错标准顺序

```
1. 容器是否在运行？     docker ps -a
2. 容器日志是什么？     docker logs web
3. 端口映射是否正确？   docker port web
4. 容器内进程是否正常？ docker exec -it web sh → ss -tlnp
5. 容器网络是否正常？   docker exec web curl http://db:5432
6. 容器配置是否正确？   docker inspect web
```

### 15.2 常见问题与解决方案

```bash
# 问题：容器启动后立即退出
docker ps -a                         # 看容器状态是 Exited
docker logs web                      # 查看退出原因
# 调试：覆盖启动命令进入容器检查
docker run --rm -it my-app:latest sh

# 问题：端口无法访问
docker port web                      # 确认端口映射
docker exec web ss -tlnp             # 确认容器内进程监听的是 0.0.0.0 而非 127.0.0.1

# 问题：容器内无法访问其他服务
docker network inspect myapp-net    # 确认服务在同一网络
docker exec app curl http://db:5432 # 用服务名测试连通性

# 问题：数据卷权限问题
docker exec web ls -la /app/data
# 确保容器内目录的属主与 USER 指令的用户匹配

# 问题：磁盘空间不足
docker system df
docker image prune -a                # 清理未使用镜像

# 问题：构建缓存问题
docker build --no-cache -t my-app:latest .
```

---

## 16. 镜像仓库：推送与分发

### 16.1 Docker Hub

```bash
docker login
docker tag my-app:latest username/my-app:v1.2.0
docker push username/my-app:v1.2.0
docker pull username/my-app:v1.2.0
```

### 16.2 GitHub Container Registry（GHCR）

```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
docker tag my-app:latest ghcr.io/username/my-app:v1.2.0
docker push ghcr.io/username/my-app:v1.2.0
```

### 16.3 GitHub Actions 自动构建

```yaml
# .github/workflows/docker.yml
name: Build and Push
on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: 登录 GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: 提取元数据
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=semver,pattern={{version}}
            type=sha,prefix=sha-

      - name: 构建并推送
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

---

# Kubernetes 入门篇

## 17. Kubernetes 是什么：从 Docker 到集群编排

### 17.1 Docker 的局限性

Docker 和 Docker Compose 能很好地管理单台机器上的容器。但当应用规模增长，需要：

- 在多台服务器上分布式运行容器（水平扩展）
- 某个容器崩溃后自动在另一台健康机器上重启
- 滚动更新：把新版本镜像逐步替换旧版本，不中断服务
- 根据流量自动增加或减少实例数量
- 管理数百个服务之间的负载均衡

这时 Docker 单机部署就力不从心了。**Kubernetes**（简称 K8s）是谷歌开源的容器编排系统，专门解决"如何在一个机器集群上管理大量容器"的问题。

### 17.2 Kubernetes 的架构

```
┌─────────────────────────────────────────────────────────┐
│                    Kubernetes 集群                       │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │              Control Plane（控制平面）              │  │
│  │  ┌───────────┐  ┌────────┐  ┌────────────────┐  │  │
│  │  │API Server │  │Schedul-│  │Controller Mgr  │  │  │
│  │  │           │  │  er    │  │                │  │  │
│  │  └───────────┘  └────────┘  └────────────────┘  │  │
│  │                   ┌──────┐                        │  │
│  │                   │ etcd │  ← 集群状态数据库       │  │
│  │                   └──────┘                        │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌───────────┐   ┌───────────┐   ┌───────────┐        │
│  │  Node 1   │   │  Node 2   │   │  Node 3   │        │
│  │ ┌───────┐ │   │ ┌───────┐ │   │ ┌───────┐ │        │
│  │ │  Pod  │ │   │ │  Pod  │ │   │ │  Pod  │ │        │
│  │ │  Pod  │ │   │ │  Pod  │ │   │ │  Pod  │ │        │
│  │ └───────┘ │   │ └───────┘ │   │ └───────┘ │        │
│  │  kubelet  │   │  kubelet  │   │  kubelet  │        │
│  └───────────┘   └───────────┘   └───────────┘        │
└─────────────────────────────────────────────────────────┘
```

- **Control Plane**：集群大脑，负责调度决策和状态管理
- **Node**：实际运行容器的工作机器
- **Pod**：K8s 的最小调度单位，包含一个或多个容器
- **kubelet**：每个 Node 上的代理，负责管理 Pod 生命周期

### 17.3 本地学习环境

```bash
# 方法一：Docker Desktop 内置 Kubernetes（最简单）
# Docker Desktop → Settings → Kubernetes → Enable Kubernetes

# 方法二：minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube start
minikube status

# 方法三：kind（Kubernetes in Docker，CI 常用）
kind create cluster --name dev
```

---

## 18. Kubernetes 核心概念与资源对象

### 18.1 Pod：最小调度单位

```yaml
# pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-pod
  labels:
    app: web
spec:
  containers:
    - name: web
      image: nginx:alpine
      ports:
        - containerPort: 80
      resources:
        requests:
          memory: "64Mi"
          cpu: "250m"
        limits:
          memory: "128Mi"
          cpu: "500m"
      readinessProbe:               # 就绪探针：何时可以接收流量
        httpGet:
          path: /health
          port: 80
        initialDelaySeconds: 5
        periodSeconds: 10
      livenessProbe:                # 存活探针：是否需要重启
        httpGet:
          path: /health
          port: 80
        initialDelaySeconds: 15
        periodSeconds: 20
```

### 18.2 Deployment：管理 Pod 副本

实际生产中很少直接创建 Pod，而是通过 Deployment 管理副本数量和更新策略：

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 3                       # 保持 3 个 Pod 副本
  selector:
    matchLabels:
      app: web
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: web
          image: my-app:v1.2.0
          ports:
            - containerPort: 3000
          env:
            - name: NODE_ENV
              value: production
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: password
          resources:
            requests:
              memory: "128Mi"
              cpu: "250m"
            limits:
              memory: "256Mi"
              cpu: "500m"
```

### 18.3 Service：稳定的网络端点

Pod 的 IP 动态变化，Service 提供固定的 DNS 名称和 IP：

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web                        # 选择所有 app=web 标签的 Pod
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: ClusterIP                   # ClusterIP | NodePort | LoadBalancer
```

### 18.4 ConfigMap 与 Secret

```yaml
# configmap.yaml（非敏感配置）
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  NODE_ENV: "production"
  LOG_LEVEL: "info"

---
# secret.yaml（敏感配置）
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
stringData:                         # 自动 Base64 编码
  password: "my-super-secret"
  connection-string: "postgresql://user:pass@db:5432/mydb"
```

---

## 19. kubectl：与集群交互的命令行工具

### 19.1 安装

```bash
# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/

# macOS
brew install kubectl

# 验证
kubectl version --client
```

### 19.2 核心操作

```bash
# 应用资源
kubectl apply -f deployment.yaml
kubectl apply -f .                   # 应用当前目录所有 yaml
kubectl delete -f deployment.yaml

# 查看资源
kubectl get pods
kubectl get pods -A                  # 所有命名空间
kubectl get pods -l app=web         # 按标签过滤
kubectl get pods -o wide            # 显示更多信息（节点、IP）
kubectl get deployments
kubectl get services
kubectl get all

# 查看详情（排障最常用！）
kubectl describe pod web-pod-abc123
kubectl describe deployment web-deployment

# 日志与调试
kubectl logs web-pod
kubectl logs -f web-pod
kubectl logs --tail=100 web-pod
kubectl exec -it web-pod -- bash
kubectl exec -it web-pod -- sh

# 临时端口转发（本地调试集群内服务）
kubectl port-forward pod/web-pod 8080:3000
kubectl port-forward service/web-service 8080:80

# 扩缩容与更新
kubectl scale deployment web-deployment --replicas=5
kubectl set image deployment/web-deployment web=my-app:v1.3.0
kubectl rollout status deployment/web-deployment
kubectl rollout history deployment/web-deployment
kubectl rollout undo deployment/web-deployment
kubectl rollout undo deployment/web-deployment --to-revision=2

# 资源监控
kubectl top nodes
kubectl top pods
```

### 19.3 命名空间管理

```bash
kubectl get namespaces
kubectl get pods -n production
kubectl apply -f deployment.yaml -n production
kubectl create namespace staging

# 设置默认命名空间
kubectl config set-context --current --namespace=production
```

---

## 20. 命令速查总表

### Docker 容器管理

| 命令 | 说明 |
|------|------|
| `docker run -d --name web -p 8080:80 nginx` | 后台运行并映射端口 |
| `docker run --rm -it image sh` | 临时交互容器 |
| `docker ps -a` | 查看所有容器 |
| `docker logs -f --tail 100 web` | 实时追踪日志 |
| `docker exec -it web sh` | 进入容器 |
| `docker inspect web` | 查看容器详细信息 |
| `docker stats web` | 实时资源使用 |
| `docker stop web` | 优雅停止 |
| `docker rm -f web` | 强制删除 |
| `docker port web` | 查看端口映射 |

### 镜像管理

| 命令 | 说明 |
|------|------|
| `docker build -t app:1.0 .` | 构建镜像 |
| `docker build --no-cache -t app .` | 禁用缓存重建 |
| `docker pull nginx:alpine` | 拉取镜像 |
| `docker images` | 查看本地镜像 |
| `docker rmi image:tag` | 删除镜像 |
| `docker history app:1.0` | 查看分层历史 |
| `docker system df` | 查看磁盘占用 |
| `docker system prune -a` | 清理未使用资源 |

### 数据与网络

| 命令 | 说明 |
|------|------|
| `docker volume ls` | 列出所有卷 |
| `docker volume inspect pgdata` | 查看卷详情 |
| `docker volume prune` | 清理未使用卷（危险！）|
| `docker network ls` | 列出所有网络 |
| `docker network create mynet` | 创建自定义网络 |
| `docker network connect mynet web` | 将容器加入网络 |

### Docker Compose

| 命令 | 说明 |
|------|------|
| `docker compose up -d` | 后台启动所有服务 |
| `docker compose up -d --build` | 重建镜像并启动 |
| `docker compose ps` | 查看服务状态 |
| `docker compose logs -f app` | 实时追踪日志 |
| `docker compose exec app sh` | 进入服务容器 |
| `docker compose down` | 停止并删除容器网络 |
| `docker compose down -v` | 同时删除数据卷（危险！）|
| `docker compose config` | 查看合并后配置 |
| `docker compose restart app` | 重启单个服务 |

### kubectl（Kubernetes）

| 命令 | 说明 |
|------|------|
| `kubectl get pods -A` | 查看所有命名空间的 Pod |
| `kubectl get pods -o wide` | Pod 详细信息（含节点、IP）|
| `kubectl describe pod web-pod` | 查看 Pod 事件与详情 |
| `kubectl logs -f web-pod` | 实时追踪 Pod 日志 |
| `kubectl exec -it web-pod -- sh` | 进入 Pod |
| `kubectl apply -f .` | 应用目录下所有 YAML |
| `kubectl delete -f deployment.yaml` | 按文件删除资源 |
| `kubectl scale deploy web --replicas=5` | 扩缩容 |
| `kubectl set image deploy/web web=app:v2` | 更新镜像 |
| `kubectl rollout undo deploy/web` | 回滚到上一版本 |
| `kubectl port-forward svc/web 8080:80` | 本地端口转发 |
| `kubectl top pods` | 查看 Pod 资源使用 |

---

## 21. 延伸阅读

### Docker 官方文档
- [Docker 官方文档](https://docs.docker.com/)：Docker Engine、Compose、BuildKit 的完整权威文档
- [Dockerfile 最佳实践](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)：官方 Dockerfile 编写指南
- [Docker Compose Specification](https://compose-spec.io/)：Compose 文件格式完整规范
- [Container Security Cheat Sheet（OWASP）](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)：容器安全配置清单

### Kubernetes
- [Kubernetes 官方文档（中文）](https://kubernetes.io/zh-cn/docs/home/)：K8s 完整中文文档
- [kubectl 速查表](https://kubernetes.io/zh-cn/docs/reference/kubectl/quick-reference/)：官方 kubectl 常用命令汇总
- [Kubernetes 互动教程](https://kubernetes.io/zh-cn/docs/tutorials/kubernetes-basics/)：无需本地安装的浏览器交互教程

### 工具生态
- [trivy](https://github.com/aquasecurity/trivy)：开源容器镜像漏洞扫描工具
- [dive](https://github.com/wagoodman/dive)：可视化分析 Docker 镜像各层内容
- [lazydocker](https://github.com/jesseduffield/lazydocker)：终端 Docker 管理 TUI
- [Helm](https://helm.sh/)：Kubernetes 的包管理器

---

*本文档持续维护更新。如有错误或建议，欢迎提交 Issue 或 PR。*
