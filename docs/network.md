# 网络基础与故障诊断完整指南

> **适用人群**：计算机系新生、转行入门者、需要系统掌握网络排障与性能分析能力的开发者和运维人员  
> **前置要求**：掌握基础 Linux 命令，了解客户端与服务器的基本概念  
> **最后更新**：2026-03-13

---


# 网络基础篇

## 1. 网络是什么：工程师需要理解的层次模型

### 1.1 为什么工程师需要理解网络

你在开发一个 Web 应用，用户反馈"打不开"。这个问题的根源可能是：

- 域名解析失败（DNS 问题）
- 服务器端口被防火墙拦截（连通性问题）
- HTTPS 证书过期（TLS 问题）
- 应用本身崩溃（进程问题）
- 数据库连接超时（内网网络问题）
- CDN 节点缓存了旧内容（缓存问题）

如果不理解网络的分层结构，你面对"打不开"只能无头苍蝇式地乱猜。理解网络分层，你就能沿着每一层系统地排查，快速锁定问题所在。

### 1.2 OSI 模型：网络通信的七层抽象

OSI（开放系统互联）模型把网络通信分为七个层次，每一层只负责自己的职责，向上层提供服务：

```
第 7 层  应用层（Application）   HTTP、HTTPS、FTP、SSH、DNS
第 6 层  表示层（Presentation）  数据格式转换、加密（TLS 部分在此）
第 5 层  会话层（Session）       会话建立与管理
第 4 层  传输层（Transport）     TCP、UDP（端口号在此层）
第 3 层  网络层（Network）       IP、路由（IP 地址在此层）
第 2 层  数据链路层（Data Link） MAC 地址、以太网帧
第 1 层  物理层（Physical）      网线、光纤、无线电信号
```

在实际工程中，我们更常用的是简化的 **TCP/IP 四层模型**：

| TCP/IP 层 | 对应 OSI 层 | 工程中的代表协议 | 排障工具 |
|-----------|------------|----------------|----------|
| 应用层 | 5-7 层 | HTTP、HTTPS、SSH、DNS | curl、dig、openssl |
| 传输层 | 4 层 | TCP、UDP | ss、nc、tcpdump |
| 网络层 | 3 层 | IP、ICMP | ping、traceroute、ip route |
| 链路层 | 1-2 层 | Ethernet、Wi-Fi | ip addr、tcpdump |

**理解分层的实用价值**：当你遇到问题，从底层往上排查——先确认网络层（能 ping 通吗？），再确认传输层（端口能连吗？），再确认应用层（HTTP 响应正常吗？）。每确认一层就缩小了问题范围，避免在错误的层次上浪费时间。

### 1.3 一次 HTTP 请求的完整旅程

当用户在浏览器输入 `https://api.example.com/users` 时，背后依次发生：

```
1. DNS 解析        api.example.com → 203.0.113.10
2. TCP 三次握手    建立与 203.0.113.10:443 的连接
3. TLS 握手        协商加密算法，验证服务器证书
4. HTTP 请求       发送 GET /users HTTP/1.1
5. 服务器处理      查询数据库，生成响应
6. HTTP 响应       返回 200 OK 和 JSON 数据
7. TCP 关闭        四次挥手断开连接
```

这 7 个步骤中，每一步都可能出问题。掌握每一步对应的排查工具，就能精确定位故障点。

---

## 2. IP 地址与子网：定位网络中的每一台机器

### 2.1 IPv4 地址

IPv4 地址是一个 32 位数字，通常写成四组十进制数，用点分隔，如 `192.168.1.100`。每组范围是 0~255。

**特殊 IP 地址**：

| 地址 | 用途 |
|------|------|
| `127.0.0.1` | 本机回环地址（loopback），请求不会离开本机 |
| `0.0.0.0` | 所有本地接口（服务监听时表示"监听所有网卡"） |
| `192.168.x.x` | 私有地址（家庭/企业内网） |
| `10.x.x.x` | 私有地址（企业内网） |
| `172.16.x.x ~ 172.31.x.x` | 私有地址 |
| `169.254.x.x` | 链路本地地址（DHCP 失败时自动分配） |

**私有地址不能在公网路由**——这解释了为什么你内网的 `192.168.1.100` 无法直接被互联网访问，必须通过 NAT 转换。

### 2.2 子网掩码与 CIDR

子网掩码（如 `255.255.255.0`）与 CIDR 前缀（如 `/24`）等价，都表示网络地址的位数。`/24` 表示前 24 位是网络地址，后 8 位是主机地址，即这个子网内有 2^8-2=254 个可用 IP。

```bash
# 查看本机 IP 和子网信息
ip addr show
# 输出示例：
# inet 192.168.1.100/24 brd 192.168.1.255 scope global eth0
#      ↑ 本机 IP    ↑ 子网前缀  ↑ 广播地址

# 计算子网信息（需要 ipcalc 工具）
ipcalc 192.168.1.0/24
# 输出：Network, Broadcast, HostMin, HostMax, Hosts 等详细信息
```

### 2.3 路由：数据包如何找到目的地

路由表决定了数据包的下一跳方向：

```bash
# 查看路由表
ip route
# 输出示例：
# default via 192.168.1.1 dev eth0   ← 默认路由（网关）
# 192.168.1.0/24 dev eth0 proto kernel  ← 本地子网直连

# 查看到达某个目标的路由
ip route get 8.8.8.8
# 输出：8.8.8.8 via 192.168.1.1 dev eth0 src 192.168.1.100
```

**默认网关**是本机不知道如何路由时的"兜底出口"，通常是路由器的 IP。如果默认网关配置错误或不可达，本机将无法访问外网。

---

## 3. DNS：域名到 IP 的翻译系统

### 3.1 DNS 的工作流程

DNS（Domain Name System）是互联网的"电话簿"，把人类可读的域名转换为机器使用的 IP 地址。理解 DNS 解析流程，是排查"域名访问异常"问题的前提。

一次 DNS 查询的完整流程：

```
用户输入 api.example.com
    ↓
1. 检查本地缓存（OS 缓存）
    ↓ 未命中
2. 查询本地 hosts 文件（/etc/hosts）
    ↓ 未找到
3. 查询本地 DNS 解析器（/etc/resolv.conf 中配置的 DNS 服务器）
    ↓ 未缓存
4. 递归查询：根域名服务器 → .com 顶级域名服务器 → example.com 权威服务器
    ↓
5. 返回 IP 地址，同时告知 TTL（缓存有效期）
    ↓
6. 本地缓存该结果（持续 TTL 秒）
```

### 3.2 关键配置文件

