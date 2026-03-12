---
title: Linux 基础与运维完整指南
summary: 从文件系统、权限、进程、服务到日志诊断，建立 Linux 一线运维与开发必备能力
level: beginner
prerequisites: ["具备基础终端使用能力"]
updated_at: 2026-03-13
---

# Linux 基础与运维完整指南

![Linux 运行与排障模型示意图](assets/diagrams/linux-flow.svg)

Linux 是大多数后端服务、容器平台与 CI 环境的底层运行系统。你在 Shell、Git、Docker 里学到的很多命令，最终都落在 Linux 的文件系统、权限模型和进程管理机制上。要真正做到“会用命令”，必须理解命令背后的系统语义：文件为什么有权限位、进程为什么会被信号终止、服务为什么重启后仍失败、日志为什么要按时间窗口分析。这些问题一旦打通，你的排错效率会出现质变。

从路径开始是最稳妥的学习顺序。Linux 的目录结构并不是随意命名，而是约定明确：`/etc` 放配置，`/var/log` 放日志，`/usr/bin` 放可执行程序，`/home` 放用户数据，`/tmp` 放临时文件。你不需要死记所有目录，但要知道“去哪里找什么”。例如服务启动失败，优先看 `/etc` 配置和 `/var/log` 日志，而不是盲目重装软件。

```bash
pwd
ls -alh /
ls -alh /etc
ls -alh /var/log | head
```

权限模型是 Linux 学习中最容易被简化、却最影响生产稳定性的部分。`rwx` 三组权限分别作用于属主、属组、其他用户。`chmod 755` 常用于可执行脚本或目录，`644` 常用于普通配置文件。这里的关键不是数字本身，而是“谁在执行、谁在访问”。你在容器、CI、服务器上遇到的 `Permission denied`，绝大多数都与身份和权限不匹配有关。

```bash
ls -l
chmod 755 deploy.sh
chmod 644 app.conf
chown -R appuser:appgroup /opt/app
```

此外，`umask` 影响新建文件默认权限。若你发现团队成员创建的文件权限不一致，可以检查 `umask`：

```bash
umask
umask 022
```

进程管理是 Linux 运维的日常核心。每个服务本质上都是进程，崩溃、卡死、内存泄漏都会以进程状态体现。常用命令是 `ps`、`top`、`ss`、`lsof`。例如你怀疑某端口被占用：

```bash
ss -tulpen | grep 8080
lsof -i :8080
```

`ss` 关注套接字层，`lsof` 关注文件与进程关系，两者结合能快速定位“谁占了端口”。结束进程时，优先 `kill -15`，仅在无响应时用 `kill -9`。这不是形式主义，而是为了给应用释放资源和写入日志的机会。

服务管理在 systemd 体系下非常统一。你可以把 `systemctl` 理解为服务生命周期控制台：启动、停止、重启、开机自启、状态检查都在这里完成。最常用组合如下：

```bash
systemctl status nginx
systemctl restart nginx
systemctl enable nginx
systemctl is-active nginx
```

当服务重启后仍失败，不要只盯着 `status` 的简短输出，应该直接查看日志窗口：

```bash
journalctl -u nginx -n 200 --no-pager
journalctl -u nginx -f
```

`-n` 限制最近行数，`-f` 持续跟踪，`--no-pager` 便于在脚本或 CI 中直接输出。日志分析建议固定“三步法”：先看报错时间点，再看前后 30 秒上下文，再看关联依赖是否也在同一时间异常。

包管理是系统可维护性的基础。Debian/Ubuntu 常用 `apt`，CentOS/RHEL 常用 `yum` 或 `dnf`。在生产环境中，建议“先查版本再升级”，避免一次升级引入不可预测兼容问题：

```bash
apt list --installed | grep nginx
apt-cache policy nginx
sudo apt update
sudo apt install nginx
```

磁盘与内存是最常见的资源瓶颈。`df -h` 看分区容量，`du -sh *` 看目录占用，`free -h` 看内存，`top`/`htop` 看实时负载。遇到 `no space left on device`，先定位大文件与日志增长点，不要直接删除系统目录。日志清理应结合轮转策略（logrotate）和保留周期。

```bash
df -h
du -sh /var/log/* | sort -h | tail
free -h
uptime
```

用户与权限治理方面，建议避免业务长期使用 root 运行。通过 `sudo` 提升权限可审计、可追踪、可回收。你可以为运维组配置最小必要命令授权，而不是直接共享 root 密码。对多用户服务器来说，这是安全底线。

文件编辑与配置变更时，推荐使用“先备份后替换”的节奏。任何关键配置改动前先留快照：

```bash
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak-$(date +%F-%H%M%S)
```

配置修改后尽量先做语法检查再重载服务。例如 Nginx：

```bash
nginx -t
systemctl reload nginx
```

这能避免“配置错误导致服务中断”的事故。

Linux 排障效率的提升，关键在于把“经验”沉淀成固定排查顺序。你可以统一采用：症状确认 -> 资源检查 -> 进程检查 -> 网络检查 -> 日志定位 -> 变更回溯。只要顺序稳定，面对陌生问题也不会慌。下面是一组通用体检命令，可作为故障初筛模板：

```bash
date
hostname
uptime
free -h
df -h
ps -ef | head -n 20
ss -tulpen | head -n 20
journalctl -p err -n 100 --no-pager
```

这些输出足以帮助你快速判断是资源问题、服务问题还是网络问题，然后再深入到具体组件。

当你把 Linux 看成“稳定运行系统”的工程平台，而不是“命令集合”，学习会顺畅很多。每条命令都对应一个系统层面的责任：权限保护、进程控制、资源分配、日志追踪。你把责任边界理解清楚，命令自然就用得稳。

## 常用命令与参数清单（可直接查阅）

### 文件与权限

- `ls -alh`：查看详细文件信息。
- `stat file`：查看 inode、权限、时间戳。
- `chmod 755 file`：修改权限。
- `chown user:group file`：修改属主属组。
- `find /path -type f -mtime +7`：查找超过 7 天的文件。

### 进程与服务

- `ps -ef`：列出全部进程。
- `top`：实时进程监控。
- `kill -15 pid`：优雅终止进程。
- `systemctl status service`：服务状态。
- `systemctl restart service`：重启服务。
- `journalctl -u service -f`：跟踪服务日志。

### 资源与系统状态

- `df -h`：磁盘分区容量。
- `du -sh *`：目录体积。
- `free -h`：内存使用。
- `uptime`：负载与运行时长。
- `vmstat 1 5`：采样系统资源变化。

### 网络与端口

- `ss -tulpen`：监听端口与进程映射。
- `ip addr`：网卡地址信息。
- `ip route`：路由信息。
- `ping -c 4 host`：连通性测试。
- `curl -I https://host`：HTTP 头检查。

## 延伸阅读

- [Linux man-pages](https://man7.org/linux/man-pages/)
- [systemd 文档](https://www.freedesktop.org/software/systemd/man/)
- [The Linux Documentation Project](https://tldp.org/)
- [Nginx 运维文档](https://nginx.org/en/docs/)
