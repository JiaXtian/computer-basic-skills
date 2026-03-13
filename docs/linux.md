# Linux 基础与 Shell 完整指南

> **适用人群**：计算机系新生、转行入门者、需要系统掌握 Linux 操作与 Shell 脚本能力的开发者和运维人员  
> **前置要求**：具备基础终端使用能力，能打开终端并执行简单命令  
> **最后更新**：2026-03-13

---

## 目录

**Linux 基础篇**
1. [Linux 是什么，为什么要学它](#1-linux-是什么为什么要学它)
2. [目录结构：Linux 的文件系统布局](#2-目录结构linux-的文件系统布局)
3. [文件操作：增删改查与导航](#3-文件操作增删改查与导航)
4. [权限模型：读懂并控制文件访问](#4-权限模型读懂并控制文件访问)
5. [用户与用户组管理](#5-用户与用户组管理)
6. [进程管理：查看、控制与诊断](#6-进程管理查看控制与诊断)
7. [服务管理：systemd 与 systemctl](#7-服务管理systemd-与-systemctl)
8. [软件包管理：安装与维护软件](#8-软件包管理安装与维护软件)
9. [磁盘与内存：资源监控与诊断](#9-磁盘与内存资源监控与诊断)
10. [网络基础：查看状态与连通性测试](#10-网络基础查看状态与连通性测试)
11. [日志系统：用 journalctl 和日志文件排错](#11-日志系统用-journalctl-和日志文件排错)

**Shell 编程篇**
12. [Shell 是什么：命令行的运行环境](#12-shell-是什么命令行的运行环境)
13. [变量、引号与字符串操作](#13-变量引号与字符串操作)
14. [输入输出重定向与管道](#14-输入输出重定向与管道)
15. [条件判断与流程控制](#15-条件判断与流程控制)
16. [循环：批量处理的利器](#16-循环批量处理的利器)
17. [函数与脚本结构](#17-函数与脚本结构)
18. [文本处理三件套：grep、sed、awk](#18-文本处理三件套grepsedawk)
19. [Shell 脚本实战：从零写一个部署脚本](#19-shell-脚本实战从零写一个部署脚本)
20. [命令速查总表](#20-命令速查总表)
21. [延伸阅读](#21-延伸阅读)

---

# Linux 基础篇

## 1. Linux 是什么，为什么要学它

### 1.1 Linux 无处不在

如果你开发后端服务、使用 Docker 容器、维护云服务器，或者将来从事任何与服务器打交道的工作，你几乎肯定会在 Linux 上运行代码。全球超过 96% 的 Web 服务器运行 Linux，几乎所有云计算基础设施（AWS、阿里云、腾讯云）的底层都是 Linux，Android 手机的内核也是 Linux。

Linux 不是一个操作系统，而是一类操作系统的统称——它们都基于 Linus Torvalds 于 1991 年发布的 Linux 内核。常见的发行版包括：

| 发行版 | 主要用途 | 包管理工具 |
|--------|----------|-----------|
| **Ubuntu** | 开发者、云服务器（最主流） | `apt` |
| **Debian** | 稳定服务器环境 | `apt` |
| **CentOS / RHEL** | 企业级服务器 | `yum` / `dnf` |
| **Fedora** | 开发者桌面，新技术试验场 | `dnf` |
| **Alpine** | Docker 容器（极致精简） | `apk` |
| **Arch Linux** | 高度自定义，偏好高级用户 | `pacman` |

本文以 Ubuntu/Debian 系为主要示例，但核心概念和大多数命令在所有 Linux 发行版上通用。

### 1.2 Linux 的核心思想：一切皆文件

Linux 设计哲学中最重要的一条是"一切皆文件"：普通文档是文件，目录是文件，设备（硬盘、键盘、网卡）是文件，进程信息是文件，甚至网络连接也可以用文件描述符表示。这个统一的抽象让所有工具都能通过相同的方式（读写文件）与系统交互，也是 Linux 命令组合能力强大的根本原因。

### 1.3 为什么命令行比图形界面更重要

在服务器环境中，通常没有图形界面（GUI），只有命令行（CLI）。命令行有几个图形界面无法替代的优势：

- **可脚本化**：命令可以组合、自动化、重复执行，GUI 操作很难自动化
- **资源效率**：命令行几乎不占用额外资源，图形界面要消耗大量 CPU 和内存
- **远程操作**：通过 SSH 连接远程服务器时，只有命令行可用
- **精确性**：命令行操作明确、可审计，GUI 操作容易误点

---

## 2. 目录结构：Linux 的文件系统布局

### 2.1 根目录与路径

Linux 只有一棵目录树，根目录是 `/`（正斜杠），所有文件和目录都挂载在这棵树上。路径分为两种：

- **绝对路径**：从根目录开始，如 `/etc/nginx/nginx.conf`
- **相对路径**：从当前目录开始，如 `./config/app.yaml` 或 `../logs/app.log`

特殊路径符号：
- `.`：当前目录
- `..`：上一级目录
- `~`：当前用户的 Home 目录（通常是 `/home/username`）
- `-`：上一个工作目录（`cd -` 回到上一个位置，非常实用）

### 2.2 重要目录及其用途

```
/
├── etc/          ← 系统和应用的配置文件（nginx、ssh、hosts 等）
├── var/
│   ├── log/      ← 系统和应用日志文件
│   ├── lib/      ← 应用运行时的持久化数据
│   └── www/      ← Web 服务器文件（惯例）
├── usr/
│   ├── bin/      ← 用户可执行程序（ls、grep、curl 等）
│   ├── sbin/     ← 系统管理员程序（需要 sudo）
│   └── local/    ← 本地安装的软件（非包管理器安装）
├── bin/          ← 基础系统命令（实际上通常链接到 /usr/bin）
├── sbin/         ← 系统管理命令
├── home/
│   └── username/ ← 各用户的家目录
├── root/         ← root 用户的家目录（独立于 /home）
├── tmp/          ← 临时文件（重启后清空）
├── proc/         ← 进程信息（虚拟文件系统，运行时动态生成）
├── sys/          ← 系统硬件信息（虚拟文件系统）
├── dev/          ← 设备文件（磁盘、终端等）
├── mnt/          ← 临时挂载点
└── opt/          ← 第三方大型软件（不通过包管理器安装时）
```

记住规律："去哪里找什么"：

- 服务启动失败 → 先查 `/etc/<服务名>/` 配置，再查 `/var/log/<服务名>/` 日志
- 命令找不到 → 通常在 `/usr/bin/` 或 `/usr/local/bin/`
- 临时测试文件 → 放 `/tmp/`，不用担心清理

### 2.3 导航命令

```bash
# 显示当前所在路径
pwd

# 切换目录
cd /etc/nginx          # 切换到绝对路径
cd ../                 # 上一级
cd ~                   # 回到 Home 目录
cd -                   # 回到上一个工作目录（反复执行可在两个目录间切换）

# 列出目录内容
ls                     # 基础列表
ls -l                  # 详细信息（权限、大小、时间等）
ls -a                  # 包含隐藏文件（以 . 开头的文件）
ls -lh                 # 详细信息 + 人类可读的文件大小
ls -alh                # 以上全部
ls -lt                 # 按修改时间排序（最新的在前）
ls -lS                 # 按文件大小排序

# 查看目录树结构（需要安装 tree）
tree /etc/nginx
tree -L 2 /var/log     # 只显示 2 层深度
```

---

## 3. 文件操作：增删改查与导航

### 3.1 查看文件内容

```bash
# 查看整个文件内容
cat /etc/hostname
cat /etc/hosts

# 分页查看（空格翻页，q 退出）
less /var/log/syslog
more /etc/nginx/nginx.conf

# 查看文件开头/结尾
head -n 20 /var/log/syslog        # 前 20 行
tail -n 50 /var/log/nginx/access.log  # 最后 50 行
tail -f /var/log/nginx/access.log     # 实时追踪（跟踪新增内容，Ctrl+C 退出）
tail -f -n 100 /var/log/app.log       # 从最后 100 行开始实时追踪

# 查看文件详细元信息（权限、inode、时间戳等）
stat /etc/passwd
```

### 3.2 创建与编辑文件

```bash
# 创建空文件（或更新时间戳）
touch newfile.txt
touch -t 202601010000 oldfile.txt   # 设置指定时间戳

# 快速写入内容（> 覆盖，>> 追加）
echo "Hello, Linux" > hello.txt
echo "Second line" >> hello.txt
echo "" >> hello.txt               # 追加空行

# 用 nano 编辑（新手友好，底部有快捷键提示）
nano /etc/hosts
# Ctrl+O 保存，Ctrl+X 退出，Ctrl+W 搜索

# 用 vim 编辑（功能强大，学习曲线较陡）
vim /etc/nginx/nginx.conf
# i 进入插入模式，Esc 返回命令模式
# :w 保存，:q 退出，:wq 保存并退出，:q! 强制退出不保存
# /keyword 搜索，n 下一个，N 上一个

# 在文件末尾追加多行内容（heredoc 语法）
cat >> /etc/profile.d/custom.sh << 'EOF'
export MY_APP_HOME=/opt/myapp
export PATH=$PATH:$MY_APP_HOME/bin
EOF
```

### 3.3 复制、移动与删除

```bash
# 复制文件
cp source.txt destination.txt
cp -r /source/dir/ /destination/dir/   # 递归复制目录
cp -a /source/ /backup/                # 保留权限和时间戳的归档复制

# 移动文件或重命名
mv oldname.txt newname.txt             # 重命名
mv /tmp/file.txt /var/www/html/        # 移动

# 删除文件（无法撤销！操作前三思）
rm file.txt
rm -r directory/                       # 递归删除目录
rm -rf /path/to/dir/                   # 强制递归删除（高危命令！）
rmdir emptydir/                        # 只能删除空目录

# 关于 rm -rf 的警告
# 永远不要执行 rm -rf / 或 rm -rf /*（会删除整个系统）
# 删除前用 ls 先确认路径，养成习惯
```

### 3.4 创建目录与链接

```bash
# 创建目录
mkdir newdir
mkdir -p /opt/app/config/env           # 递归创建多级目录（父目录不存在时自动创建）

# 创建软链接（类似 Windows 的快捷方式）
ln -s /opt/app/current /opt/app/latest
# 访问 /opt/app/latest 实际上访问的是 /opt/app/current

# 查看链接指向
ls -l /opt/app/latest
# lrwxrwxrwx 1 root root  /opt/app/latest -> /opt/app/current

# 创建硬链接（两个文件名指向同一个 inode）
ln /original/file.txt /another/path/file.txt
```

### 3.5 搜索文件

```bash
# find：在目录树中按条件搜索
find /var/log -name "*.log"                     # 按名称搜索
find /etc -name "nginx.conf" -type f            # 只找文件（不包括目录）
find /home -user alice                          # 找属于 alice 的文件
find /tmp -mtime +7                             # 找超过 7 天未修改的文件
find /opt -size +100M                           # 找大于 100MB 的文件
find /var/log -name "*.log" -mtime +30 -delete  # 查找并删除 30 天前的日志

# locate：基于数据库快速搜索（需要 mlocate 包）
locate nginx.conf
updatedb                                         # 更新数据库（sudo）

# which：找命令在哪里
which nginx
which python3

# whereis：找命令、源码、手册
whereis nginx
```

---

## 4. 权限模型：读懂并控制文件访问

### 4.1 权限的意义

Linux 权限是生产环境稳定性的关键保障之一。理解权限能帮你：

- 排查 `Permission denied` 错误（最常见的 Linux 报错之一）
- 保护敏感文件（如密钥、配置文件）不被未授权读取
- 控制服务进程能访问哪些资源
- 在 Docker、CI 环境中正确配置容器权限

### 4.2 权限位的读法

执行 `ls -l` 时，每一行开头的字符串就是权限位：

```
-rwxr-xr--  1  alice  developers  4096  Mar 13 10:00  deploy.sh
│└──┴──┴──  │    │        │         │        │           │
│ 属主 属组 │  属主    属组      大小     修改时间     文件名
│  其他用户 └── 链接数
└── 文件类型（- 普通文件，d 目录，l 软链接，c 字符设备）
```

权限位的三组含义：

| 字符位置 | 作用于 | r（读） | w（写） | x（执行） |
|----------|--------|---------|---------|-----------|
| 2-4 位 | 属主（Owner） | 能读取文件内容 | 能修改文件 | 能执行文件 |
| 5-7 位 | 属组（Group） | 同上 | 同上 | 同上 |
| 8-10 位 | 其他人（Others） | 同上 | 同上 | 同上 |

对于**目录**来说，权限含义稍有不同：
- `r`：能列出目录内容（`ls`）
- `w`：能在目录中创建、删除、重命名文件
- `x`：能进入目录（`cd`）以及访问目录内的文件

### 4.3 数字表示法

权限也可以用三位八进制数字表示：`r=4`、`w=2`、`x=1`，三个权限加起来：

| 数字 | 权限 | 含义 |
|------|------|------|
| `7` | `rwx` | 读+写+执行 |
| `6` | `rw-` | 读+写 |
| `5` | `r-x` | 读+执行 |
| `4` | `r--` | 只读 |
| `0` | `---` | 无权限 |

常用权限组合：

```bash
chmod 755 script.sh     # 属主全权，其他人只读+执行（可执行脚本）
chmod 644 config.conf   # 属主读写，其他人只读（配置文件）
chmod 600 id_rsa        # 只有属主可读写（SSH 私钥）
chmod 700 ~/.ssh        # 只有属主可进入（SSH 目录）
chmod 777 /tmp/shared   # 所有人全权（临时共享目录，不建议生产使用）
```

### 4.4 修改权限与归属

```bash
# 修改文件权限
chmod 755 deploy.sh
chmod +x deploy.sh              # 给所有人加执行权限
chmod u+x,g-w deploy.sh        # 给属主加执行，去掉属组写权限
chmod -R 755 /opt/app/          # 递归修改目录下所有文件

# 修改属主和属组
chown alice deploy.sh
chown alice:developers deploy.sh
chown -R appuser:appgroup /opt/app/  # 递归修改整个目录

# 只修改属组
chgrp developers /opt/app/logs/
```

### 4.5 umask：新文件的默认权限

`umask` 是一个掩码，决定新建文件和目录的默认权限。系统默认 `umask 022`：

- 新建文件默认权限：`666 - 022 = 644`（`rw-r--r--`）
- 新建目录默认权限：`777 - 022 = 755`（`rwxr-xr-x`）

```bash
# 查看当前 umask
umask
# 输出：0022

# 临时修改（仅当前会话有效）
umask 027    # 新建文件为 640，目录为 750（更严格的团队环境）

# 永久修改：写入 ~/.bashrc 或 /etc/profile
echo "umask 027" >> ~/.bashrc
```

### 4.6 特殊权限：sudo 与 su

```bash
# sudo：以 root 权限执行单条命令（推荐方式，可审计）
sudo apt update
sudo systemctl restart nginx
sudo -u www-data ls /var/www    # 以指定用户身份执行

# su：切换用户身份（需要目标用户密码）
su alice                        # 切换到 alice 用户
su -                            # 切换到 root（需要 root 密码）
su - alice                      # 切换到 alice 并加载其环境变量

# 查看当前用户有哪些 sudo 权限
sudo -l
```

---

## 5. 用户与用户组管理

### 5.1 用户管理

```bash
# 查看当前用户
whoami
id                        # 显示用户ID、组ID等详细信息
id alice                  # 查看指定用户的信息

# 创建用户
sudo useradd alice                           # 基础创建
sudo useradd -m -s /bin/bash alice          # 创建家目录，指定 Shell
sudo useradd -m -s /bin/bash -G sudo alice  # 同时加入 sudo 组

# 设置密码
sudo passwd alice

# 修改用户信息
sudo usermod -s /bin/zsh alice       # 修改 Shell
sudo usermod -aG docker alice        # 追加到 docker 组（-a 不会删除已有组）
sudo usermod -l newname alice        # 重命名用户

# 删除用户
sudo userdel alice             # 只删除用户，保留家目录
sudo userdel -r alice          # 删除用户及其家目录和邮件

# 查看所有用户
cat /etc/passwd
# 格式：用户名:密码:UID:GID:描述:家目录:Shell
```

### 5.2 用户组管理

```bash
# 查看用户所属的组
groups
groups alice

# 创建用户组
sudo groupadd developers

# 将用户加入组
sudo usermod -aG developers alice

# 注意：修改组成员后，需要重新登录（或执行 newgrp）才能生效
newgrp developers   # 在当前会话中激活新组

# 删除用户组
sudo groupdel developers

# 查看所有用户组
cat /etc/group
```

### 5.3 sudo 权限配置

sudo 的权限配置在 `/etc/sudoers` 文件（必须用 `visudo` 编辑，它会检查语法）：

```bash
sudo visudo

# /etc/sudoers 常用配置示例：
# alice ALL=(ALL:ALL) ALL             # alice 可以执行所有 sudo 命令
# %developers ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx
#   ↑ developers 组可以无密码重启 nginx

# 推荐：在 /etc/sudoers.d/ 目录下创建独立文件
sudo tee /etc/sudoers.d/developers << 'EOF'
%developers ALL=(ALL) NOPASSWD: /bin/systemctl restart app
%developers ALL=(ALL) NOPASSWD: /usr/bin/docker
EOF
sudo chmod 440 /etc/sudoers.d/developers
```

---

## 6. 进程管理：查看、控制与诊断

### 6.1 什么是进程

每个运行中的程序都是一个进程，有唯一的进程 ID（PID）。Linux 的所有进程构成一棵树，起点是 PID 1（系统初始化进程，现代 Linux 通常是 systemd）。理解进程管理是排查服务异常、分析性能问题的基础。

### 6.2 查看进程

```bash
# ps：进程快照
ps                            # 只看当前终端的进程
ps -e                         # 所有进程
ps -ef                        # 全格式（UID、PID、PPID、命令等）
ps -ef | grep nginx           # 过滤特定进程
ps -aux                       # BSD 风格，带 CPU/内存占用

# 输出字段含义：
# UID   PID  PPID  C  STIME  TTY  TIME  CMD
# 用户  进程ID 父进程ID  CPU  启动时间  终端  CPU时间  命令

# pgrep：按名称查找 PID
pgrep nginx                   # 返回所有 nginx 进程的 PID
pgrep -l nginx                # 同时显示进程名

# top：实时进程监控（默认 3 秒刷新）
top
# 常用交互键：
# q 退出  k 终止进程（输入 PID）  1 切换单核/多核显示
# P 按 CPU 排序  M 按内存排序  u 过滤用户

# htop：更友好的 top（需要安装）
sudo apt install htop
htop

# pstree：以树形显示进程关系
pstree
pstree -p              # 显示 PID
pstree -u              # 显示用户
```

### 6.3 发送信号与终止进程

Linux 通过"信号（Signal）"控制进程行为：

```bash
# kill：向进程发送信号
kill 1234              # 默认发送 SIGTERM（15），请求进程优雅退出
kill -15 1234          # 明确发送 SIGTERM（让程序有机会清理资源）
kill -9 1234           # 发送 SIGKILL，强制立即终止（进程无法捕获）
kill -HUP 1234         # 发送 SIGHUP，通常用于让服务重新读取配置

# killall：按进程名终止
killall nginx          # 终止所有 nginx 进程
killall -9 python3     # 强制终止所有 python3 进程

# pkill：按名称或条件终止
pkill -u alice         # 终止 alice 用户的所有进程
pkill -f "python app.py"  # 按完整命令行匹配

# 为什么优先用 SIGTERM 而不是 SIGKILL？
# SIGTERM 允许程序捕获信号，执行清理：关闭数据库连接、写入日志、完成当前请求
# SIGKILL 直接由内核终止，程序没有机会处理，可能导致数据损坏或日志不完整
```

常用信号列表：

| 信号 | 编号 | 含义 |
|------|------|------|
| SIGTERM | 15 | 请求优雅退出（默认） |
| SIGKILL | 9 | 强制立即终止 |
| SIGHUP | 1 | 挂起/重新加载配置 |
| SIGINT | 2 | 键盘中断（Ctrl+C） |
| SIGSTOP | 19 | 暂停进程（Ctrl+Z） |
| SIGCONT | 18 | 恢复暂停的进程 |

### 6.4 后台运行与任务管理

```bash
# 在后台运行命令（& 放末尾）
python3 server.py &
# 输出：[1] 12345   ← [任务编号] PID

# 查看后台任务
jobs

# 将后台任务移到前台
fg %1              # %1 是任务编号

# 将前台任务切到后台（先 Ctrl+Z 暂停，再 bg）
# 运行中按 Ctrl+Z 暂停
bg %1              # 在后台继续运行

# nohup：即使关闭终端也继续运行
nohup python3 server.py > /var/log/server.log 2>&1 &
# 输出重定向到日志文件，& 放后台

# 查看特定进程的详细信息
ls -l /proc/12345/        # 进程虚拟目录
cat /proc/12345/status    # 进程状态信息
cat /proc/12345/environ   # 进程环境变量
```

---

## 7. 服务管理：systemd 与 systemctl

### 7.1 什么是 systemd

systemd 是现代 Linux（Ubuntu 16+、CentOS 7+）的初始化系统和服务管理器。它统一管理所有系统服务的启动、停止、依赖和日志。在 systemd 出现之前，每个发行版有自己的服务管理方式（SysVinit、Upstart 等），造成了大量混乱。`systemctl` 是与 systemd 交互的核心命令。

### 7.2 基础服务操作

```bash
# 查看服务状态（最常用，第一时间看这个）
systemctl status nginx
# 输出包含：服务状态、进程PID、最近日志

# 启动 / 停止 / 重启服务
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx     # 停止后重新启动（会短暂中断）
sudo systemctl reload nginx      # 重新加载配置，不中断服务（nginx支持热重载）

# 开机自启设置
sudo systemctl enable nginx      # 设置开机自启
sudo systemctl disable nginx     # 取消开机自启
sudo systemctl enable --now nginx  # 设置开机自启并立即启动（组合操作）

# 快速判断状态
systemctl is-active nginx        # 输出 active 或 inactive
systemctl is-enabled nginx       # 输出 enabled 或 disabled
systemctl is-failed nginx        # 输出 failed 或其他
```

### 7.3 查看和管理多个服务

```bash
# 列出所有正在运行的服务
systemctl list-units --type=service --state=running

# 列出所有服务（包括未运行的）
systemctl list-units --type=service --all

# 列出所有失败的服务（故障排查入口）
systemctl list-units --state=failed

# 查看服务的依赖关系
systemctl list-dependencies nginx
```

### 7.4 编写自定义 Systemd 服务

当你需要让自己的应用以服务方式运行时，创建一个 Service Unit 文件：

```bash
# 创建服务配置文件
sudo nano /etc/systemd/system/myapp.service
```

文件内容示例：

```ini
[Unit]
Description=My Application Server
After=network.target        # 在网络就绪后启动
Requires=postgresql.service # 依赖 PostgreSQL（可选）

[Service]
Type=simple
User=appuser                # 以指定用户运行（不要用 root）
Group=appgroup
WorkingDirectory=/opt/myapp
EnvironmentFile=/opt/myapp/.env   # 从文件加载环境变量
ExecStart=/usr/bin/node /opt/myapp/server.js
ExecReload=/bin/kill -HUP $MAINPID
Restart=always              # 崩溃后自动重启
RestartSec=5                # 重启前等待 5 秒
StandardOutput=journal      # 输出到 systemd journal
StandardError=journal

[Install]
WantedBy=multi-user.target  # 在多用户模式下启用
```

```bash
# 加载新服务配置
sudo systemctl daemon-reload

# 启动并设置开机自启
sudo systemctl enable --now myapp

# 查看状态
systemctl status myapp
```

---

## 8. 软件包管理：安装与维护软件

### 8.1 apt（Debian/Ubuntu）

```bash
# 更新软件包索引（安装前必须先更新）
sudo apt update

# 升级所有已安装的软件包
sudo apt upgrade
sudo apt full-upgrade           # 更积极的升级（可能删除冲突包）

# 安装软件包
sudo apt install nginx
sudo apt install nginx curl git  # 一次安装多个

# 安装指定版本
sudo apt install nginx=1.18.0-6ubuntu14

# 查看可用版本
apt-cache policy nginx

# 删除软件包
sudo apt remove nginx              # 删除但保留配置文件
sudo apt purge nginx               # 彻底删除（含配置文件）
sudo apt autoremove                # 删除不再需要的依赖

# 搜索软件包
apt search "web server"
apt-cache search nginx

# 查看软件包信息
apt show nginx
apt list --installed               # 列出所有已安装包
apt list --installed | grep nginx  # 查找特定包
```

### 8.2 dnf / yum（CentOS/RHEL/Fedora）

```bash
# 更新
sudo dnf update
sudo yum update                    # 旧版 CentOS

# 安装
sudo dnf install nginx
sudo yum install nginx

# 删除
sudo dnf remove nginx

# 搜索
dnf search nginx

# 查看信息
dnf info nginx

# 列出已安装
dnf list installed
```

### 8.3 生产环境包管理原则

```bash
# 原则一：先查版本，再升级
apt-cache policy nginx             # 查看当前版本和可用版本

# 原则二：安装前先测试在非生产环境
# 生产升级应在测试/预发布环境验证后进行

# 原则三：记录变更
# 把软件版本和安装时间记录在变更日志里

# 原则四：关键配置先备份
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak-$(date +%F-%H%M%S)
sudo apt upgrade nginx

# 查看某个命令属于哪个软件包
dpkg -S /usr/bin/nginx             # 反查命令来自哪个包
which nginx | xargs dpkg -S        # 结合 which 使用
```

---

## 9. 磁盘与内存：资源监控与诊断

### 9.1 磁盘空间

```bash
# 查看所有挂载分区的使用情况
df -h
# 输出示例：
# Filesystem  Size  Used  Avail  Use%  Mounted on
# /dev/sda1   50G   18G    29G   38%   /

# 查看 inode 使用情况（有时磁盘空间足够但 inode 用完了）
df -i

# 查看当前目录下各子目录的磁盘占用
du -sh *
du -sh /var/log/*       # 查看日志目录各文件大小
du -sh /* 2>/dev/null   # 查看根目录各文件夹大小

# 找出磁盘占用最大的文件/目录
du -sh /var/log/* | sort -h | tail -10    # 找最大的 10 个
find / -size +500M -type f 2>/dev/null    # 找大于 500MB 的文件

# 常见"磁盘满了"排查流程
df -h                       # 定位哪个分区满了
du -sh /var/log/* | sort -h  # 找哪个日志文件最大
du -sh /opt/* | sort -h     # 找哪个应用目录最大
```

### 9.2 内存使用

```bash
# 查看内存使用概况
free -h
# 输出示例：
#               total   used   free   shared  buff/cache  available
# Mem:           7.7G   3.2G   1.1G     245M        3.4G       4.0G
# Swap:          2.0G     0B   2.0G
# available 列才是真正可用的内存（包括可回收的缓存）

# 实时监控内存（每 2 秒刷新）
watch -n 2 free -h

# 查看详细内存信息
cat /proc/meminfo

# 清理文件系统缓存（仅在确实需要时使用）
sudo sync && sudo echo 3 > /proc/sys/vm/drop_caches
```

### 9.3 系统整体负载

```bash
# 查看系统负载和运行时间
uptime
# 输出：10:30:00 up 15 days, 2:30, 2 users, load average: 0.52, 0.45, 0.40
# load average 三个数字：1分钟、5分钟、15分钟的平均负载
# 负载值接近或超过 CPU 核心数时，系统处于高负载状态

# 查看 CPU 核心数
nproc
cat /proc/cpuinfo | grep "model name" | head -1

# vmstat：综合系统资源监控（每 1 秒采样，共 5 次）
vmstat 1 5
# 关注列：r（运行队列）、b（阻塞进程）、si/so（swap）、wa（IO等待）

# iostat：磁盘 IO 监控
iostat -x 1 5

# sar：历史性能数据（需要 sysstat 包）
sudo apt install sysstat
sar -u 1 5    # CPU 使用率
sar -r 1 5    # 内存使用
sar -d 1 5    # 磁盘 IO
```

---

## 10. 网络基础：查看状态与连通性测试

### 10.1 查看网络配置

```bash
# 查看网卡和 IP 地址
ip addr
ip addr show eth0     # 只看特定网卡

# 查看路由表
ip route
ip route show         # 同上

# 查看 DNS 配置
cat /etc/resolv.conf

# 查看主机名
hostname
hostname -f           # 完全限定域名（FQDN）
```

### 10.2 端口与连接状态

```bash
# ss：查看套接字状态（取代旧的 netstat）
ss -tulpen
# 参数：-t TCP  -u UDP  -l 监听  -p 进程  -e 扩展  -n 不解析名称

ss -tlnp              # 查看所有 TCP 监听端口及对应进程
ss -tlnp | grep :80   # 检查 80 端口是否被监听
ss -anp | grep nginx  # 查看 nginx 的所有连接

# 等效的 netstat 命令（较旧的系统）
netstat -tulpen
netstat -tlnp | grep :80

# lsof：查看进程打开的文件和网络连接
lsof -i :8080           # 谁在监听 8080 端口
lsof -i tcp             # 所有 TCP 连接
lsof -p 1234            # 进程 1234 打开的所有文件
lsof -u alice           # alice 用户打开的文件
```

### 10.3 连通性测试

```bash
# ping：测试网络连通性
ping -c 4 google.com         # 发 4 个包
ping -c 4 -i 0.2 8.8.8.8    # 间隔 0.2 秒

# traceroute：追踪网络路径（每一跳的延迟）
traceroute google.com
mtr google.com               # 更强的路由追踪（实时刷新）

# curl：测试 HTTP/HTTPS 接口
curl https://example.com
curl -I https://example.com  # 只看响应头
curl -v https://example.com  # 详细输出（含请求/响应头）
curl -o /dev/null -w "%{http_code}\n" https://example.com  # 只看状态码
curl -X POST -H "Content-Type: application/json" \
     -d '{"key":"value"}' \
     https://api.example.com/endpoint

# wget：下载文件
wget https://example.com/file.zip
wget -O custom-name.zip https://example.com/file.zip
wget -q --spider https://example.com  # 检查 URL 是否可访问（不下载）

# nc（netcat）：测试 TCP 端口是否可达
nc -zv server.example.com 22
nc -zv server.example.com 80
nc -zv -w 3 server.example.com 5432  # 3 秒超时

# dig / nslookup：DNS 查询
dig google.com
dig +short google.com         # 只显示 IP
nslookup google.com
```

---

## 11. 日志系统：用 journalctl 和日志文件排错

### 11.1 journalctl：systemd 日志管理

```bash
# 查看所有系统日志（按时间倒序）
journalctl

# 查看特定服务的日志
journalctl -u nginx
journalctl -u nginx -n 100 --no-pager   # 最近 100 行，不分页

# 实时追踪日志（类似 tail -f）
journalctl -u nginx -f

# 按时间范围过滤
journalctl -u nginx --since "2026-03-13 10:00:00"
journalctl -u nginx --since "1 hour ago"
journalctl -u nginx --since "2026-03-13 10:00" --until "2026-03-13 10:10"

# 只看错误级别以上的日志
journalctl -p err
journalctl -p err -n 100 --no-pager      # 最近 100 条错误
journalctl -u nginx -p err -n 50         # nginx 的最近 50 条错误

# 查看本次启动以来的日志
journalctl -b
journalctl -b -1     # 上次启动的日志

# 日志占用磁盘查看与清理
journalctl --disk-usage
sudo journalctl --vacuum-size=500M      # 清理到只保留 500MB
sudo journalctl --vacuum-time=7d        # 清理 7 天前的日志
```

### 11.2 传统日志文件

```bash
# 常见日志文件位置
/var/log/syslog          # 系统日志（Ubuntu/Debian）
/var/log/messages        # 系统日志（CentOS/RHEL）
/var/log/auth.log        # 认证和授权日志（登录记录）
/var/log/kern.log        # 内核日志
/var/log/nginx/access.log  # Nginx 访问日志
/var/log/nginx/error.log   # Nginx 错误日志
/var/log/mysql/error.log   # MySQL 错误日志

# 实时追踪多个日志文件
tail -f /var/log/nginx/access.log /var/log/nginx/error.log

# 搜索日志中的关键词
grep "ERROR" /var/log/app.log
grep -i "error\|fatal\|critical" /var/log/syslog
grep "Mar 13" /var/log/nginx/error.log | grep "upstream"

# 统计错误出现次数
grep "ERROR" /var/log/app.log | wc -l

# 查看最近登录记录
last                     # 所有登录记录
lastb                    # 失败的登录尝试（需要 root）
lastlog                  # 每个用户的最后登录时间
```

### 11.3 日志排查三步法

遇到服务异常，建议按以下顺序排查：

```bash
# 第一步：确认错误出现的时间点
journalctl -u myapp --since "2026-03-13 09:55" --until "2026-03-13 10:05"

# 第二步：查看前后 30 秒的上下文，是否有依赖服务同时异常
journalctl --since "2026-03-13 09:58" --until "2026-03-13 10:02" -p err

# 第三步：检查同一时间点的系统资源状态
# （是否有磁盘满、内存耗尽等资源类问题）
sar -u -r -d -s 09:55:00 -e 10:05:00 2>/dev/null || echo "需要安装 sysstat"
```

---

# Shell 编程篇

## 12. Shell 是什么：命令行的运行环境

### 12.1 Shell 的角色

Shell 是用户与操作系统内核之间的接口，负责解释你输入的命令并传递给内核执行。你每次打开终端，实际上是运行了一个 Shell 程序。常见的 Shell 有：

| Shell | 说明 |
|-------|------|
| **bash** | Bourne Again Shell，Linux 默认，最广泛使用 |
| **zsh** | macOS 现默认，功能更丰富，插件生态好（Oh My Zsh）|
| **sh** | 最基础的 POSIX Shell，脚本兼容性最好 |
| **fish** | 用户友好，开箱即用的自动补全 |
| **dash** | Ubuntu 的 `/bin/sh`，执行速度快 |

查看当前使用的 Shell：

```bash
echo $SHELL           # 当前用户的默认 Shell
echo $0               # 当前正在运行的 Shell
cat /etc/shells       # 系统安装的所有 Shell 列表
```

### 12.2 Shell 脚本的基础结构

Shell 脚本是一个包含一系列命令的文本文件，可以批量自动化执行操作。

```bash
#!/bin/bash
# 第一行 shebang：告诉系统用哪个 Shell 解释这个脚本
# ↑ #!/usr/bin/env bash 更具移植性

# 这是注释

echo "Script started at $(date)"

# 退出码：0 表示成功，非 0 表示失败
# set -e 让脚本在任何命令失败时立即退出（推荐）
# set -u 让脚本在使用未定义变量时报错
# set -o pipefail 让管道中任何命令失败都算失败
set -euo pipefail
```

给脚本添加执行权限并运行：

```bash
chmod +x deploy.sh
./deploy.sh            # 执行
bash deploy.sh         # 用 bash 解释执行（不需要执行权限）
bash -x deploy.sh      # 调试模式：打印每条命令执行情况
```

---

## 13. 变量、引号与字符串操作

### 13.1 变量基础

```bash
# 赋值（等号两侧不能有空格！）
name="Alice"
age=25
pi=3.14

# 使用变量（加 $）
echo $name
echo "Hello, $name!"
echo "Age: ${age}"          # 花括号：明确变量边界，推荐养成习惯

# 命令赋值给变量
current_date=$(date +%F)
file_count=$(ls /tmp | wc -l)
echo "Today is $current_date, /tmp has $file_count files"

# 只读变量
readonly MAX_RETRIES=3
# MAX_RETRIES=5  # 会报错

# 删除变量
unset name

# 查看所有环境变量
env
printenv
echo $HOME
echo $PATH
```

### 13.2 引号的区别

这是 Shell 中最容易出错的点，必须理解三种引号的区别：

```bash
name="World"

# 双引号：解析变量和命令替换
echo "Hello, $name!"          # 输出：Hello, World!
echo "Today: $(date +%F)"     # 输出：Today: 2026-03-13

# 单引号：完全原样输出，不解析任何内容
echo 'Hello, $name!'          # 输出：Hello, $name!
echo 'Today: $(date +%F)'     # 输出：Today: $(date +%F)

# 反引号（老式命令替换，推荐用 $() 替代）
files=`ls /tmp`   # 不推荐
files=$(ls /tmp)  # 推荐

# 转义特殊字符
echo "Price: \$100"           # 输出：Price: $100
echo "Path: /home/user/file"  # 普通斜杠不需要转义
```

### 13.3 字符串操作

```bash
str="Hello, Linux World"

# 字符串长度
echo ${#str}                  # 输出：18

# 子字符串截取（从位置 7 开始，截取 5 个字符）
echo ${str:7:5}               # 输出：Linux

# 字符串替换（替换第一个匹配）
echo ${str/Linux/Shell}       # 输出：Hello, Shell World

# 字符串替换（替换所有匹配）
path="/usr/local/bin:/usr/bin"
echo ${path//:/\\n}           # 把 : 替换为换行

# 去掉前缀（最短匹配）
file="archive.tar.gz"
echo ${file#*.}               # 输出：tar.gz（去掉 archive.）

# 去掉后缀（最长匹配）
echo ${file%%.*}              # 输出：archive（去掉所有扩展名）
echo ${file%.*}               # 输出：archive.tar（只去掉最后一个 .gz）

# 转换大小写（bash 4+）
str="Hello World"
echo ${str,,}                 # 全小写：hello world
echo ${str^^}                 # 全大写：HELLO WORLD
```

### 13.4 特殊变量

```bash
# 脚本相关特殊变量
echo $0       # 当前脚本名
echo $1       # 第一个参数
echo $2       # 第二个参数
echo $@       # 所有参数（作为独立字符串）
echo $*       # 所有参数（作为一个字符串）
echo $#       # 参数个数
echo $$       # 当前 Shell 的 PID
echo $!       # 最近后台进程的 PID
echo $?       # 上一个命令的退出码（0 成功，非 0 失败）

# 示例脚本：接受参数
#!/bin/bash
if [ $# -lt 1 ]; then
    echo "Usage: $0 <name>"
    exit 1
fi
echo "Hello, $1!"
```

---

## 14. 输入输出重定向与管道

### 14.1 标准输入输出

Linux 的每个进程默认有三个文件描述符：

- `0`：标准输入（stdin）：键盘
- `1`：标准输出（stdout）：终端屏幕
- `2`：标准错误（stderr）：终端屏幕

### 14.2 重定向

```bash
# 标准输出重定向
echo "Hello" > output.txt         # 覆盖写入
echo "World" >> output.txt        # 追加写入
ls -la > file_list.txt

# 标准错误重定向
ls /nonexistent 2> error.log
find / -name "*.conf" 2>/dev/null  # 把错误丢弃（常用！）

# 同时重定向 stdout 和 stderr
command > output.txt 2>&1         # 两者都写到同一文件
command > output.txt 2> error.txt # 分别写入不同文件
command &> all_output.txt         # bash 简写，效果同上

# 标准输入重定向（从文件读取）
mysql -u root -p mydatabase < schema.sql
sort < unsorted.txt > sorted.txt

# /dev/null：黑洞设备，丢弃所有写入
command > /dev/null 2>&1          # 完全静默运行
```

### 14.3 管道

管道（`|`）把前一个命令的输出作为后一个命令的输入，是 Linux 命令组合能力的核心。

```bash
# 基础管道
ps -ef | grep nginx                    # 过滤进程
cat /var/log/nginx/access.log | wc -l  # 统计行数
ls -la | sort -k5 -n -r                # 按文件大小倒序

# 多级管道
ps -ef | grep nginx | grep -v grep | awk '{print $2}'
# 找 nginx 进程 → 过滤掉 grep 本身 → 提取 PID 列

# 统计 Nginx 访问日志中各 IP 的请求数（Top 10）
cat /var/log/nginx/access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -10

# tee：同时输出到屏幕和文件
./build.sh | tee build.log             # 输出到屏幕并保存到文件
```

### 14.4 Here Document

```bash
# heredoc：将多行文本传给命令
cat << 'EOF'
Line 1
Line 2
Line 3
EOF

# 写入配置文件
sudo tee /etc/myapp/config.yaml << 'EOF'
database:
  host: localhost
  port: 5432
  name: mydb
EOF

# 传给 SSH 执行多行命令
ssh user@server << 'ENDSSH'
echo "Running remote setup"
mkdir -p /opt/app
cd /opt/app
git pull origin main
ENDSSH
```

---

## 15. 条件判断与流程控制

### 15.1 if 语句

```bash
# 基础 if
if [ condition ]; then
    # 条件为真时执行
elif [ another_condition ]; then
    # 另一个条件
else
    # 以上都不满足时
fi

# 常用条件判断
file="/etc/nginx/nginx.conf"

if [ -f "$file" ]; then
    echo "文件存在"
fi

if [ -d "/var/log" ]; then
    echo "目录存在"
fi

if [ -e "$file" ]; then    # 存在（文件或目录）
    echo "路径存在"
fi

if [ -r "$file" ]; then    # 可读
    echo "文件可读"
fi

if [ -w "$file" ]; then    # 可写
    echo "文件可写"
fi

if [ -x "/usr/bin/python3" ]; then  # 可执行
    echo "python3 可执行"
fi
```

### 15.2 字符串与数字比较

```bash
name="Alice"
count=10

# 字符串比较
if [ "$name" = "Alice" ]; then echo "匹配"; fi      # 相等
if [ "$name" != "Bob" ]; then echo "不匹配"; fi     # 不等
if [ -z "$name" ]; then echo "为空"; fi              # 为空
if [ -n "$name" ]; then echo "非空"; fi              # 非空

# 数字比较（必须用 -eq/-ne/-lt/-le/-gt/-ge，不能用 = < >）
if [ $count -eq 10 ]; then echo "等于10"; fi
if [ $count -ne 5 ]; then echo "不等于5"; fi
if [ $count -gt 5 ]; then echo "大于5"; fi
if [ $count -lt 20 ]; then echo "小于20"; fi
if [ $count -ge 10 ]; then echo "大于等于10"; fi
if [ $count -le 10 ]; then echo "小于等于10"; fi

# 更现代的写法（[[ ]] 支持正则和逻辑运算符）
if [[ "$name" == Al* ]]; then echo "以 Al 开头"; fi   # 通配符匹配
if [[ "$name" =~ ^[A-Z] ]]; then echo "以大写开头"; fi  # 正则匹配
if [[ $count -gt 5 && $count -lt 20 ]]; then echo "在范围内"; fi
```

### 15.3 case 语句

当需要对同一变量做多种匹配时，`case` 比多个 `if-elif` 更清晰：

```bash
#!/bin/bash
env=$1

case "$env" in
    production|prod)
        echo "部署到生产环境"
        ;;
    staging|stag)
        echo "部署到预发布环境"
        ;;
    development|dev)
        echo "部署到开发环境"
        ;;
    *)
        echo "未知环境: $env"
        echo "用法: $0 [prod|staging|dev]"
        exit 1
        ;;
esac
```

---

## 16. 循环：批量处理的利器

### 16.1 for 循环

```bash
# 遍历列表
for fruit in apple banana orange; do
    echo "Fruit: $fruit"
done

# 遍历文件
for file in /var/log/*.log; do
    echo "Processing: $file"
    wc -l "$file"
done

# 遍历命令输出
for user in $(cat /etc/passwd | cut -d: -f1); do
    echo "User: $user"
done

# C 风格数字循环
for ((i=1; i<=10; i++)); do
    echo "Number: $i"
done

# 使用 seq 生成序列
for i in $(seq 1 5); do
    echo "Step $i"
done

# 实用示例：批量备份配置文件
for conf in nginx mysql redis; do
    src="/etc/$conf/$conf.conf"
    if [ -f "$src" ]; then
        cp "$src" "/backup/${conf}.conf.$(date +%F)"
        echo "Backed up: $conf"
    fi
done
```

### 16.2 while 与 until 循环

```bash
# while：条件为真时继续循环
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done

# 逐行读取文件（推荐方式）
while IFS= read -r line; do
    echo "Line: $line"
done < /etc/hosts

# 无限循环（用于守护进程或轮询）
while true; do
    if curl -sf http://localhost:8080/health > /dev/null; then
        echo "Service is up"
        break
    fi
    echo "Waiting for service..."
    sleep 5
done

# until：条件为假时继续（与 while 相反）
until [ -f "/tmp/ready.flag" ]; do
    echo "Waiting for ready flag..."
    sleep 2
done
echo "Ready flag found!"
```

### 16.3 循环控制

```bash
for i in $(seq 1 10); do
    if [ $i -eq 3 ]; then
        continue    # 跳过本次迭代，继续下一次
    fi
    if [ $i -eq 7 ]; then
        break       # 退出整个循环
    fi
    echo $i
done
# 输出：1 2 4 5 6
```

---

## 17. 函数与脚本结构

### 17.1 定义和调用函数

```bash
# 定义函数
log_info() {
    echo "[$(date +%T)] INFO: $1"
}

log_error() {
    echo "[$(date +%T)] ERROR: $1" >&2   # 错误输出到 stderr
}

# 调用函数
log_info "Script started"
log_error "Something went wrong"

# 函数带返回值（通过 echo 输出）
get_timestamp() {
    echo $(date +%Y%m%d_%H%M%S)
}

ts=$(get_timestamp)
echo "Timestamp: $ts"

# 函数带参数
deploy() {
    local env=$1       # local：局部变量，不影响全局
    local version=$2

    log_info "Deploying version $version to $env"

    if [ -z "$env" ] || [ -z "$version" ]; then
        log_error "Usage: deploy <env> <version>"
        return 1       # 函数退出码
    fi

    # ... 部署逻辑 ...
    return 0
}

deploy production v2.1.0
```

### 17.2 错误处理

```bash
#!/bin/bash
set -euo pipefail

# 错误处理函数（在脚本退出时调用）
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "Script failed with exit code: $exit_code"
        # 清理临时文件等
        rm -f /tmp/lock.$$
    fi
}
trap cleanup EXIT    # 无论正常退出还是出错都会调用

# 检查命令是否成功
if ! command -v nginx >/dev/null 2>&1; then
    echo "Error: nginx is not installed"
    exit 1
fi

# 或者更简洁的写法
nginx -t || { echo "Nginx config test failed"; exit 1; }
```

---

## 18. 文本处理三件套：grep、sed、awk

这三个工具是 Linux 文本处理的核心，掌握它们可以高效处理日志、配置文件和数据。

### 18.1 grep：搜索与过滤

```bash
# 基础搜索
grep "error" /var/log/app.log
grep -i "Error" /var/log/app.log          # 忽略大小写
grep -n "error" /var/log/app.log          # 显示行号
grep -c "error" /var/log/app.log          # 只显示匹配行数
grep -v "DEBUG" /var/log/app.log          # 排除包含 DEBUG 的行

# 扩展正则表达式（-E 或 egrep）
grep -E "error|warning|critical" app.log  # 或匹配
grep -E "^[0-9]{4}-" app.log              # 以4位数字开头的行
grep -E "\b404\b" access.log              # 精确匹配单词 404

# 上下文显示
grep -A 3 "ERROR" app.log     # 匹配行 + 后 3 行
grep -B 3 "ERROR" app.log     # 匹配行 + 前 3 行
grep -C 3 "ERROR" app.log     # 匹配行 + 前后各 3 行

# 递归搜索目录
grep -r "TODO" /opt/app/src/
grep -rl "password" /etc/      # -l 只显示文件名

# 统计日志中各类状态码的数量
grep -oE '"[0-9]{3} ' access.log | sort | uniq -c | sort -rn
```

### 18.2 sed：流式文本替换

```bash
# 基础替换（s/旧内容/新内容/g）
sed 's/http/https/g' config.txt          # 输出到屏幕
sed -i 's/http/https/g' config.txt       # 直接修改文件（-i 原地编辑）
sed -i.bak 's/http/https/g' config.txt   # 修改前自动备份为 .bak

# 只替换第 2 次出现
sed 's/foo/bar/2' file.txt

# 指定行范围操作
sed '5,10d' file.txt                     # 删除第 5 到 10 行
sed '1d' file.txt                        # 删除第 1 行（删除文件头部注释）
sed '/^#/d' config.txt                   # 删除所有注释行
sed '/^$/d' file.txt                     # 删除所有空行

# 在特定行前后插入内容
sed '3i\新增这一行' file.txt              # 在第 3 行前插入
sed '/server_name/a\    listen 443 ssl;' nginx.conf  # 在匹配行后插入

# 提取特定行
sed -n '10,20p' file.txt                  # 只输出第 10-20 行
sed -n '/BEGIN/,/END/p' file.txt          # 输出 BEGIN 到 END 之间的内容

# 实用示例：修改配置文件中的端口
sed -i 's/^port = .*/port = 8080/' /etc/myapp/config.ini
```

### 18.3 awk：结构化文本处理

awk 是一个完整的文本处理语言，特别擅长处理按列分隔的数据：

```bash
# 基础：打印特定列（默认按空白分隔）
awk '{print $1}' file.txt           # 打印第 1 列
awk '{print $1, $3}' file.txt       # 打印第 1 和第 3 列
awk '{print NR, $0}' file.txt       # 打印行号和完整行
df -h | awk '{print $1, $5}'        # 打印分区名和使用率

# 指定分隔符（-F）
awk -F: '{print $1, $7}' /etc/passwd    # 打印用户名和 Shell
awk -F, '{print $1}' data.csv           # 处理 CSV

# 条件过滤
awk '$3 > 100' data.txt                 # 只处理第 3 列大于 100 的行
awk '/ERROR/ {print $0}' app.log        # 包含 ERROR 的行
awk 'NR > 10 && NR < 20' file.txt       # 只处理第 11-19 行

# 计算统计
awk '{sum += $1} END {print "Total:", sum}' numbers.txt
awk '{count[$1]++} END {for (ip in count) print count[ip], ip}' access.log | sort -rn | head

# 实用示例：分析 Nginx 访问日志
# 统计各 HTTP 状态码数量
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -rn

# 统计各 IP 的请求次数（Top 10）
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -10

# 提取响应时间超过 1 秒的请求
awk '$NF > 1.0 {print $0}' /var/log/nginx/access.log
```

---

## 19. Shell 脚本实战：从零写一个部署脚本

下面是一个贴近真实场景的部署脚本，综合运用了前面所有知识点：

```bash
#!/bin/bash
# deploy.sh - 应用部署脚本
# 用法: ./deploy.sh [production|staging] [version]

set -euo pipefail

# ─── 配置 ──────────────────────────────────────────────
APP_NAME="myapp"
DEPLOY_DIR="/opt/${APP_NAME}"
LOG_DIR="/var/log/${APP_NAME}"
BACKUP_DIR="/opt/backups/${APP_NAME}"
SERVICE_NAME="${APP_NAME}"

# ─── 工具函数 ───────────────────────────────────────────
log_info()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO]  $*"; }
log_warn()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN]  $*" >&2; }
log_error() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $*" >&2; }

# 脚本退出时的清理工作
cleanup() {
    local code=$?
    [ $code -ne 0 ] && log_error "Deployment failed! Exit code: $code"
    rm -f /tmp/deploy.$$.lock
}
trap cleanup EXIT

# ─── 参数检查 ───────────────────────────────────────────
if [ $# -lt 2 ]; then
    log_error "Usage: $0 <env> <version>"
    log_error "  env:     production | staging"
    log_error "  version: e.g. v2.1.0"
    exit 1
fi

ENV=$1
VERSION=$2

case "$ENV" in
    production|staging) ;;
    *) log_error "Unknown environment: $ENV"; exit 1 ;;
esac

# ─── 防止并发部署 ────────────────────────────────────────
LOCK_FILE="/tmp/deploy.$$.lock"
if [ -f "$LOCK_FILE" ]; then
    log_error "Another deployment is in progress!"
    exit 1
fi
touch "$LOCK_FILE"

# ─── 主流程 ─────────────────────────────────────────────
log_info "Starting deployment: $APP_NAME $VERSION → $ENV"

# 1. 检查依赖
for cmd in git systemctl nginx; do
    if ! command -v $cmd &>/dev/null; then
        log_error "Required command not found: $cmd"
        exit 1
    fi
done

# 2. 备份当前版本
mkdir -p "$BACKUP_DIR"
if [ -d "$DEPLOY_DIR/current" ]; then
    BACKUP_PATH="${BACKUP_DIR}/${VERSION}-$(date +%Y%m%d_%H%M%S)"
    log_info "Backing up current version to $BACKUP_PATH"
    cp -a "$DEPLOY_DIR/current" "$BACKUP_PATH"
fi

# 3. 拉取新版本
log_info "Fetching version $VERSION..."
cd "$DEPLOY_DIR"
git fetch --tags
git checkout "$VERSION"

# 4. 安装依赖并构建
log_info "Installing dependencies..."
npm ci --production 2>&1 | tee -a "$LOG_DIR/deploy.log"

# 5. 配置检查
log_info "Validating nginx config..."
nginx -t || { log_error "Nginx config validation failed!"; exit 1; }

# 6. 重启服务
log_info "Restarting service..."
sudo systemctl restart "$SERVICE_NAME"

# 7. 健康检查（最多等 30 秒）
log_info "Waiting for service health check..."
for i in $(seq 1 6); do
    if curl -sf "http://localhost:8080/health" > /dev/null; then
        log_info "Health check passed!"
        break
    fi
    if [ $i -eq 6 ]; then
        log_error "Health check failed after 30 seconds!"
        exit 1
    fi
    log_warn "Health check attempt $i/6 failed, retrying in 5s..."
    sleep 5
done

log_info "Deployment completed successfully: $APP_NAME $VERSION → $ENV"
```

---

## 20. 命令速查总表

### 文件与目录

| 命令 | 说明 |
|------|------|
| `pwd` | 显示当前路径 |
| `cd /path` | 切换目录 |
| `ls -alh` | 详细列出文件（含隐藏文件，人类可读大小） |
| `ls -lt` | 按时间排序 |
| `mkdir -p /a/b/c` | 递归创建目录 |
| `cp -a src dst` | 保留属性复制 |
| `mv old new` | 移动/重命名 |
| `rm -rf dir/` | 递归强制删除（高危） |
| `ln -s target link` | 创建软链接 |
| `find /path -name "*.log"` | 按名称搜索文件 |
| `find /path -mtime +7` | 搜索 7 天前的文件 |

### 查看文件

| 命令 | 说明 |
|------|------|
| `cat file` | 输出文件全部内容 |
| `less file` | 分页查看 |
| `head -n 20 file` | 查看前 20 行 |
| `tail -n 50 file` | 查看后 50 行 |
| `tail -f file` | 实时追踪文件新增内容 |
| `stat file` | 查看文件详细元信息 |

### 权限与用户

| 命令 | 说明 |
|------|------|
| `chmod 755 file` | 修改权限（数字） |
| `chmod +x file` | 添加执行权限 |
| `chown user:group file` | 修改属主属组 |
| `chown -R user:group /dir` | 递归修改 |
| `umask` | 查看默认权限掩码 |
| `sudo command` | 以 root 权限执行 |
| `sudo -l` | 查看当前用户 sudo 权限 |
| `useradd -m -s /bin/bash user` | 创建用户 |
| `usermod -aG group user` | 追加用户到组 |

### 进程管理

| 命令 | 说明 |
|------|------|
| `ps -ef` | 查看所有进程 |
| `ps -ef \| grep name` | 过滤进程 |
| `top` / `htop` | 实时进程监控 |
| `pgrep -l name` | 按名称查找 PID |
| `kill -15 PID` | 优雅终止进程 |
| `kill -9 PID` | 强制终止进程 |
| `killall name` | 按名称终止所有进程 |
| `nohup cmd &` | 后台持久运行 |

### 服务管理（systemd）

| 命令 | 说明 |
|------|------|
| `systemctl status svc` | 查看服务状态 |
| `systemctl start svc` | 启动服务 |
| `systemctl stop svc` | 停止服务 |
| `systemctl restart svc` | 重启服务 |
| `systemctl reload svc` | 重载配置（不中断） |
| `systemctl enable svc` | 设置开机自启 |
| `systemctl disable svc` | 取消开机自启 |
| `systemctl enable --now svc` | 设置自启并立即启动 |
| `systemctl list-units --state=failed` | 列出失败服务 |

### 资源监控

| 命令 | 说明 |
|------|------|
| `df -h` | 磁盘分区使用情况 |
| `du -sh /path/*` | 目录磁盘占用 |
| `free -h` | 内存使用情况 |
| `uptime` | 系统负载 |
| `vmstat 1 5` | 综合系统资源采样 |
| `iostat -x 1 5` | 磁盘 IO 监控 |

### 日志

| 命令 | 说明 |
|------|------|
| `journalctl -u svc -n 100` | 服务最近 100 行日志 |
| `journalctl -u svc -f` | 实时追踪服务日志 |
| `journalctl -p err -n 50` | 最近 50 条错误 |
| `journalctl --since "1 hour ago"` | 最近 1 小时日志 |
| `tail -f /var/log/nginx/error.log` | 追踪 Nginx 错误日志 |

### 文本处理

| 命令 | 说明 |
|------|------|
| `grep -n "keyword" file` | 搜索并显示行号 |
| `grep -v "exclude" file` | 排除匹配行 |
| `grep -E "pat1\|pat2"` | 多模式匹配 |
| `grep -C 3 "ERROR" file` | 匹配行及前后 3 行 |
| `sed 's/old/new/g' file` | 全局替换 |
| `sed -i.bak 's/old/new/g' file` | 原地替换并备份 |
| `awk '{print $1}' file` | 打印第一列 |
| `awk -F: '{print $1}' /etc/passwd` | 指定分隔符 |
| `sort \| uniq -c \| sort -rn` | 排序去重统计频率 |
| `wc -l file` | 统计行数 |

---

## 21. 延伸阅读

### Linux 基础

- [**Linux man-pages**](https://man7.org/linux/man-pages/)：所有 Linux 命令和系统调用的权威手册，用 `man command` 在本地查阅
- [**The Linux Documentation Project (TLDP)**](https://tldp.org/)：大量 Linux 学习指南和 HOWTO 文档，适合系统性学习
- [**Linux Command（命令手册）**](https://linuxcommand.org/)：面向新手的 Linux 命令学习资源

### systemd

- [**systemd 官方文档**](https://www.freedesktop.org/software/systemd/man/)：systemctl、journalctl、Unit 文件格式的完整参考
- [**systemd by Example**](https://systemd-by-example.com/)：通过大量实例理解 systemd 各组件

### Shell 脚本

- [**Bash 参考手册**](https://www.gnu.org/software/bash/manual/bash.html)：Bash 官方完整文档
- [**Shell Scripting Tutorial**](https://www.shellscript.sh/)：循序渐进的 Shell 脚本学习教程
- [**ShellCheck**](https://www.shellcheck.net/)：在线 Shell 脚本静态检查工具，帮你发现常见错误（强烈推荐！）
- [**Google Shell Style Guide**](https://google.github.io/styleguide/shellguide.html)：Google 内部 Shell 脚本规范，适合进阶学习

### 运维实践

- [**Nginx 运维文档**](https://nginx.org/en/docs/)：Nginx 配置与优化的官方参考
- [**The Art of Command Line**](https://github.com/jlevy/the-art-of-command-line/blob/master/README-zh.md)：高质量命令行使用技巧集合，中文版

---

*本文档持续维护更新。如有错误或建议，欢迎提交 Issue 或 PR。*