```bash
# /etc/hosts：本地静态解析（优先级高于 DNS）
cat /etc/hosts
# 127.0.0.1  localhost
# 192.168.1.50  dev.internal   ← 可以手动添加内网域名映射

# 添加本地解析（开发调试时非常有用）
echo "192.168.1.50  dev.internal" | sudo tee -a /etc/hosts

# /etc/resolv.conf：DNS 服务器配置
cat /etc/resolv.conf
# nameserver 8.8.8.8
# nameserver 8.8.4.4
# search example.com   ← 短域名会自动补全为 api.example.com

# 修改 DNS 服务器（Ubuntu 使用 systemd-resolved）
sudo nano /etc/systemd/resolved.conf
# [Resolve]
# DNS=8.8.8.8 1.1.1.1
sudo systemctl restart systemd-resolved
```

### 3.3 常见 DNS 记录类型

| 记录类型 | 含义 | 示例 |
|---------|------|------|
| **A** | 域名 → IPv4 地址 | `api.example.com → 203.0.113.10` |
| **AAAA** | 域名 → IPv6 地址 | `api.example.com → 2001:db8::1` |
| **CNAME** | 域名 → 另一个域名（别名） | `www.example.com → example.com` |
| **MX** | 邮件服务器地址 | `example.com MX mail.example.com` |
| **TXT** | 文本记录（验证、SPF 等） | `example.com TXT "v=spf1 ..."` |
| **NS** | 权威域名服务器 | `example.com NS ns1.example.com` |
| **PTR** | IP → 域名（反向解析） | `10.0.1.203.in-addr.arpa → api.example.com` |

---

## 4. TCP 与 UDP：两种传输方式的选择

### 4.1 TCP：可靠传输

TCP（Transmission Control Protocol）是面向连接的协议，提供可靠的、有序的、有错误校验的数据传输。HTTP、HTTPS、SSH、FTP 都基于 TCP。

**TCP 三次握手**（建立连接）：

```
客户端                    服务端
   |  ── SYN ──────────►  |   "我想建立连接"
   |  ◄─ SYN-ACK ───────  |   "好的，我也准备好了"
   |  ── ACK ──────────►  |   "确认，开始通信"
   |  ← 数据传输 →        |
```

**TCP 四次挥手**（关闭连接）：

```
客户端                    服务端
   |  ── FIN ──────────►  |   "我发完了"
   |  ◄─ ACK ───────────  |   "收到"
   |  ◄─ FIN ───────────  |   "我也发完了"
   |  ── ACK ──────────►  |   "收到，连接关闭"
```

TCP 的可靠性通过**重传机制**保证：发送方每发一个包，都等待接收方的确认（ACK）；超时未收到 ACK 就重传。这保证了数据不丢失，但也带来了延迟开销。

### 4.2 UDP：快速但不可靠

UDP（User Datagram Protocol）是无连接协议，发送方不等待确认，不重传，不保证顺序。UDP 用于对实时性要求高、容忍少量丢包的场景：

| 协议 | 传输层 | 原因 |
|------|--------|------|
| HTTP/HTTPS | TCP | 需要可靠性，不能丢数据 |
| SSH | TCP | 需要可靠性和顺序性 |
| DNS | UDP（主要） | 查询简单，速度优先 |
| 视频通话 | UDP | 实时性优先，丢帧可接受 |
| 在线游戏 | UDP | 低延迟优先 |
| QUIC (HTTP/3) | UDP | 自己实现可靠性，避免 TCP 缺陷 |

### 4.3 端口号的含义

端口号（0~65535）与 IP 地址一起定位具体的服务。IP 定位到机器，端口定位到机器上的服务。

**知名端口（0~1023，需要 root 才能监听）**：

| 端口 | 协议/服务 |
|------|---------|
| 22 | SSH |
| 25 | SMTP（邮件发送） |
| 53 | DNS |
| 80 | HTTP |
| 443 | HTTPS |
| 3306 | MySQL |
| 5432 | PostgreSQL |
| 6379 | Redis |
| 27017 | MongoDB |

---

## 5. HTTP 与 HTTPS：应用层的通信协议

### 5.1 HTTP 请求与响应结构

HTTP（HyperText Transfer Protocol）是 Web 通信的基础协议，采用请求-响应模式。

**HTTP 请求结构**：

```
POST /api/users HTTP/1.1           ← 请求行：方法 路径 版本
Host: api.example.com              ← 请求头
Content-Type: application/json
Authorization: Bearer eyJ...
Content-Length: 45

{"name": "Alice", "email": "a@x.com"}  ← 请求体
```

**HTTP 响应结构**：

```
HTTP/1.1 201 Created               ← 状态行：版本 状态码 状态文本
Content-Type: application/json    ← 响应头
Content-Length: 89
X-Request-Id: abc-123

{"id": 42, "name": "Alice", "email": "a@x.com"}  ← 响应体
```

### 5.2 HTTP 方法语义

| 方法 | 语义 | 幂等性 |
|------|------|--------|
| GET | 获取资源 | 是（多次调用结果相同） |
| POST | 创建资源 | 否 |
| PUT | 全量更新资源 | 是 |
| PATCH | 部分更新资源 | 否 |
| DELETE | 删除资源 | 是 |
| HEAD | 获取响应头（不含 body） | 是 |
| OPTIONS | 查询服务器支持的方法 | 是 |

### 5.3 HTTP 状态码全览

状态码是 HTTP 响应的"诊断码"，分为五大类：

```
1xx  信息性响应   100 Continue, 101 Switching Protocols
2xx  成功         200 OK, 201 Created, 204 No Content
3xx  重定向       301 永久重定向, 302 临时重定向, 304 Not Modified
4xx  客户端错误   400 Bad Request, 401 Unauthorized, 403 Forbidden,
                  404 Not Found, 429 Too Many Requests
5xx  服务端错误   500 Internal Server Error, 502 Bad Gateway,
                  503 Service Unavailable, 504 Gateway Timeout
```

工程中最需要重点关注的：

| 状态码 | 含义 | 常见原因 |
|--------|------|---------|
| **401** | 未认证 | Token 缺失或过期 |
| **403** | 无权限 | 权限不足，但认证是对的 |
| **404** | 未找到 | 路径错误，或资源已删除 |
| **429** | 请求过多 | 触发了限流规则 |
| **500** | 服务器内部错误 | 应用崩溃，看应用日志 |
| **502** | 网关收到了无效响应 | 上游服务崩溃或返回非 HTTP 数据 |
| **503** | 服务不可用 | 实例全部不健康，或正在维护 |
| **504** | 网关超时 | 上游服务响应太慢 |

---

## 6. TLS：加密通信与证书体系

### 6.1 为什么需要 TLS

HTTP 是明文协议，你发送的所有数据（包括密码、token、个人信息）都可以被网络中的任何中间节点读取。**TLS（Transport Layer Security）** 在 TCP 之上建立加密层，保证：

- **保密性**：数据加密，第三方无法读取
- **完整性**：数据不能被篡改
- **认证性**：确认你连接的是真正的服务器（而不是冒牌的）

