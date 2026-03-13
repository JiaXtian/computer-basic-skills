# Python 完整指南

> **适用人群**：计算机系新生、转行入门者、需要系统掌握 Python 开发环境与工程实践的学习者
> **前置要求**：具备基础命令行操作能力
> **最后更新**：2026-03-13

---

## 目录

**环境篇**
1. [Python 是什么，为什么学它](#1-python-是什么为什么学它)
2. [安装 Python：三大平台完整指南](#2-安装-python三大平台完整指南)
3. [虚拟环境：venv 与 virtualenv](#3-虚拟环境venv-与-virtualenv)
4. [Conda：科学计算的环境管理利器](#4-conda科学计算的环境管理利器)
5. [包管理：pip 的完整用法](#5-包管理pip-的完整用法)
6. [项目依赖管理：requirements.txt 与 pyproject.toml](#6-项目依赖管理requirementstxt-与-pyprojecttoml)

**语言基础篇**
7. [变量、数据类型与运算符](#7-变量数据类型与运算符)
8. [字符串：最常用的数据类型](#8-字符串最常用的数据类型)
9. [列表、元组、集合与字典](#9-列表元组集合与字典)
10. [流程控制：条件与循环](#10-流程控制条件与循环)
11. [函数：代码复用的基本单元](#11-函数代码复用的基本单元)
12. [文件操作与异常处理](#12-文件操作与异常处理)
13. [模块与包：组织代码的方式](#13-模块与包组织代码的方式)

**工程实践篇**
14. [代码风格：PEP 8 与格式化工具](#14-代码风格pep-8-与格式化工具)
15. [调试与测试基础](#15-调试与测试基础)
16. [常用标准库速览](#16-常用标准库速览)
17. [命令速查总表](#17-命令速查总表)
18. [延伸阅读](#18-延伸阅读)

---

# 环境篇

## 1. Python 是什么，为什么学它

### 1.1 Python 的定位

Python 是一门以**可读性**为核心设计原则的高级编程语言，由 Guido van Rossum 于 1991 年发布。它的语法接近自然语言，去掉了大量样板代码，让程序员能把精力集中在解决问题本身，而不是与语言规则周旋。

同样实现一个读取文件、统计词频的程序，Python 往往只需要其他语言三分之一的代码量。这不是偷懒，而是语言设计上的刻意取舍：用表达力换开发效率。Python 的核心哲学被写进了 `import this` 这首"Python 之禅"里，其中最有名的一句是："There should be one obvious way to do it."——做一件事应该有且只有一种显而易见的方式。

### 1.2 Python 适合做什么

Python 今天是覆盖领域最广的编程语言之一，几乎没有它碰不到的方向：

| 领域 | 代表工具/框架 |
|------|-------------|
| **Web 后端开发** | Django、FastAPI、Flask |
| **数据分析** | Pandas、NumPy、Jupyter Notebook |
| **机器学习 / AI** | PyTorch、TensorFlow、scikit-learn |
| **自动化脚本** | 批量处理文件、定时任务、网络爬虫 |
| **DevOps 工具** | Ansible、AWS CDK、各类 CLI 工具 |
| **科学计算** | SciPy、Matplotlib、SymPy |
| **系统管理** | 替代复杂 Shell 脚本，适合包含业务逻辑的自动化 |

Python 的另一个优势是生态极其丰富——PyPI（Python Package Index）上有超过 50 万个第三方包，几乎任何你需要的功能都有现成的库。

### 1.3 Python 2 vs Python 3

Python 2 已于 2020 年 1 月 1 日正式停止维护。**所有新项目都应使用 Python 3**，目前主流生产版本是 Python 3.11 和 3.12。本文所有示例均基于 Python 3。如果你在老项目中遇到 Python 2 代码，最常见的差异是：`print` 从语句变成了函数，字符串默认变成了 Unicode，`/` 除法始终返回浮点数。

---

## 2. 安装 Python：三大平台完整指南

### 2.1 macOS

macOS 系统自带的 Python 版本通常较旧，且是系统工具依赖，不建议直接使用。推荐通过 Homebrew 安装独立的官方版本：

```bash
# 先安装 Homebrew（如果还没有）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装 Python 3.12
brew install python@3.12

# 验证安装
python3 --version
# 输出：Python 3.12.x

pip3 --version
```

macOS 上 `python` 命令可能仍然指向系统自带旧版，始终用 `python3` 和 `pip3` 明确指定版本。

如果你需要**频繁切换多个 Python 版本**（比如维护不同项目分别要求 3.10、3.11、3.12），推荐安装 `pyenv`：

```bash
# 安装 pyenv
brew install pyenv

# 在 ~/.zshrc 或 ~/.bashrc 中加入以下三行（安装后 brew 会提示）
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
source ~/.zshrc

# 查看可安装的 Python 版本
pyenv install --list | grep "  3\.12"

# 安装指定版本
pyenv install 3.12.2

# 设置全局默认版本
pyenv global 3.12.2

# 为某个项目目录单独设置版本（会在目录下生成 .python-version 文件）
cd myproject
pyenv local 3.11.8

# 查看当前版本
pyenv version
pyenv versions    # 列出所有已安装版本
```

### 2.2 Windows

**方法一：官方安装包（推荐新手）**

前往 [python.org/downloads](https://www.python.org/downloads/) 下载最新的 Python 3.12 安装包。安装时必须注意两个关键选项：

- ✅ 勾选 **"Add Python 3.12 to PATH"**（这一步非常重要，漏掉后命令行就找不到 python 命令）
- 推荐选择 **"Customize installation"** 确认 pip 已被勾选

安装后在命令提示符（CMD）或 PowerShell 中验证：

```powershell
python --version
# 输出：Python 3.12.x

pip --version
```

**方法二：Microsoft Store（最简单）**

在 Microsoft Store 搜索 "Python 3.12" 一键安装，适合快速上手。

**方法三：winget（命令行方式）**

```powershell
winget install Python.Python.3.12
```

### 2.3 Linux（Ubuntu/Debian）

Ubuntu 通常预装了 Python 3，但可能不是最新版本：

```bash
# 检查当前版本
python3 --version

# 通过 deadsnakes PPA 安装更新的版本（Ubuntu 推荐方式）
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.12 python3.12-venv python3.12-dev

# 安装 pip
sudo apt install python3-pip

# 验证
python3.12 --version
pip3 --version
```

**CentOS/RHEL**：

```bash
sudo dnf install python3.12 python3-pip
```

### 2.4 验证安装与 REPL 初体验

安装完成后，进入 Python 交互式解释器（REPL，Read-Eval-Print Loop）做最终确认。REPL 是 Python 的即时执行环境，每输入一行代码就立即看到结果，非常适合快速实验：

```bash
python3
# 进入后显示版本信息和 >>> 提示符

>>> print("Hello, Python!")
Hello, Python!
>>> 2 ** 10
1024
>>> import sys; print(sys.version)

# 退出
>>> exit()
# 或 Ctrl+D（Linux/macOS），Ctrl+Z 回车（Windows）
```

---

## 3. 虚拟环境：venv 与 virtualenv

### 3.1 为什么必须使用虚拟环境

这是 Python 新手最容易跳过、却最容易踩坑的环节，必须认真对待。

设想你同时维护两个项目：

- 项目 A 依赖 `Django 4.2`
- 项目 B 依赖 `Django 3.2`（老项目，暂时没精力升级）

如果所有包都安装到系统 Python（全局环境），这两个版本无法共存，一个项目必然出问题。**虚拟环境**的作用是：为每个项目创建一个完全独立的 Python 环境，各自有独立的包目录，互不干扰。

这不是可选的"最佳实践"，而是 Python 项目管理的**基本规范**。在工程团队中，一个没有虚拟环境的 Python 项目往往意味着依赖混乱、无法复现、协作困难。养成习惯：**每开一个新项目，第一步就是创建虚拟环境**。

### 3.2 venv：Python 内置的虚拟环境工具

`venv` 是 Python 3.3+ 内置的虚拟环境模块，无需额外安装，够用且稳定。

```bash
# 第一步：在项目目录下创建虚拟环境
# 命名约定用 .venv（以 . 开头会被 ls 默认隐藏，更整洁）
python3 -m venv .venv

# 第二步：激活虚拟环境
# macOS / Linux：
source .venv/bin/activate

# Windows（CMD）：
.venv\Scripts\activate.bat

# Windows（PowerShell）：
.venv\Scripts\Activate.ps1
# 如果 PowerShell 报"脚本执行被禁用"，先执行：
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 激活成功后，命令行提示符前会出现 (.venv) 前缀：
# (.venv) user@machine:~/myproject$

# 第三步：确认 Python 指向虚拟环境（而不是系统全局）
which python          # macOS/Linux，应输出 .venv/bin/python
where python          # Windows

python --version      # 激活后 python 和 python3 都指向虚拟环境
pip --version         # pip 也指向虚拟环境

# 第四步：安装项目依赖（只影响虚拟环境，不污染全局）
pip install requests flask

# 第五步：退出虚拟环境
deactivate
# 提示符前缀 (.venv) 消失，回到系统环境
```

### 3.3 虚拟环境的日常工作流

```bash
# 新项目的标准启动流程
mkdir myproject && cd myproject
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt    # 安装项目依赖（如果有）

# 每次打开新终端都需要重新激活
# 养成习惯：cd 进入项目目录后，第一件事就是 source .venv/bin/activate

# .gitignore 中必须忽略虚拟环境目录（不要提交到 git）
echo ".venv/" >> .gitignore
echo "venv/" >> .gitignore
echo "__pycache__/" >> .gitignore
echo "*.pyc" >> .gitignore
```

> **最常见的错误**：忘记激活虚拟环境就直接 `pip install`，把包装到了全局环境。激活前先检查命令行前缀是否有 `(.venv)`。

### 3.4 virtualenv：功能更丰富的替代方案

`virtualenv` 是第三方工具，比内置 `venv` 创建速度更快，支持更灵活的 Python 版本选择：

```bash
# 安装
pip install virtualenv

# 创建虚拟环境（用法与 venv 基本相同）
virtualenv .venv

# 指定 Python 版本（非常实用）
virtualenv -p python3.11 .venv
virtualenv -p $(which python3.12) .venv

# 激活方式与 venv 完全相同
source .venv/bin/activate
```

---

## 4. Conda：科学计算的环境管理利器

### 4.1 Conda 与 pip/venv 的本质区别

Conda 是另一套独立的包管理与环境管理系统，起源于科学计算社区（Anaconda 公司维护）。它与 pip+venv 的核心区别是：

| | pip + venv | Conda |
|--|-----------|-------|
| **包来源** | PyPI（Python 包索引） | Conda 仓库（含非 Python 包） |
| **管理范围** | 仅 Python 包 | Python 包 + C/C++ 库 + CUDA + R 等 |
| **环境隔离** | Python 虚拟环境 | 完整独立环境（含 Python 本身） |
| **适用场景** | Web 开发、通用 Python | 数据科学、机器学习、科学计算 |
| **解析依赖** | 较简单 | 更复杂但更全面 |

Conda 的核心优势是能管理**非 Python 的二进制依赖**。比如 `numpy` 在底层依赖 BLAS/LAPACK 数学库，PyTorch 依赖特定版本的 CUDA，这些用 pip 安装往往需要手动处理系统级依赖，稍有不慎就会版本冲突。Conda 把这些复杂的二进制依赖也统一纳入管理，一条命令安装好，省去大量麻烦。

**选择建议**：做 Web 开发或通用脚本，用 pip+venv 就够了；做数据科学、机器学习、需要 GPU 或复杂科学计算库，优先用 Conda。

### 4.2 安装 Miniconda（推荐）

Conda 有两种发行版：
- **Anaconda**：包含 Conda + 250 余个预装数据科学包 + 图形界面，安装包约 3GB
- **Miniconda**：只含 Conda 本身，约 100MB，按需安装包（推荐）

```bash
# Linux（x86_64）
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
# 按提示操作，建议同意初始化 conda（会在 .bashrc 中写入初始化脚本）
# 安装完成后关闭并重新打开终端

# Linux（ARM64，适用于树莓派等）
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh
bash Miniconda3-latest-Linux-aarch64.sh

# macOS（Apple Silicon，M1/M2/M3）
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
bash Miniconda3-latest-MacOSX-arm64.sh

# macOS（Intel）
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
bash Miniconda3-latest-MacOSX-x86_64.sh

# Windows：从官网下载 .exe 安装包
# https://docs.conda.io/en/latest/miniconda.html

# 验证安装
conda --version
# 输出：conda 24.x.x

# 更新 conda 本身
conda update -n base conda
```

### 4.3 Conda 环境管理

```bash
# 创建新环境，指定 Python 版本
conda create -n myenv python=3.12
# -n myenv 是环境名，存储在 ~/miniconda3/envs/myenv/

# 创建环境的同时安装常用包（效率更高，减少依赖冲突）
conda create -n dataenv python=3.11 numpy pandas matplotlib jupyter scikit-learn

# 查看所有已创建的环境
conda env list
# 或
conda info --envs
# 输出示例：
# base              * /home/user/miniconda3
# myenv               /home/user/miniconda3/envs/myenv
# dataenv             /home/user/miniconda3/envs/dataenv
# 当前激活的环境前有 * 标记

# 激活环境
conda activate myenv
# 提示符前会出现 (myenv) 前缀

# 退出环境（回到 base 环境）
conda deactivate

# 克隆已有环境（快速复制一个环境用于实验）
conda create -n myenv-backup --clone myenv

# 删除环境（--all 删除整个目录）
conda env remove -n myenv --all

# 重命名环境（先克隆，再删除原来的）
conda create -n newname --clone myenv
conda env remove -n myenv --all
```

### 4.4 Conda 包管理

```bash
# 安装包
conda install numpy
conda install numpy pandas matplotlib     # 一次安装多个

# 从 conda-forge 频道安装（社区维护，包更全更新，强烈推荐添加）
conda install -c conda-forge jupyterlab
conda install -c conda-forge pytorch

# 安装指定版本
conda install numpy=1.26.0
conda install "numpy>=1.24,<2.0"

# 查看当前环境已安装的包
conda list
conda list | grep numpy                   # 过滤查看

# 更新包
conda update numpy
conda update --all                        # 更新当前环境所有包

# 删除包
conda remove numpy

# 搜索可用包及版本
conda search numpy
conda search -c conda-forge torch         # 在 conda-forge 频道搜索
```

### 4.5 在 Conda 环境中使用 pip

Conda 仓库里没有的包，可以在 Conda 环境中使用 pip 安装（从 PyPI 获取）：

```bash
conda activate myenv
pip install some-pypi-only-package

# 最佳实践：优先用 conda install，不够再用 pip
# 这样 conda 的依赖解析能覆盖尽可能多的包，减少冲突
# 混用时 conda install 放前面操作，pip install 放后面
```

### 4.6 导出与重建环境（团队协作关键）

```bash
# 导出当前环境为 YAML 文件（含精确版本号）
conda env export > environment.yml

# 导出时去掉平台特定的构建字符串（跨平台兼容性更好）
conda env export --no-builds > environment.yml

# 只导出手动安装的包（不含自动引入的依赖，文件更简洁）
conda env export --from-history > environment.yml

# 根据 environment.yml 重建环境
conda env create -f environment.yml

# 更新已有环境（environment.yml 有改动时）
conda env update -f environment.yml --prune
# --prune 会删除 yml 文件中没有的包
```

`environment.yml` 文件示例：

```yaml
name: myenv
channels:
  - conda-forge
  - defaults
dependencies:
  - python=3.12
  - numpy=1.26.0
  - pandas=2.2.0
  - matplotlib=3.8.0
  - jupyter
  - pip:
    - some-pypi-only-package==1.0.0    # pip 安装的包单独列在这里
```

### 4.7 Conda 配置优化

```bash
# 添加 conda-forge 频道并设为最高优先级（推荐）
conda config --add channels conda-forge
conda config --set channel_priority strict

# 查看当前配置
conda config --show

# 配置国内镜像加速（清华大学镜像源）
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
conda config --set show_channel_urls yes

# 查看修改后的配置（存储在 ~/.condarc）
cat ~/.condarc

# 禁用 conda 自动激活 base 环境（每次打开终端不自动进入 base）
conda config --set auto_activate_base false
```

---

## 5. 包管理：pip 的完整用法

### 5.1 pip 基础操作

```bash
# 第一件事：升级 pip 本身
# 用 python -m pip 而不是直接 pip，确保用的是当前环境的 pip
python -m pip install --upgrade pip

# 安装包
pip install requests
pip install requests==2.31.0             # 指定精确版本
pip install "requests>=2.28.0,<3.0"     # 版本范围
pip install requests flask sqlalchemy   # 一次安装多个

# 安装开发版（从 GitHub 仓库）
pip install git+https://github.com/user/repo.git
pip install git+https://github.com/user/repo.git@v1.2.0  # 指定 tag

# 以"可编辑模式"安装本地包（修改代码立即生效，无需重新安装）
pip install -e .
pip install -e ".[dev]"                 # 同时安装 dev 额外依赖

# 查看已安装的包
pip list
pip list --outdated                     # 查看可更新的包

# 查看某个包的详情（版本、依赖、安装位置）
pip show requests

# 更新包
pip install --upgrade requests
pip install --upgrade requests flask   # 一次更新多个

# 卸载包
pip uninstall requests
pip uninstall -y requests              # -y 跳过确认提示
```

### 5.2 pip 镜像源配置

国内使用 pip 安装包有时较慢，配置镜像源可以显著提速：

```bash
# 临时使用镜像（单次生效）
pip install numpy -i https://pypi.tuna.tsinghua.edu.cn/simple

# 永久配置全局镜像（写入 pip 配置文件）
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn

# 查看当前 pip 配置
pip config list

# 常用国内镜像源
# 清华大学：https://pypi.tuna.tsinghua.edu.cn/simple
# 阿里云：  https://mirrors.aliyun.com/pypi/simple/
# 腾讯云：  https://mirrors.cloud.tencent.com/pypi/simple/
```

---

## 6. 项目依赖管理：requirements.txt 与 pyproject.toml

### 6.1 requirements.txt

这是最传统、最通用的 Python 依赖描述格式，几乎所有工具和平台都支持：

```bash
# 生成 requirements.txt（当前环境所有包的精确版本快照）
pip freeze > requirements.txt

# 查看内容（类似）
# requests==2.31.0
# flask==3.0.0
# sqlalchemy==2.0.25

# 根据文件安装所有依赖
pip install -r requirements.txt
```

实际工程中更推荐手动维护一个**只含直接依赖**的 `requirements.txt`，版本号用范围而不是精确值（精确版本留给 lock 文件）：

```text
# requirements.txt（手动维护，只写直接依赖）
requests>=2.28.0
flask>=3.0.0
sqlalchemy>=2.0.0

# requirements-dev.txt（开发时额外依赖）
pytest>=7.0
black>=23.0
ruff>=0.1.0
```

### 6.2 pyproject.toml（现代标准）

`pyproject.toml` 是 Python 官方推荐的现代项目配置格式，把项目元数据、依赖声明、工具配置统一在一个文件里，是目前新项目的最佳选择：

```toml
# pyproject.toml
[project]
name = "my-app"
version = "1.0.0"
description = "A sample Python application"
requires-python = ">=3.11"
dependencies = [
    "requests>=2.28.0",
    "fastapi>=0.100.0",
    "sqlalchemy>=2.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "black>=23.0",
    "ruff>=0.1.0",
    "mypy>=1.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

# 各工具配置统一写在这里，不需要单独的配置文件
[tool.black]
line-length = 88

[tool.ruff]
line-length = 88
select = ["E", "F", "I"]

[tool.mypy]
python_version = "3.12"
strict = true
```

```bash
# 安装项目（含 dependencies 中的依赖）
pip install .

# 安装包含开发依赖
pip install ".[dev]"

# 以可编辑模式安装（开发推荐）
pip install -e ".[dev]"
```

---

# 语言基础篇

## 7. 变量、数据类型与运算符

### 7.1 变量与基础类型

Python 是动态类型语言，变量无需声明类型，赋值即创建，类型由值决定：

```python
# 整数（int）
age = 25
big_number = 1_000_000     # 下划线分隔，提高可读性，等同于 1000000

# 浮点数（float）
pi = 3.14159
temperature = -7.5

# 布尔值（bool）
is_active = True
has_error = False

# None（表示"没有值"，类似其他语言的 null）
result = None

# 字符串（str）
name = "Alice"
greeting = 'Hello'         # 单引号双引号等价
multiline = """
这是
多行字符串
"""

# 查看变量类型
print(type(age))           # <class 'int'>
print(type(pi))            # <class 'float'>
print(type(name))          # <class 'str'>
print(type(is_active))     # <class 'bool'>

# 类型转换
str(42)           # "42"
int("100")        # 100
float("3.14")     # 3.14
bool(0)           # False（0、""、[]、None 都是 falsy）
bool(1)           # True
list("abc")       # ['a', 'b', 'c']
```

### 7.2 运算符

```python
# 算术运算符
10 + 3     # 13
10 - 3     # 7
10 * 3     # 30
10 / 3     # 3.3333...（除法总是返回浮点数）
10 // 3    # 3（整除，取商）
10 % 3     # 1（取余）
2 ** 10    # 1024（幂运算）

# 比较运算符（返回布尔值）
5 > 3      # True
5 == 5     # True（比较值相等，注意是双等号）
5 != 3     # True（不等于）
"a" < "b"  # True（字符串按字典序比较）

# 身份运算符（比较是否是内存中同一个对象）
x = [1, 2, 3]
y = x
z = [1, 2, 3]
x is y     # True（y 和 x 指向同一对象）
x is z     # False（z 是值相同但独立的对象）
x == z     # True（值相等）
# 判断 None 时用 is，而不是 ==
result is None

# 逻辑运算符（支持短路求值）
True and False   # False
True or False    # True
not True         # False

# 成员运算符
"a" in "apple"      # True
3 in [1, 2, 3]      # True
4 not in [1, 2, 3]  # True
"key" in {"key": 1} # True（字典判断 key 是否存在）

# 赋值运算符
x = 10
x += 3     # x = 13
x -= 2     # x = 11
x *= 2     # x = 22
x //= 3    # x = 7
x **= 2    # x = 49
```

---

## 8. 字符串：最常用的数据类型

字符串是 Python 中使用频率最高的数据类型，熟练掌握字符串操作能显著提升日常开发效率。

### 8.1 字符串基础操作

```python
s = "Hello, Python!"

# 长度
len(s)             # 14

# 索引（从 0 开始，负数从末尾倒数）
s[0]               # "H"
s[-1]              # "!"

# 切片 [开始:结束:步长]（左闭右开区间）
s[0:5]             # "Hello"
s[7:]              # "Python!"
s[:5]              # "Hello"
s[::2]             # "Hlo yhn"（每隔一个取一个）
s[::-1]            # "!nohtyP ,olleH"（反转字符串）

# 拼接与重复
"Hello" + " " + "World"    # "Hello World"
"ha" * 3                   # "hahaha"

# 包含判断
"Python" in s              # True
```

### 8.2 常用字符串方法

```python
s = "  Hello, World!  "

# 大小写转换
s.upper()          # "  HELLO, WORLD!  "
s.lower()          # "  hello, world!  "
s.title()          # "  Hello, World!  "（每词首字母大写）

# 去除空白
s.strip()          # "Hello, World!"（两侧空白）
s.lstrip()         # "Hello, World!  "（左侧）
s.rstrip()         # "  Hello, World!"（右侧）

# 查找与替换
s.find("World")         # 9（返回索引，找不到返回 -1）
s.count("l")            # 3（统计出现次数）
s.replace("World", "Python")   # "  Hello, Python!  "

# 分割与合并
"a,b,c,d".split(",")            # ["a", "b", "c", "d"]
"hello world".split()           # ["hello", "world"]（按空白分割）
",".join(["a", "b", "c"])       # "a,b,c"
"\n".join(["line1", "line2"])   # "line1\nline2"

# 判断类型
"123".isdigit()      # True
"abc".isalpha()      # True
"abc123".isalnum()   # True
s.startswith("  H")  # True
s.endswith("!  ")    # True
```

### 8.3 f-string：最推荐的字符串格式化方式

f-string（Formatted String Literals）是 Python 3.6+ 引入的格式化语法，目前最推荐的方式，直观且高效：

```python
name = "Alice"
age = 25
score = 98.567

# 基础用法：花括号内写变量名或表达式
print(f"My name is {name}, I am {age} years old.")
print(f"Next year I will be {age + 1}")

# 格式控制
print(f"Score: {score:.2f}")          # 两位小数：98.57
print(f"Padded: {age:05d}")           # 补零到 5 位：00025
print(f"Hex: {255:#x}")               # 十六进制：0xff
print(f"Percent: {0.856:.1%}")        # 百分比：85.6%
print(f"Right align: {name:>10}")     # 右对齐，宽度 10

# 调试用法（Python 3.8+）：变量名=值格式
print(f"{name=}, {age=}")             # name='Alice', age=25

# 多行 f-string
message = (
    f"Name: {name}\n"
    f"Age:  {age}\n"
    f"Score: {score:.1f}"
)
```

---

## 9. 列表、元组、集合与字典

### 9.1 列表（list）：有序可变序列

```python
fruits = ["apple", "banana", "cherry"]

# 访问与切片
fruits[0]            # "apple"
fruits[-1]           # "cherry"
fruits[1:3]          # ["banana", "cherry"]

# 修改
fruits[0] = "mango"
fruits.append("orange")          # 末尾添加
fruits.insert(1, "grape")        # 在索引 1 处插入
fruits.extend(["kiwi", "pear"])  # 追加另一个列表的所有元素

# 删除
fruits.remove("banana")          # 按值删除（删除第一个匹配）
del fruits[0]                    # 按索引删除
popped = fruits.pop()            # 删除并返回末尾元素
popped = fruits.pop(1)           # 删除并返回指定索引的元素

# 查询与排序
"apple" in fruits                # True/False
fruits.index("cherry")           # 返回索引（不存在则报错）
fruits.count("apple")            # 统计出现次数
fruits.sort()                    # 原地排序（升序）
fruits.sort(reverse=True)        # 原地排序（降序）
sorted_copy = sorted(fruits)     # 返回新排序列表，不修改原列表

# 列表推导式（Python 最优雅的语法之一）
squares = [x**2 for x in range(10)]
evens   = [x for x in range(20) if x % 2 == 0]
upper   = [name.upper() for name in ["alice", "bob", "charlie"]]

# 嵌套推导式（矩阵展开）
matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
flat   = [num for row in matrix for num in row]  # [1, 2, 3, 4, 5, 6, 7, 8, 9]
```

### 9.2 元组（tuple）：有序不可变序列

```python
point = (3, 4)
rgb   = (255, 128, 0)
single = (42,)     # 单元素元组必须有逗号，否则被当成普通括号

# 访问（与列表相同）
point[0]           # 3

# 解包（非常实用的特性）
x, y = point       # x=3, y=4
r, g, b = rgb

# 扩展解包（Python 3+）
first, *rest = [1, 2, 3, 4, 5]     # first=1, rest=[2, 3, 4, 5]
*init, last  = [1, 2, 3, 4, 5]     # init=[1, 2, 3, 4], last=5

# 函数返回多个值，本质上就是返回元组
def min_max(data):
    return min(data), max(data)    # 返回元组

low, high = min_max([3, 1, 4, 1, 5, 9, 2])
```

### 9.3 集合（set）：无序不重复

```python
# 创建集合（自动去重）
tags = {"python", "coding", "python", "dev"}
print(tags)    # {'python', 'coding', 'dev'}

# 添加与删除
tags.add("tutorial")
tags.remove("dev")         # 不存在时报 KeyError
tags.discard("notexist")   # 不存在时静默忽略

# 集合运算
a = {1, 2, 3, 4}
b = {3, 4, 5, 6}
a | b    # 并集：{1, 2, 3, 4, 5, 6}
a & b    # 交集：{3, 4}
a - b    # 差集：{1, 2}（在 a 不在 b）
a ^ b    # 对称差集：{1, 2, 5, 6}

# 实用场景：快速列表去重
nums   = [1, 2, 2, 3, 3, 3, 4]
unique = list(set(nums))      # [1, 2, 3, 4]（顺序不保证）

# 子集与超集判断
{1, 2}.issubset({1, 2, 3})    # True
{1, 2, 3}.issuperset({1, 2})  # True
```

### 9.4 字典（dict）：键值对映射

```python
user = {
    "name": "Alice",
    "age": 25,
    "email": "alice@example.com"
}

# 访问
user["name"]                  # "Alice"（不存在时报 KeyError）
user.get("phone")             # None（不存在时返回 None，不报错）
user.get("phone", "N/A")      # "N/A"（自定义默认值）

# 修改与添加
user["age"] = 26
user["city"] = "Beijing"

# 删除
del user["email"]
popped = user.pop("city")
popped = user.pop("country", None)    # 不存在时返回 None

# 遍历
for key in user:                      # 遍历键
    print(key)
for key, value in user.items():       # 遍历键值对（最常用）
    print(f"{key}: {value}")
for value in user.values():           # 遍历值
    print(value)

# 常用方法
len(user)                             # 键值对数量
"name" in user                        # True（判断键是否存在）
user.keys()
user.values()
user.items()

# 合并字典（Python 3.9+）
defaults  = {"theme": "dark", "lang": "en"}
overrides = {"lang": "zh"}
merged    = defaults | overrides      # {"theme": "dark", "lang": "zh"}

# 字典推导式
squares = {x: x**2 for x in range(5)}   # {0:0, 1:1, 2:4, 3:9, 4:16}
```

---

## 10. 流程控制：条件与循环

### 10.1 条件语句

```python
score = 85

# if / elif / else
if score >= 90:
    grade = "A"
elif score >= 80:
    grade = "B"
elif score >= 70:
    grade = "C"
else:
    grade = "F"

# 三元表达式（一行写完简单条件）
status = "Pass" if score >= 60 else "Fail"

# match 语句（Python 3.10+，类似 switch/case）
command = "quit"
match command:
    case "quit" | "exit":
        print("Goodbye!")
    case "hello":
        print("Hello!")
    case _:                          # 默认分支
        print(f"Unknown: {command}")
```

### 10.2 循环

```python
fruits = ["apple", "banana", "cherry"]

# for 循环：遍历可迭代对象
for fruit in fruits:
    print(fruit)

# range() 生成数字序列
for i in range(5):           # 0, 1, 2, 3, 4
    print(i)
for i in range(1, 10, 2):   # 1, 3, 5, 7, 9（起止步长）
    print(i)

# enumerate：同时获取索引和值
for index, fruit in enumerate(fruits):
    print(f"{index}: {fruit}")
for index, fruit in enumerate(fruits, start=1):  # 从 1 计数
    print(f"{index}. {fruit}")

# zip：同时遍历多个序列
names  = ["Alice", "Bob", "Charlie"]
scores = [90, 85, 92]
for name, score in zip(names, scores):
    print(f"{name}: {score}")

# while 循环
count = 0
while count < 5:
    print(count)
    count += 1

# break 和 continue
for i in range(10):
    if i == 3:
        continue    # 跳过本次迭代，继续下一次
    if i == 7:
        break       # 退出整个循环
    print(i)

# for...else（循环正常结束时执行 else，break 退出则不执行）
for i in range(5):
    if i == 10:
        break
else:
    print("循环正常结束，没有 break")    # 这行会执行
```

---

## 11. 函数：代码复用的基本单元

### 11.1 定义与调用

```python
def greet(name):
    """为指定用户生成问候语。

    Args:
        name: 用户名称字符串

    Returns:
        格式化的问候字符串
    """
    return f"Hello, {name}!"

message = greet("Alice")    # "Hello, Alice!"
```

三引号包裹的字符串是文档字符串（docstring），是 Python 函数文档的标准写法，`help(greet)` 会显示它。

### 11.2 各种参数类型

```python
# 默认参数（有默认值的参数必须放在后面）
def create_user(name, role="user", active=True):
    return {"name": name, "role": role, "active": active}

create_user("Alice")                      # 用默认值
create_user("Bob", role="admin")         # 只覆盖 role

# 关键字参数（调用时明确写参数名，顺序可以任意）
create_user(name="Dave", active=False, role="guest")

# *args：接收任意数量位置参数（打包为元组）
def sum_all(*numbers):
    return sum(numbers)
sum_all(1, 2, 3, 4, 5)    # 15

# **kwargs：接收任意数量关键字参数（打包为字典）
def print_info(**info):
    for key, value in info.items():
        print(f"{key}: {value}")
print_info(name="Alice", age=25, city="Beijing")

# 类型注解（Python 3.5+，不强制执行但提高可读性和工具支持）
def add(x: int, y: int) -> int:
    return x + y

def greet_n(name: str, times: int = 1) -> str:
    return (name + "! ") * times
```

### 11.3 lambda 与高阶函数

```python
# lambda：匿名函数，适合简短的一行逻辑
square = lambda x: x ** 2
square(5)    # 25

# 常与 sorted、map、filter 结合使用
students = [
    {"name": "Alice", "score": 90},
    {"name": "Bob",   "score": 75},
    {"name": "Charlie", "score": 85},
]

# sorted：按分数降序
sorted_students = sorted(students, key=lambda s: s["score"], reverse=True)

# map：对每个元素应用函数
numbers = [1, 2, 3, 4, 5]
squares = list(map(lambda x: x**2, numbers))     # [1, 4, 9, 16, 25]

# filter：过滤满足条件的元素
evens   = list(filter(lambda x: x % 2 == 0, numbers))  # [2, 4]

# 实际工程中，列表推导式通常比 map/filter 更 Pythonic
squares = [x**2 for x in numbers]
evens   = [x for x in numbers if x % 2 == 0]
```

---

## 12. 文件操作与异常处理

### 12.1 文件读写

```python
# 写入文件（w 覆盖，a 追加，encoding 必须明确指定）
with open("output.txt", "w", encoding="utf-8") as f:
    f.write("Hello, File!\n")
    f.write("Second line\n")

# 读取整个文件
with open("output.txt", "r", encoding="utf-8") as f:
    content = f.read()
    print(content)

# 逐行读取（内存友好，适合大文件）
with open("output.txt", "r", encoding="utf-8") as f:
    for line in f:
        print(line.strip())    # strip() 去掉行末换行符

# 读取所有行到列表
with open("output.txt", "r", encoding="utf-8") as f:
    lines = f.readlines()      # ["Hello, File!\n", "Second line\n"]

# 写入多行
lines = ["line1\n", "line2\n", "line3\n"]
with open("output.txt", "w", encoding="utf-8") as f:
    f.writelines(lines)
```

`with` 语句（上下文管理器）会在块结束时**自动关闭文件**，即使发生异常也能正确清理资源，是文件操作的标准写法，始终使用它。

### 12.2 异常处理

```python
# 基础 try/except
try:
    result = 10 / 0
except ZeroDivisionError:
    print("不能除以零")

# 捕获多种异常，获取异常信息
try:
    number = int(input("输入一个数字："))
    result = 100 / number
except ValueError as e:
    print(f"输入不是有效数字：{e}")
except ZeroDivisionError:
    print("不能输入 0")
except Exception as e:          # 捕获所有其他异常（兜底）
    print(f"未知错误：{e}")
else:
    print(f"结果：{result}")    # 没有异常时执行
finally:
    print("无论如何都会执行")   # 清理资源（关闭连接等）

# 主动抛出异常
def set_age(age: int):
    if age < 0:
        raise ValueError(f"年龄不能为负数：{age}")
    if age > 150:
        raise ValueError(f"年龄超出合理范围：{age}")
    return age

# 自定义异常类（让错误类型更有语义）
class InsufficientFundsError(Exception):
    def __init__(self, amount, balance):
        self.amount  = amount
        self.balance = balance
        super().__init__(
            f"余额不足：需要 {amount}，现有 {balance}"
        )

# 使用自定义异常
def withdraw(amount, balance):
    if amount > balance:
        raise InsufficientFundsError(amount, balance)
    return balance - amount
```

---

## 13. 模块与包：组织代码的方式

### 13.1 导入模块

```python
# 导入标准库模块
import os
import sys
import json
import datetime

# 使用模块
os.getcwd()
os.path.join("dir", "file.txt")
datetime.datetime.now()

# 导入特定名称（推荐，明确依赖）
from os.path import join, exists, dirname
from datetime import datetime, timedelta
from pathlib import Path          # 更现代的路径处理方式

# 使用别名（常用于较长的模块名）
import numpy  as np
import pandas as pd

# 不推荐：导入所有（污染命名空间，难以追踪来源）
# from os.path import *
```

### 13.2 项目目录结构

任何 `.py` 文件都是一个模块，包含 `__init__.py` 的目录是一个包：

```
myproject/
├── main.py
├── pyproject.toml
├── requirements.txt
├── .venv/
├── utils/
│   ├── __init__.py          # 使 utils 目录成为包
│   ├── string_utils.py
│   └── file_utils.py
└── models/
    ├── __init__.py
    └── user.py
```

```python
# utils/string_utils.py
def capitalize_words(text: str) -> str:
    return " ".join(word.capitalize() for word in text.split())

# main.py
from utils.string_utils import capitalize_words
from utils import file_utils    # 导入整个子模块

result = capitalize_words("hello world")   # "Hello World"
```

---

# 工程实践篇

## 14. 代码风格：PEP 8 与格式化工具

### 14.1 PEP 8 核心规范

PEP 8 是 Python 官方代码风格指南，遵循它能让代码更易读，在团队合作时减少摩擦：

```python
# 命名约定
variable_name  = "snake_case"    # 变量：小写下划线
CONSTANT_VALUE = 42              # 常量：全大写下划线
def function_name(): pass        # 函数：小写下划线
class ClassName: pass            # 类：大驼峰（PascalCase）

# 缩进：4 个空格，不用 Tab
def example():
    if True:
        print("indented")

# 每行不超过 88 字符
# 用括号换行（比反斜杠更优雅）
result = (
    first_value
    + second_value
    + third_value
)

# 导入顺序：标准库 -> 第三方 -> 本地（组间空一行）
import os
import sys

import requests
import flask

from myapp import utils

# 运算符两侧有空格
x = 5 + 3
result = func(x, y)    # 函数调用参数逗号后有空格
```

### 14.2 自动化工具

手动遵循风格规范很累，用工具自动化：

```bash
# black：最流行的代码格式化工具（零配置，风格一致）
pip install black
black myfile.py              # 格式化单个文件
black .                      # 格式化当前目录所有 .py 文件
black --check .              # 只检查不修改（用于 CI）
black --diff .               # 显示会做哪些修改（预览）

# ruff：超快的 linter + 格式化（用 Rust 编写，强烈推荐）
pip install ruff
ruff check .                 # 检查代码风格和潜在 bug
ruff check --fix .           # 自动修复可修复的问题
ruff format .                # 格式化代码

# mypy：静态类型检查（配合类型注解使用）
pip install mypy
mypy myfile.py
mypy --strict myfile.py      # 严格模式

# 在 pyproject.toml 中统一配置工具，不需要单独配置文件
# [tool.black]
# line-length = 88
#
# [tool.ruff]
# line-length = 88
# select = ["E", "F", "I", "N"]
```

---

## 15. 调试与测试基础

### 15.1 调试技巧

```python
# 最简单：print 调试
def calculate(x, y):
    print(f"DEBUG: x={x}, y={y}")
    result = x * y + x
    print(f"DEBUG: result={result}")
    return result

# 使用内置调试器 pdb
import pdb

def buggy_function(data):
    pdb.set_trace()    # 执行到此处暂停，进入交互调试
    # pdb 常用命令：
    # n (next)       执行下一行
    # s (step)       进入函数内部
    # c (continue)   继续到下一个断点
    # p 变量名        打印变量值
    # q (quit)       退出调试
    result = data * 2
    return result

# Python 3.7+ 推荐：breakpoint()（更简洁，等同于 pdb.set_trace()）
def process(data):
    breakpoint()
    return data * 2
```

### 15.2 单元测试（pytest）

pytest 是 Python 最流行的测试框架，比标准库的 `unittest` 更简洁易用：

```bash
# 安装
pip install pytest pytest-cov
```

```python
# calculator.py
def add(x, y):
    return x + y

def divide(x, y):
    if y == 0:
        raise ValueError("除数不能为零")
    return x / y

# test_calculator.py
# 命名规范：文件以 test_ 开头，函数以 test_ 开头
import pytest
from calculator import add, divide

def test_add_positive():
    assert add(2, 3) == 5

def test_add_negative():
    assert add(-1, 1) == 0

def test_divide_normal():
    assert divide(10, 2) == 5.0

def test_divide_by_zero():
    with pytest.raises(ValueError, match="除数不能为零"):
        divide(10, 0)

# 参数化测试：一个函数跑多组数据
@pytest.mark.parametrize("a, b, expected", [
    (2, 3, 5),
    (0, 0, 0),
    (-1, 1, 0),
    (100, -50, 50),
])
def test_add_parametrized(a, b, expected):
    assert add(a, b) == expected
```

```bash
# 运行测试
pytest                           # 运行当前目录所有测试
pytest test_calculator.py        # 运行指定文件
pytest -v                        # 详细输出（显示每个测试名称）
pytest -k "add"                  # 只运行名称含 "add" 的测试
pytest -x                        # 遇到第一个失败就停止
pytest --cov=.                   # 生成代码覆盖率报告
pytest --cov=. --cov-report=html # 生成 HTML 格式覆盖率报告
```

---

## 16. 常用标准库速览

Python 的"内置电池"标准库非常丰富，熟悉常用模块能避免重复造轮子。

```python
# pathlib：现代文件系统操作（推荐替代 os.path）
from pathlib import Path

p = Path("./mydir/file.txt")
p.parent             # Path('./mydir')
p.name               # 'file.txt'
p.stem               # 'file'
p.suffix             # '.txt'
p.exists()           # 是否存在
p.is_file()
p.is_dir()
p.mkdir(parents=True, exist_ok=True)            # 递归创建目录
p.read_text(encoding="utf-8")                   # 读取文本
p.write_text("content", encoding="utf-8")       # 写入文本
list(Path(".").glob("**/*.py"))                 # 递归查找所有 .py 文件

# json：JSON 序列化与反序列化
import json

data     = {"name": "Alice", "scores": [90, 85, 92]}
json_str = json.dumps(data, ensure_ascii=False, indent=2)  # 对象转字符串
parsed   = json.loads(json_str)                            # 字符串转对象

with open("data.json", "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)       # 写入文件
with open("data.json", "r", encoding="utf-8") as f:
    loaded = json.load(f)                                  # 从文件读取

# datetime：日期时间处理
from datetime import datetime, timedelta

now       = datetime.now()
formatted = now.strftime("%Y-%m-%d %H:%M:%S")    # 格式化
tomorrow  = now + timedelta(days=1)
parsed_dt = datetime.strptime("2026-03-13", "%Y-%m-%d")  # 解析字符串

# collections：扩展数据结构
from collections import Counter, defaultdict, deque

# Counter：计数器
words   = ["apple", "banana", "apple", "cherry", "banana", "apple"]
counter = Counter(words)
print(counter)                 # Counter({'apple': 3, 'banana': 2, 'cherry': 1})
counter.most_common(2)         # [('apple', 3), ('banana', 2)]

# defaultdict：带默认值的字典（避免 KeyError）
graph = defaultdict(list)
graph["A"].append("B")         # 不需要先初始化 graph["A"] = []

# re：正则表达式
import re

text    = "My phone is 138-1234-5678"
pattern = r"\d{3,4}-\d{4,8}"
matches = re.findall(pattern, text)           # ['138-1234-5678']
cleaned = re.sub(r"\d", "*", "secret123")    # 'secret***'
m       = re.match(r"(\w+)\s(\w+)", "Hello World")
print(m.group(1))                             # 'Hello'

# subprocess：执行系统命令
import subprocess

result = subprocess.run(
    ["git", "log", "--oneline", "-5"],
    capture_output=True,
    text=True
)
print(result.stdout)
print(result.returncode)    # 0 表示成功

# os.environ：读取环境变量
import os

db_url   = os.environ.get("DATABASE_URL", "sqlite:///default.db")
api_key  = os.environ["API_KEY"]   # 不存在则报 KeyError
port     = int(os.environ.get("PORT", "8080"))
```

---

## 17. 命令速查总表

### Python 环境命令

| 命令 | 说明 |
|------|------|
| `python3 --version` | 查看 Python 版本 |
| `python3 script.py` | 运行 Python 脚本 |
| `python3` | 进入交互式 REPL |
| `python3 -c "print('hi')"` | 执行单行代码 |
| `python3 -m venv .venv` | 创建虚拟环境 |
| `source .venv/bin/activate` | 激活虚拟环境（macOS/Linux） |
| `.venv\Scripts\activate` | 激活虚拟环境（Windows CMD） |
| `deactivate` | 退出虚拟环境 |
| `which python` | 确认当前 python 路径 |

### pip 包管理

| 命令 | 说明 |
|------|------|
| `python -m pip install --upgrade pip` | 升级 pip |
| `pip install package` | 安装包 |
| `pip install package==1.2.3` | 安装指定版本 |
| `pip install "pkg>=1.0,<2.0"` | 安装版本范围 |
| `pip install -r requirements.txt` | 批量安装 |
| `pip install -e .` | 可编辑模式安装本地包 |
| `pip install -e ".[dev]"` | 安装含 dev 依赖 |
| `pip list` | 查看已安装包 |
| `pip list --outdated` | 查看可更新的包 |
| `pip show package` | 查看包详情 |
| `pip freeze > requirements.txt` | 导出依赖快照 |
| `pip uninstall package` | 卸载包 |
| `pip install --upgrade package` | 更新包 |
| `pip config set global.index-url <url>` | 配置镜像源 |

### Conda 环境管理

| 命令 | 说明 |
|------|------|
| `conda --version` | 查看 Conda 版本 |
| `conda update -n base conda` | 更新 Conda 本身 |
| `conda env list` | 查看所有环境 |
| `conda create -n myenv python=3.12` | 创建环境 |
| `conda create -n myenv python=3.11 numpy pandas` | 创建时同步安装包 |
| `conda activate myenv` | 激活环境 |
| `conda deactivate` | 退出环境 |
| `conda env remove -n myenv --all` | 删除环境 |
| `conda install numpy` | 安装包 |
| `conda install -c conda-forge package` | 从 conda-forge 安装 |
| `conda list` | 查看已安装包 |
| `conda update --all` | 更新所有包 |
| `conda remove package` | 卸载包 |
| `conda env export > environment.yml` | 导出环境 |
| `conda env export --from-history > environment.yml` | 只导出手动安装的包 |
| `conda env create -f environment.yml` | 从文件创建环境 |
| `conda env update -f environment.yml --prune` | 更新已有环境 |
| `conda search package` | 搜索可用包 |
| `conda config --add channels conda-forge` | 添加 conda-forge 频道 |
| `conda config --set auto_activate_base false` | 禁止自动激活 base |

### pyenv 版本管理

| 命令 | 说明 |
|------|------|
| `pyenv install --list` | 查看可安装版本 |
| `pyenv install 3.12.2` | 安装指定版本 |
| `pyenv global 3.12.2` | 设置全局默认版本 |
| `pyenv local 3.11.8` | 设置目录局部版本 |
| `pyenv versions` | 查看所有已安装版本 |
| `pyenv version` | 查看当前使用版本 |

### 代码质量工具

| 命令 | 说明 |
|------|------|
| `black .` | 格式化所有代码 |
| `black --check .` | 检查格式（不修改，用于 CI）|
| `ruff check .` | Lint 检查 |
| `ruff check --fix .` | 自动修复 Lint 问题 |
| `ruff format .` | 格式化代码 |
| `mypy myfile.py` | 静态类型检查 |
| `pytest` | 运行所有测试 |
| `pytest -v` | 详细测试输出 |
| `pytest -k "add"` | 只运行名称含关键词的测试 |
| `pytest --cov=.` | 生成覆盖率报告 |

---

## 18. 延伸阅读

### 官方文档

- [**Python 官方文档（中文）**](https://docs.python.org/zh-cn/3/)：最权威的 Python 3 完整参考，含教程、标准库文档和语言规范
- [**Python 标准库文档**](https://docs.python.org/zh-cn/3/library/)：所有内置模块的详细说明
- [**PEP 8 风格指南**](https://peps.python.org/pep-0008/)：Python 代码风格的权威规范

### 学习资源

- [**Python 官方入门教程（中文）**](https://docs.python.org/zh-cn/3/tutorial/)：适合有编程基础的快速入门，官方出品质量有保障
- [**廖雪峰 Python 教程**](https://www.liaoxuefeng.com/wiki/1016959663602400)：面向中文读者的系统入门教程，覆盖面广
- [**Real Python**](https://realpython.com/)：高质量英文 Python 教程，从基础到进阶主题都有覆盖

### 进阶书籍

- [**《流畅的 Python》（Fluent Python）**](https://book.douban.com/subject/27028517/)：深入理解 Python 特性的进阶读物，强烈推荐
- [**《Python 工匠》**](https://book.douban.com/subject/35723705/)：国内作者写的 Python 最佳实践书籍，贴近工程实际

### 工具文档

- [**pip 文档**](https://pip.pypa.io/en/stable/)：pip 所有命令和配置的完整说明
- [**Conda 文档**](https://docs.conda.io/projects/conda/en/stable/)：环境和包管理完整参考
- [**pyenv 文档**](https://github.com/pyenv/pyenv)：多版本 Python 管理工具
- [**pytest 文档**](https://docs.pytest.org/en/stable/)：Python 测试框架完整文档
- [**black 文档**](https://black.readthedocs.io/en/stable/)：代码格式化工具
- [**ruff 文档**](https://docs.astral.sh/ruff/)：超快 Linter 工具文档
- [**FastAPI 官方文档（中文）**](https://fastapi.tiangolo.com/zh/)：现代 Python Web 框架，文档极佳

---

*本文档持续维护更新。如有错误或建议，欢迎提交 Issue 或 PR。*