HTTPS = HTTP over TLS，就是在 HTTP 下面加了一层 TLS 加密通道。

### 6.2 证书体系

TLS 的"认证性"通过数字证书实现。证书包含：

- 域名（Common Name / Subject Alternative Names）
- 公钥
- 颁发机构（CA，Certificate Authority）
- 有效期

浏览器和操作系统内置了一批受信任的 CA（如 Let's Encrypt、DigiCert、GlobalSign）。当你访问 HTTPS 网站时，浏览器验证服务器证书是否由受信任的 CA 签发，且域名与证书匹配，且证书未过期。

```
证书链（从下往上信任传递）：
  服务器证书 (*.example.com)
       ↑ 由
  中间 CA 证书 (Let's Encrypt R3)
       ↑ 由
  根 CA 证书 (ISRG Root X1)   ← 内置于操作系统/浏览器
```

**常见 TLS 问题**：

| 错误 | 原因 |
|------|------|
| `certificate has expired` | 证书过期，需要续签 |
| `certificate name mismatch` | 证书域名与访问域名不符 |
| `self-signed certificate` | 自签名证书，不受公共信任 |
| `certificate chain incomplete` | 中间证书缺失 |
| `TLS handshake timeout` | 网络问题或 TLS 配置过旧 |

---

# 本机网络配置篇

## 7. 查看与配置本机网络

### 7.1 查看网卡与 IP 地址

```bash
# 查看所有网卡和 IP 地址（推荐）
ip addr
ip addr show                      # 等价
ip addr show eth0                 # 只看指定网卡
ip -4 addr show                   # 只看 IPv4
ip -6 addr show                   # 只看 IPv6

# 输出解读示例：
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
#     inet 192.168.1.100/24 brd 192.168.1.255 scope global eth0
#     ↑ 本机 IP         ↑ 子网前缀  ↑ 广播地址

# 旧式命令（仍然常用）
ifconfig
ifconfig eth0
```

### 7.2 查看和配置路由

```bash
# 查看路由表
ip route
ip route show

# 查看到达某个 IP 的路由路径
ip route get 8.8.8.8

# 添加静态路由（临时，重启失效）
sudo ip route add 10.0.0.0/8 via 192.168.1.1

# 删除路由
sudo ip route del 10.0.0.0/8

# 查看默认网关
ip route | grep default
# 输出：default via 192.168.1.1 dev eth0
```

### 7.3 网络接口操作

```bash
# 启用/禁用网卡
sudo ip link set eth0 up
sudo ip link set eth0 down

# 查看网卡状态（包含速率、双工等物理信息）
ip link show eth0
ethtool eth0                      # 需要安装 ethtool

# 临时修改 IP 地址（重启后失效）
sudo ip addr add 192.168.1.200/24 dev eth0
sudo ip addr del 192.168.1.200/24 dev eth0

# 查看 ARP 缓存（IP → MAC 地址映射）
ip neigh
arp -n
```

### 7.4 永久网络配置

**Ubuntu（使用 Netplan，/etc/netplan/）**：

```yaml
# /etc/netplan/00-installer-config.yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false                    # 关闭 DHCP，使用静态 IP
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
```

```bash
# 应用配置
sudo netplan apply

# 测试配置（不实际应用）
sudo netplan try
```

**CentOS/RHEL（NetworkManager）**：

```bash
# 使用 nmcli 配置
nmcli con show                              # 查看所有连接
nmcli con show eth0                         # 查看 eth0 详情
nmcli con mod eth0 ipv4.addresses 192.168.1.100/24
nmcli con mod eth0 ipv4.gateway 192.168.1.1
nmcli con mod eth0 ipv4.dns "8.8.8.8 1.1.1.1"
nmcli con mod eth0 ipv4.method manual
nmcli con up eth0                           # 应用配置
```

---

## 8. 防火墙与端口管理

### 8.1 ufw（Ubuntu 常用）

`ufw`（Uncomplicated Firewall）是 Ubuntu 上最易用的防火墙管理工具：

```bash
# 查看防火墙状态和规则
sudo ufw status
sudo ufw status verbose          # 详细输出

# 启用/禁用防火墙
sudo ufw enable
sudo ufw disable

# 允许/拒绝端口
sudo ufw allow 22                # 允许 SSH（22/TCP）
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8080/tcp

# 允许特定 IP 访问指定端口（生产环境推荐！）
sudo ufw allow from 203.0.113.5 to any port 22
sudo ufw allow from 10.0.0.0/8 to any port 5432    # 只允许内网访问数据库

# 拒绝端口
sudo ufw deny 3306               # 拒绝 MySQL 端口（禁止外部访问）

# 删除规则
sudo ufw delete allow 8080
sudo ufw delete allow from 203.0.113.5 to any port 22

# 重置所有规则
sudo ufw reset
```

### 8.2 iptables（底层，更精细的控制）

```bash
# 查看当前规则
sudo iptables -L -n -v
sudo iptables -L INPUT -n -v --line-numbers  # 查看 INPUT 链规则及行号

# 允许已建立连接的数据包（通常是第一条规则）
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 允许 SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# 允许 HTTP 和 HTTPS
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# 拒绝其他所有入站流量（放在最后！）
sudo iptables -A INPUT -j DROP

# 删除规则（按行号）
sudo iptables -D INPUT 3

# 保存规则（使重启后生效）
sudo iptables-save > /etc/iptables/rules.v4
```

### 8.3 云服务商安全组

在云环境（AWS、阿里云、腾讯云）中，安全组是另一层防火墙，在流量到达虚拟机之前就进行过滤。许多"明明 ufw 放行了，外部还是访问不了"的问题，根源在于安全组规则没有更新。

云安全组的排查要点：
- 确认入站规则（Inbound Rules）包含了你需要的端口
- 注意协议类型（TCP/UDP/All）
- 注意来源 IP（`0.0.0.0/0` 表示所有，生产环境应限制来源）
- 安全组与 ufw 是叠加关系，两者都需要放行

---

# 诊断工具篇

## 9. 连通性诊断：ping、nc、telnet

### 9.1 ping：测试网络层连通性

`ping` 使用 ICMP 协议，测试目标主机是否可达以及往返延迟。注意：**ping 不通不等于服务不可用**，因为很多服务器出于安全考虑会屏蔽 ICMP。

```bash
# 基础测试（发送 4 个包）
ping -c 4 google.com
ping -c 4 8.8.8.8

# 输出解读：
# 64 bytes from 142.250.185.46: icmp_seq=1 ttl=115 time=8.32 ms
# ↑ 包大小                       ↑ 序列号  ↑ 存活时间  ↑ 往返延迟

# 持续发送（Ctrl+C 停止）
ping google.com

# 指定包间隔（秒）
ping -i 0.5 google.com           # 每 0.5 秒一个包

# 指定包大小（字节）
ping -s 1400 google.com          # 测试大包是否正常（MTU 相关）

# 指定超时时间
ping -W 2 google.com             # 等待响应最长 2 秒

# 快速评估丢包率（发 100 个包）
ping -c 100 google.com | tail -2
# 输出：100 packets transmitted, 99 received, 1% packet loss
```

**延迟参考值**：
- `< 5ms`：同机房或同城
- `5~30ms`：国内跨城市
- `30~100ms`：跨国
- `> 200ms`：延迟较高，可能影响用户体验
- 丢包 `> 1%`：网络质量有问题，需要排查

### 9.2 nc（netcat）：测试传输层连通性

`nc` 是"网络界的瑞士军刀"，可以测试 TCP/UDP 端口连通性、传输数据、甚至模拟简单服务。

```bash
# 测试 TCP 端口是否可达（-z 不发送数据，-v 详细输出）
nc -zv google.com 443
# 输出：Connection to google.com 443 port [tcp/https] succeeded!

nc -zv db.internal 5432
# 失败输出：nc: connect to db.internal port 5432 (tcp) failed: Connection refused
#   Connection refused  ← 端口在，但被拒绝（服务可能未启动或防火墙规则）
#   No route to host    ← 网络不通
#   Connection timed out ← 端口被防火墙静默丢弃（常见于云安全组）

# 指定超时时间（-w 3 表示等待 3 秒）
nc -zv -w 3 server.example.com 22

# 测试 UDP 端口
nc -zvu server.example.com 53

# 批量测试多个端口
for port in 22 80 443 8080; do
    nc -zv -w 2 server.example.com $port 2>&1
done

# 作为简单 HTTP 客户端（手动发送请求）
echo -e "GET / HTTP/1.0\r\nHost: example.com\r\n\r\n" | nc example.com 80
```

**连接失败的三种情况及其含义**：

| 错误信息 | 含义 | 排查方向 |
|---------|------|---------|
| `Connection refused` | 端口到达了，但被拒绝 | 服务是否启动？是否监听了该端口？ |
| `Connection timed out` | 数据包被静默丢弃 | 防火墙/安全组是否阻断？ |
| `No route to host` | 找不到路由，无法到达 | 网络路径问题，检查路由和网卡 |

### 9.3 telnet：简易 TCP 测试

`telnet` 是较老的工具，但在很多系统上默认可用，适合快速验证端口连通性：

```bash
# 测试 TCP 连通性
telnet server.example.com 22
telnet server.example.com 80

# 连接成功会显示：
# Trying 203.0.113.10...
# Connected to server.example.com.

# 连接失败会显示：
# Trying 203.0.113.10...
# telnet: Unable to connect to remote host: Connection refused
```

---

## 10. DNS 诊断：dig、nslookup、host

### 10.1 dig：功能最强的 DNS 诊断工具

`dig`（Domain Information Groper）是 DNS 排查的首选工具，输出详细且格式清晰。

```bash
# 基础 A 记录查询
dig api.example.com

# 输出解读：
# ;; QUESTION SECTION:
# ;api.example.com.        IN  A           ← 查询什么
#
# ;; ANSWER SECTION:
# api.example.com.  300  IN  A  203.0.113.10   ← 结果（300 是 TTL 秒数）
#
# ;; Query time: 23 msec                   ← 查询耗时
# ;; SERVER: 192.168.1.1#53                ← 使用的 DNS 服务器

# 只输出解析结果（+short 简洁模式）
dig api.example.com +short
# 输出：203.0.113.10

# 查询特定记录类型
dig api.example.com A            # IPv4 地址
dig api.example.com AAAA         # IPv6 地址
dig api.example.com CNAME        # 别名记录
dig api.example.com MX           # 邮件服务器
dig api.example.com TXT          # 文本记录
dig api.example.com NS           # 权威域名服务器
dig api.example.com SOA          # 起始授权记录

# 指定 DNS 服务器查询（@ 后面是 DNS 服务器地址）
dig @8.8.8.8 api.example.com        # 用 Google DNS
dig @1.1.1.1 api.example.com        # 用 Cloudflare DNS
dig @192.168.1.1 api.example.com    # 用本地路由器 DNS

# 比较本机 DNS 和公共 DNS 的结果差异（排查 DNS 劫持或缓存问题）
echo "=== 本机 DNS ===" && dig api.example.com +short
echo "=== Google DNS ===" && dig @8.8.8.8 api.example.com +short
echo "=== Cloudflare DNS ===" && dig @1.1.1.1 api.example.com +short

# 反向解析（IP → 域名）
dig -x 8.8.8.8 +short

# 查询整条解析链（追踪从根到权威服务器的完整过程）
dig api.example.com +trace

# 检查 TTL（决定缓存多久失效）
dig api.example.com | grep "ANSWER SECTION" -A 5
# 记录中的数字就是 TTL（秒）
```

### 10.2 nslookup：交互式 DNS 查询

```bash
# 基础查询
nslookup api.example.com
nslookup api.example.com 8.8.8.8   # 指定 DNS 服务器

# 交互模式
nslookup
> server 8.8.8.8          # 切换 DNS 服务器
> set type=MX             # 切换查询类型
> example.com
> exit
```

### 10.3 host：快速简洁的 DNS 查询

```bash
# 快速查看解析结果
host api.example.com
host -t MX example.com          # 查询 MX 记录
host -t NS example.com          # 查询 NS 记录
host 8.8.8.8                    # 反向解析
```

### 10.4 DNS 排查场景实战

**场景：访问域名失败，排查是否 DNS 问题**

```bash
# 第一步：确认本机能否解析
dig api.example.com +short
# 如果没有输出，说明解析失败

# 第二步：换公共 DNS 测试（排除本地 DNS 故障）
dig @8.8.8.8 api.example.com +short
# 如果公共 DNS 能解析而本机不能，说明本地 DNS 有问题

# 第三步：检查 /etc/hosts 是否有干扰
grep "api.example.com" /etc/hosts

# 第四步：检查 DNS 配置
cat /etc/resolv.conf

# 第五步：清除本地 DNS 缓存（Ubuntu）
sudo systemd-resolve --flush-caches
sudo systemd-resolve --statistics  # 查看缓存状态
```

---

## 11. HTTP 诊断：curl 的完整用法

`curl` 是 HTTP 排查最强大的命令行工具，从简单的连通性验证到精确的性能分析，几乎所有 HTTP 场景都能覆盖。

### 11.1 基础请求

```bash
# GET 请求（最简单）
curl https://api.example.com/health

# 只看响应头（不含 body）
curl -I https://api.example.com/health

# 查看完整请求和响应过程（含 TLS 握手）
curl -v https://api.example.com/health

# 跟随重定向（如 http 跳转到 https）
curl -L http://api.example.com/

# 保存响应到文件
curl -o response.json https://api.example.com/users
curl -O https://example.com/archive.tar.gz   # 使用服务器文件名
```

### 11.2 发送各种类型的请求

```bash
# POST 请求，JSON 数据
curl -X POST \
     -H "Content-Type: application/json" \
     -d '{"name": "Alice", "email": "alice@example.com"}' \
     https://api.example.com/users

# POST 请求，表单数据
curl -X POST \
     -d "username=alice&password=secret" \
     https://api.example.com/login

# PUT 请求
curl -X PUT \
     -H "Content-Type: application/json" \
     -d '{"name": "Alice Updated"}' \
     https://api.example.com/users/42

# DELETE 请求
curl -X DELETE https://api.example.com/users/42

# 携带 Authorization Header（Bearer Token）
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..." \
     https://api.example.com/profile

# 从文件读取请求体
curl -X POST \
     -H "Content-Type: application/json" \
     -d @request.json \
     https://api.example.com/users

# 文件上传（multipart）
curl -X POST \
     -F "file=@/path/to/photo.jpg" \
     -F "description=Profile photo" \
     https://api.example.com/upload
```

### 11.3 诊断性参数

```bash
# 只看 HTTP 状态码（最快速的健康检查）
curl -s -o /dev/null -w "%{http_code}\n" https://api.example.com/health

# 静默模式，只看响应体（去掉进度条）
curl -s https://api.example.com/health | jq .

# 设置超时（防止 curl 一直等）
curl --connect-timeout 5 \      # TCP 连接超时 5 秒
     --max-time 30 \            # 整个请求最长 30 秒
     https://api.example.com/heavy-endpoint

# 忽略 TLS 证书错误（仅用于测试！不要在生产脚本中使用）
curl -k https://self-signed.example.com/

# 指定 DNS 解析结果（绕过 DNS，直接用指定 IP）
curl --resolve api.example.com:443:203.0.113.10 \
     https://api.example.com/health
# 用于在 DNS 未更新时测试新服务器

# 指定 Host 头（测试反向代理后端）
curl -H "Host: api.example.com" http://203.0.113.10/health

# 查看 Cookie
curl -c cookies.txt https://api.example.com/login   # 保存 Cookie
curl -b cookies.txt https://api.example.com/profile  # 携带 Cookie
```

### 11.4 精确耗时分析（最实用！）

这是 curl 最有价值的诊断功能，把一次 HTTP 请求的各阶段耗时拆开展示：

```bash
curl -s -o /dev/null \
  -w "DNS解析:    %{time_namelookup}s\n\
TCP连接:    %{time_connect}s\n\
TLS握手:    %{time_appconnect}s\n\
首字节时间: %{time_starttransfer}s\n\
总耗时:     %{time_total}s\n\
状态码:     %{http_code}\n\
下载大小:   %{size_download} bytes\n" \
  https://api.example.com/health
```

输出示例：
```
DNS解析:    0.023s
TCP连接:    0.045s
TLS握手:    0.098s
首字节时间: 0.234s
总耗时:     0.241s
状态码:     200
下载大小:   1234 bytes
```

各指标的诊断含义：

| 指标 | 计算方式 | 偏高时排查方向 |
|------|---------|--------------|
| `time_namelookup` | DNS 解析耗时 | DNS 服务器响应慢，或缓存未命中 |
| `time_connect - time_namelookup` | TCP 握手耗时 | 网络延迟高，或端口拥堵 |
| `time_appconnect - time_connect` | TLS 握手耗时 | 证书链过长，或 TLS 配置问题 |
| `time_starttransfer - time_appconnect` | 服务器处理时间 | 应用逻辑慢，数据库慢查询 |
| `time_total - time_starttransfer` | 响应体传输时间 | 响应体过大，或带宽不足 |

---

## 12. 路由追踪：traceroute 与 mtr

### 12.1 traceroute：查看数据包的路由路径

`traceroute` 通过发送 TTL 逐渐递增的数据包，让路径上每一跳的路由器"暴露"自己的 IP 和延迟。

```bash
# 基础追踪
traceroute google.com
traceroute 8.8.8.8

# 输出解读：
# 1  192.168.1.1 (192.168.1.1)  1.234 ms   ← 本地网关（1 跳）
# 2  10.0.0.1    (10.0.0.1)     5.678 ms   ← ISP 入口
# 3  * * *                                  ← 该跳路由器不响应（正常）
# 4  142.250.185.46 (lga...net)  8.901 ms   ← Google 边缘节点

# 使用 TCP 而不是 ICMP（穿透更多防火墙）
traceroute -T -p 80 google.com        # TCP 到 80 端口
traceroute -T -p 443 api.example.com  # TCP 到 443 端口，更贴近真实访问

# 设置最大跳数（默认 30）
traceroute -m 15 google.com

# 不做反向 DNS 解析（更快）
traceroute -n google.com
```

**解读技巧**：
- `* * *` 不代表丢包，很多路由器不响应 ICMP TTL 超时报文
- 在某一跳突然延迟增大，且之后延迟持续高：该跳可能是瓶颈
- 最后一跳延迟与 ping 延迟接近：路径正常

### 12.2 mtr：实时持续路由追踪

`mtr`（My Traceroute）是 traceroute 的增强版，持续发包并实时计算每跳的丢包率和延迟统计，适合观察抖动和间歇性问题。

```bash
# 安装
sudo apt install mtr

# 实时交互模式
mtr google.com
# 界面说明：
# Loss%  ← 丢包率（正常应为 0%）
# Snt    ← 发送包数
# Last   ← 最后一次延迟
# Avg    ← 平均延迟
# Best   ← 最低延迟
# Wrst   ← 最高延迟
# StDev  ← 延迟标准差（越小越稳定）

# 报告模式（发 100 个包，输出统计报告）
mtr -rw google.com
mtr -rw --no-dns google.com  # 不解析 DNS，更快

# 使用 TCP（穿透防火墙）
mtr -T -P 443 api.example.com

# 保存报告到文件
mtr -rw google.com > /tmp/mtr-report.txt
```

---

## 13. 端口与连接状态：ss 与 lsof

### 13.1 ss：查看套接字状态

`ss`（Socket Statistics）是 `netstat` 的现代替代品，速度更快，信息更丰富。

```bash
# 查看所有监听端口（最常用）
ss -tlnp
# 参数：-t TCP  -l 监听  -n 不解析名称  -p 显示进程

# 包含 UDP
ss -tulnp

# 查看所有连接（包括已建立的）
ss -tanp

# 过滤特定端口
ss -tlnp | grep :80
ss -tlnp | grep :443
ss -anp | grep :8080

# 过滤特定进程
ss -anp | grep nginx
ss -anp | grep ESTABLISHED | grep :5432   # 谁在连接数据库

# 统计连接状态分布
ss -s
# 输出：
# Total: 234
# TCP:   78 (estab 45, closed 10, orphaned 2, timewait 21)

# 查看 TIME_WAIT 连接数量（过多说明短连接频繁，可能需要调优）
ss -anp | grep TIME_WAIT | wc -l

# 等效的旧命令（很多系统仍然可用）
netstat -tlnp
netstat -anp | grep :8080
```

### 13.2 lsof：查看进程打开的文件和网络连接

```bash
# 查看谁在占用某个端口
lsof -i :8080
lsof -i :80

# 输出示例：
# COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
# nginx    1234 root   6u  IPv4  12345      0t0  TCP *:80 (LISTEN)
# nginx    1235 www   7u  IPv4  12346      0t0  TCP *:80 (LISTEN)

# 查看某个进程打开的所有文件和连接
lsof -p 1234

# 查看某个用户的所有打开文件
lsof -u nginx

# 查看所有 TCP 连接
lsof -i tcp

# 查看某个文件被哪些进程使用
lsof /var/log/nginx/access.log

# 查找已删除但仍被占用的文件（磁盘空间没有释放的原因）
lsof | grep deleted
```

---

## 14. 抓包分析：tcpdump 与 Wireshark

### 14.1 tcpdump：命令行抓包

`tcpdump` 在网卡层面捕获原始数据包，是深度网络排障的核心工具。使用前需要明确目标，否则在高流量环境中会被数据淹没。

```bash
# 基础：抓取所有流量（Ctrl+C 停止）
sudo tcpdump

# 指定网卡
sudo tcpdump -i eth0
sudo tcpdump -i any            # 所有网卡

# 过滤主机
sudo tcpdump host api.example.com
sudo tcpdump src host 203.0.113.10       # 只看来自该 IP 的包
sudo tcpdump dst host 203.0.113.10       # 只看发往该 IP 的包

# 过滤端口
sudo tcpdump port 443
sudo tcpdump port 80 or port 443
sudo tcpdump tcp port 8080

# 组合过滤（and/or/not）
sudo tcpdump host api.example.com and port 443
sudo tcpdump not port 22        # 排除 SSH 流量（避免递归抓包）

# 显示详细内容（-v/-vv/-vvv 递增详细程度）
sudo tcpdump -v host api.example.com and port 443

# 显示包内容（-X 十六进制和 ASCII，-A 只 ASCII）
sudo tcpdump -A port 80 host api.example.com

# 保存到 pcap 文件（后续用 Wireshark 分析）
sudo tcpdump -i eth0 host api.example.com and port 443 -w /tmp/capture.pcap

# 限制包数量
sudo tcpdump -c 100 port 443   # 只抓 100 个包

# 读取 pcap 文件
tcpdump -r /tmp/capture.pcap

# 实际排障示例：确认请求是否到达服务器
sudo tcpdump -i eth0 tcp port 8080 -n
# 如果看到 SYN 但没有 SYN-ACK，说明应用没有监听该端口
# 如果连 SYN 都看不到，说明包被防火墙拦截了
```

**tcpdump 过滤语法速查**：

| 过滤表达式 | 含义 |
|-----------|------|
| `host x.x.x.x` | 来自或发往该 IP |
| `port 443` | 使用该端口 |
| `tcp` / `udp` | 协议类型 |
| `net 10.0.0.0/8` | 某个子网 |
| `src host x` | 只看来源 |
| `dst port 80` | 只看目标端口 |
| `tcp[tcpflags] & tcp-syn != 0` | 只看 SYN 包 |

### 14.2 Wireshark：图形化包分析

Wireshark 是最强大的图形化网络分析工具，适合对 `tcpdump` 保存的 pcap 文件进行深度分析。

```bash
# 安装 Wireshark
sudo apt install wireshark

# 在服务器上用 tcpdump 抓包，传到本机用 Wireshark 分析
sudo tcpdump -i eth0 host api.example.com -w /tmp/capture.pcap
scp server:/tmp/capture.pcap ./
wireshark capture.pcap    # 本机打开
```

Wireshark 关键使用技巧：
- **过滤表达式**：`http`、`tcp.port == 443`、`ip.addr == 10.0.0.1`
- **追踪 TCP 流**：右键某个包 → Follow → TCP Stream，查看完整对话
- **统计功能**：Statistics → Endpoints（各 IP 流量）、Conversations（各连接流量）
- **专家信息**：Analyze → Expert Information，自动标出重传、乱序、RST 等异常

---

## 15. TLS 证书诊断：openssl

### 15.1 检查服务器证书

```bash
# 连接服务器并查看证书信息（最常用）
openssl s_client -connect api.example.com:443

# 如果是多域名共用一个 IP（SNI 场景），必须指定域名
openssl s_client -connect api.example.com:443 -servername api.example.com

# 输出解读关键段落：
# Certificate chain
#  0 s:CN = api.example.com                  ← 服务器证书
#    i:C = US, O = Let's Encrypt, CN = R3    ← 颁发机构
#  1 s:C = US, O = Let's Encrypt, CN = R3    ← 中间 CA
#    i:C = US, O = Internet Security...      ← 根 CA
#
# SSL-Session:
#     Protocol  : TLSv1.3                    ← TLS 版本
#     Cipher    : TLS_AES_256_GCM_SHA384     ← 加密套件
#
# Verify return code: 0 (ok)                 ← 证书链验证通过

# 只查看证书有效期（快速检查是否过期）
echo | openssl s_client -connect api.example.com:443 -servername api.example.com 2>/dev/null \
  | openssl x509 -noout -dates
# 输出：
# notBefore=Jan  1 00:00:00 2026 GMT
# notAfter=Apr  1 00:00:00 2026 GMT   ← 到期日期

# 查看证书域名（Subject Alternative Names）
echo | openssl s_client -connect api.example.com:443 -servername api.example.com 2>/dev/null \
  | openssl x509 -noout -text | grep -A1 "Subject Alternative"

# 计算证书剩余天数
echo | openssl s_client -connect api.example.com:443 -servername api.example.com 2>/dev/null \
  | openssl x509 -noout -checkend 0 && echo "证书有效" || echo "证书已过期"

# 检查证书还有多少天过期（-checkend N：N 秒内是否过期）
echo | openssl s_client -connect api.example.com:443 2>/dev/null \
  | openssl x509 -noout -checkend 2592000 \
  || echo "警告：证书将在 30 天内过期！"
```

### 15.2 检查本地证书文件

```bash
# 查看证书基本信息
openssl x509 -in /etc/ssl/certs/server.crt -noout -text

# 只看有效期
openssl x509 -in /etc/ssl/certs/server.crt -noout -dates

# 只看域名
openssl x509 -in /etc/ssl/certs/server.crt -noout -subject

# 验证私钥和证书是否匹配（模数必须相同）
openssl rsa -in server.key -noout -modulus | md5sum
openssl x509 -in server.crt -noout -modulus | md5sum
# 两行输出的 MD5 必须相同，否则密钥和证书不匹配

# 验证证书链
openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt server.crt
```

---

# 故障排查篇

## 16. 系统化排障：分层定位方法论

### 16.1 黄金排障流程

网络排障最常见的误区是"抓到一个报错就急忙改配置"。这种方式容易治标不治本，甚至引入新问题。正确的方法是**系统化分层排查**：

```
层次 1：名称解析    →  域名能解析到 IP 吗？
   ↓ 通过
层次 2：网络连通    →  IP 和端口能到达吗？
   ↓ 通过
层次 3：协议行为    →  HTTP 响应是否正常？TLS 证书是否有效？
   ↓ 通过
层次 4：服务日志    →  应用层是否有错误？
   ↓ 通过
层次 5：路由链路    →  中间经过的网络节点是否有问题？
   ↓ 通过
层次 6：抓包验证    →  实际数据包是否与预期一致？
```

每一层确认通过，就把问题范围缩小一层。**不要跳层**——在不确认网络连通的情况下就去看应用日志，往往会在错误的方向上浪费大量时间。

### 16.2 标准排障检查脚本

下面这个脚本综合了四层检查，可以作为服务健康巡检的基础：

```bash
#!/bin/bash
# network_check.sh - 四层网络健康检查

TARGET="api.example.com"
PORT=443

echo "========== 网络健康检查：$TARGET =========="
echo "时间：$(date)"
echo ""

# 第一层：DNS 解析
echo "--- 第一层：DNS 解析 ---"
IP=$(dig +short "$TARGET" | head -1)
if [ -z "$IP" ]; then
    echo "❌ DNS 解析失败：无法解析 $TARGET"
    exit 1
fi
echo "✅ 解析成功：$TARGET → $IP"
echo ""

# 第二层：TCP 连通
echo "--- 第二层：TCP 连通 ---"
if nc -zv -w 3 "$TARGET" "$PORT" 2>&1 | grep -q succeeded; then
    echo "✅ 端口可达：$TARGET:$PORT"
else
    echo "❌ 端口不可达：$TARGET:$PORT"
    exit 1
fi
echo ""

# 第三层：HTTP 响应
echo "--- 第三层：HTTP 响应 ---"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    --connect-timeout 5 --max-time 10 \
    "https://$TARGET/health")
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ HTTP 响应正常：$HTTP_CODE"
else
    echo "⚠️  HTTP 响应异常：$HTTP_CODE"
fi
echo ""

# 第四层：耗时分析
echo "--- 第四层：耗时分析 ---"
curl -s -o /dev/null \
  -w "  DNS:   %{time_namelookup}s\n  TCP:   %{time_connect}s\n  TLS:   %{time_appconnect}s\n  TTFB:  %{time_starttransfer}s\n  Total: %{time_total}s\n" \
  "https://$TARGET/health"

# 第五层：证书有效期
echo ""
echo "--- 第五层：TLS 证书 ---"
EXPIRY=$(echo | openssl s_client -connect "$TARGET:$PORT" -servername "$TARGET" 2>/dev/null \
    | openssl x509 -noout -dates 2>/dev/null | grep notAfter | cut -d= -f2)
echo "  证书到期：$EXPIRY"

echo ""
echo "========== 检查完成 =========="
```

---

## 17. 慢请求分析：耗时拆分与根因定位

### 17.1 不要把"慢"直接归因于网络

工程中一个常见的误判是：接口慢 → 网络慢。实际上，一次 HTTP 请求的耗时由多个阶段构成，每个阶段可能是瓶颈：

```
用户感知总耗时 = DNS解析 + TCP握手 + TLS握手 + 服务器处理 + 响应传输
```

服务器处理时间（`time_starttransfer - time_appconnect`）往往是最大的变量，而它完全与网络无关，是应用层或数据库层的问题。

### 17.2 逐步缩小慢的范围

```bash
# 第一步：用 curl 拆分各阶段耗时
curl -s -o /dev/null \
  -w "dns=%{time_namelookup} tcp=%{time_connect} tls=%{time_appconnect} ttfb=%{time_starttransfer} total=%{time_total}\n" \
  https://api.example.com/users

# 输出示例：
# dns=0.025 tcp=0.048 tls=0.095 ttfb=2.340 total=2.345

# 分析：TTFB（首字节时间）从 tls 完成到收到第一个字节花了 2.24 秒
# 这段时间是服务器处理时间，与网络无关，要看后端日志和数据库

# 第二步：确认是否偶发还是持续
for i in $(seq 1 5); do
    curl -s -o /dev/null \
      -w "$(date +%T) total=%{time_total} code=%{http_code}\n" \
      https://api.example.com/users
    sleep 1
done

# 第三步：与直连后端比较（绕过 CDN/反向代理）
# 如果直连后端快，反向代理慢：问题在代理层
curl --resolve api.example.com:443:203.0.113.10 \
     https://api.example.com/users
```

### 17.3 常见慢请求根因与判断依据

| 现象 | `time_namelookup` 偏高 | 根因 | 解决方向 |
|------|----------------------|------|---------|
| DNS 慢 | `> 0.1s` | DNS 服务器慢或缓存失效 | 换 DNS，检查 TTL |
| 建连慢 | `time_connect` 偏高 | 网络延迟高或丢包 | traceroute 检查路径 |
| TLS 慢 | `time_appconnect` 偏高 | 证书链长，OCSP 响应慢 | 优化证书链，开启 OCSP Stapling |
| 处理慢 | `ttfb - tls` 偏高 | 应用处理慢，数据库慢查询 | 看应用日志，APM 追踪 |
| 传输慢 | `total - ttfb` 偏高 | 响应体大或带宽不足 | 开启 gzip 压缩，CDN 加速 |

---

## 18. 常见错误状态码的排查思路

### 18.1 502 Bad Gateway

**含义**：反向代理（如 Nginx）成功收到了请求，但从后端服务获取响应时失败。

**排查步骤**：

```bash
# 第一步：确认后端服务是否在运行
systemctl status myapp
ps -ef | grep myapp

# 第二步：确认后端服务在监听预期端口
ss -tlnp | grep :8080    # 8080 是后端端口

# 第三步：检查 Nginx 配置的 proxy_pass 地址是否正确
grep -r "proxy_pass" /etc/nginx/

# 第四步：在代理服务器上直接测试后端连通性
curl -v http://127.0.0.1:8080/health

# 第五步：查看 Nginx 错误日志（最直接）
tail -50 /var/log/nginx/error.log
journalctl -u nginx -n 100 --no-pager
```

### 18.2 504 Gateway Timeout

**含义**：反向代理等待后端响应超过了配置的超时时间。

```bash
# 第一步：直接测试后端响应时间
time curl -v http://127.0.0.1:8080/slow-endpoint

# 第二步：检查 Nginx 超时配置
grep -r "proxy_read_timeout\|proxy_connect_timeout" /etc/nginx/

# 第三步：查看后端日志，是否有慢操作
tail -100 /var/log/myapp/app.log | grep -E "slow|timeout|error"

# 第四步：检查数据库是否有慢查询
# MySQL
SELECT * FROM information_schema.PROCESSLIST WHERE TIME > 10;
# PostgreSQL
SELECT pid, now() - query_start AS duration, query
FROM pg_stat_activity
WHERE state != 'idle' ORDER BY duration DESC;
```

### 18.3 连接超时 vs 连接拒绝

```bash
# 测试连接行为
nc -zv -w 5 api.example.com 443

# Connection refused（立刻返回）
# → 端口到达了服务器，但没有服务在监听
# → 排查：服务是否启动？监听地址是否正确？

# Connection timed out（等待后超时）
# → 数据包被防火墙静默丢弃，从未到达服务器
# → 排查：云安全组规则？iptables 规则？网络路径？

# 验证监听地址
ss -tlnp | grep 443
# 如果看到 127.0.0.1:443 而不是 0.0.0.0:443
# 说明服务只监听本机回环，外部无法访问
```

---

## 19. 命令速查总表

### DNS 诊断

| 命令 | 说明 |
|------|------|
| `dig api.example.com +short` | 快速查看解析结果 |
| `dig api.example.com A` | 查询 A 记录 |
| `dig @8.8.8.8 api.example.com` | 用 Google DNS 查询 |
| `dig api.example.com +trace` | 追踪完整解析链路 |
| `dig -x 8.8.8.8 +short` | 反向解析 IP |
| `nslookup api.example.com` | 简易 DNS 查询 |
| `host -t MX example.com` | 查询 MX 记录 |

### 连通性测试

| 命令 | 说明 |
|------|------|
| `ping -c 4 host` | 测试 ICMP 连通性 |
| `ping -c 100 host \| tail -2` | 统计丢包率 |
| `nc -zv host 443` | 测试 TCP 端口 |
| `nc -zv -w 3 host 5432` | 带超时的端口测试 |
| `telnet host 80` | 简易 TCP 测试 |

### HTTP 诊断

| 命令 | 说明 |
|------|------|
| `curl -I URL` | 只看响应头 |
| `curl -v URL` | 详细请求过程 |
| `curl -L URL` | 跟随重定向 |
| `curl -s -o /dev/null -w "%{http_code}" URL` | 只看状态码 |
| `curl --connect-timeout 5 --max-time 30 URL` | 设置超时 |
| `curl -H "Authorization: Bearer TOKEN" URL` | 携带认证头 |
| `curl -X POST -d @body.json URL` | POST 请求 |
| `curl -w "dns=%{time_namelookup} total=%{time_total}\n" URL` | 耗时分析 |

### 路由与追踪

| 命令 | 说明 |
|------|------|
| `ip addr` | 查看 IP 地址 |
| `ip route` | 查看路由表 |
| `ip route get 8.8.8.8` | 查看到目标的路由 |
| `traceroute google.com` | 路径跳点追踪 |
| `traceroute -T -p 443 host` | TCP 追踪（穿透防火墙） |
| `mtr -rw google.com` | 持续路由追踪报告 |

### 端口与连接

| 命令 | 说明 |
|------|------|
| `ss -tlnp` | 查看 TCP 监听端口及进程 |
| `ss -tulnp` | 包含 UDP |
| `ss -anp \| grep :8080` | 过滤特定端口 |
| `ss -s` | 连接状态统计 |
| `lsof -i :8080` | 查看占用端口的进程 |
| `lsof -p PID` | 查看进程打开的所有文件 |

### 抓包

| 命令 | 说明 |
|------|------|
| `sudo tcpdump -i eth0 host x.x.x.x` | 按主机过滤 |
| `sudo tcpdump port 443` | 按端口过滤 |
| `sudo tcpdump host x and port 443` | 组合过滤 |
| `sudo tcpdump -w /tmp/capture.pcap` | 保存到文件 |
| `tcpdump -r capture.pcap` | 读取 pcap 文件 |
| `sudo tcpdump -n not port 22` | 排除 SSH 流量 |

### TLS 证书

| 命令 | 说明 |
|------|------|
| `openssl s_client -connect host:443 -servername host` | 查看证书详情 |
| `openssl x509 -noout -dates -in cert.crt` | 查看证书有效期 |
| `openssl x509 -noout -subject -in cert.crt` | 查看证书域名 |
| `openssl x509 -noout -checkend 2592000 -in cert.crt` | 检查 30 天内是否过期 |

### 防火墙

| 命令 | 说明 |
|------|------|
| `sudo ufw status verbose` | 查看 ufw 规则 |
| `sudo ufw allow 443/tcp` | 允许 443 端口 |
| `sudo ufw allow from 10.0.0.0/8 to any port 5432` | 限制来源 IP |
| `sudo iptables -L -n -v` | 查看 iptables 规则 |

---

## 20. 延伸阅读

### 协议标准

- [**MDN HTTP 文档**](https://developer.mozilla.org/zh-CN/docs/Web/HTTP)：HTTP 协议各方面的详细中文解释，包括状态码、请求方法、Header 说明，非常适合查阅
- [**IETF RFC Index**](https://www.ietf.org/process/rfcs/)：所有网络协议的权威标准文档（TCP RFC 793、TLS RFC 8446、HTTP/2 RFC 7540 等）

### 工具文档

- [**curl 官方文档**](https://curl.se/docs/)：curl 所有参数的完整说明，含大量使用示例
- [**OpenSSL 文档**](https://www.openssl.org/docs/)：TLS 证书操作和 s_client 工具的完整参考
- [**Wireshark 用户手册**](https://www.wireshark.org/docs/wsug_html/)：从安装到高级过滤的完整指南
- [**tcpdump 过滤语法**](https://www.tcpdump.org/manpages/pcap-filter.7.html)：pcap 过滤表达式完整手册

### 深入学习

- [**《计算机网络：自顶向下方法》**](https://book.douban.com/subject/36081529/)：系统学习计算机网络最推荐的教材，从应用层到物理层逐层讲解
- [**High Performance Browser Networking**](https://hpbn.co/)（中文版：《Web 性能权威指南》）：深入讲解 TCP、TLS、HTTP/2、QUIC 等协议的性能特性，免费在线阅读
- [**The Illustrated TLS 1.3 Connection**](https://tls13.xargs.org/)：用可视化方式逐字节解析 TLS 1.3 握手过程，理解 TLS 原理的最佳资料

---

*本文档持续维护更新。如有错误或建议，欢迎提交 Issue 或 PR。*