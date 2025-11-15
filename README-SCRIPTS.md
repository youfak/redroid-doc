# Redroid 一键安装脚本

这是一套完整的 Redroid 自动化安装和检查工具，支持多种 Linux 发行版。

## 📦 包含文件

| 文件 | 说明 |
|------|------|
| `install-redroid.sh` | 主安装脚本，自动检测系统并配置环境 |
| `check-kernel.sh` | 系统兼容性检查工具 |
| `INSTALL.zh-cn.md` | 详细的中文安装和使用文档 |
| `SYSTEMS.md` | 完整的系统支持列表和要求 |

## 🚀 快速开始

### 1. 检查系统兼容性

在安装前，先检查你的系统是否满足要求：

```bash
sudo bash check-kernel.sh
```

这会检查：
- ✅ 系统类型和版本
- ✅ 内核版本和特性
- ✅ Docker 安装状态
- ✅ 必需的内核模块
- ✅ 系统资源 (内存、磁盘)

### 2. 运行安装脚本

如果检查通过，运行安装脚本：

```bash
sudo bash install-redroid.sh
```

脚本会自动：
1. 检测你的 Linux 发行版
2. 安装 Docker (如果未安装)
3. 加载必需的内核模块
4. 配置系统环境
5. 创建便捷启动脚本
6. 可选安装 ADB 工具
7. 可选测试运行 Redroid

### 3. 启动 Redroid

安装完成后，使用生成的启动脚本：

```bash
# 使用默认参数
start-redroid.sh

# 或自定义参数
start-redroid.sh [容器名] [数据目录] [端口] [Android版本]

# 示例
start-redroid.sh redroid13 ~/android-data 5555 13.0.0_64only-latest
```

### 4. 连接 Redroid

```bash
# 连接 ADB
adb connect localhost:5555

# 查看屏幕 (需要 scrcpy)
scrcpy -s localhost:5555
```

## 📋 支持的系统

### 开箱即用 ✅
- Ubuntu 20.04 / 22.04
- Debian 11 / 12
- Fedora 38+
- Arch Linux / Manjaro
- Gentoo (5.18.5+)
- Deepin 23
- Linux Mint

### 需要简单配置 ⚠️
- Ubuntu 18.04 (需升级内核)
- Pop!_OS (推荐 xanmod 内核)
- Deepin 20.9 (单容器限制)
- openKylin 2 (单容器限制)

### 需要自定义内核 🔧
- CentOS / RHEL / AlmaLinux / Rocky
- openEuler
- WSL2

### 需要 redroid-modules 📦
- Amazon Linux
- Alibaba Cloud Linux

详细列表请查看 [SYSTEMS.md](SYSTEMS.md)

## 📖 文档

- **[INSTALL.zh-cn.md](INSTALL.zh-cn.md)** - 完整的安装和使用指南
  - 系统要求
  - 安装步骤
  - 配置参数
  - 常见问题
  - 故障排除

- **[SYSTEMS.md](SYSTEMS.md)** - 系统支持列表
  - 所有支持的发行版
  - 内核要求详情
  - 推荐配置
  - 特殊说明

## 🔍 脚本功能详解

### install-redroid.sh

**主要功能**:
- 自动检测 17+ 种 Linux 发行版
- 智能判断内核版本要求
- 自动安装和配置 Docker
- 加载必需的内核模块
- 配置系统环境 (SELinux 等)
- 生成便捷启动脚本
- 可选安装 ADB 工具
- 可选测试运行

**支持的系统**:
- Ubuntu (18.04, 20.04, 22.04+)
- Debian (11, 12)
- CentOS / RHEL / AlmaLinux / Rocky
- Fedora (38, 39+)
- Arch Linux / Manjaro
- Deepin (20.9, 23)
- Gentoo
- openEuler
- openKylin
- Pop!_OS
- Linux Mint
- Amazon Linux
- Alibaba Cloud Linux

### check-kernel.sh

**检查项目**:
- ✅ 系统架构 (x86_64 / aarch64)
- ✅ 内核版本 (针对不同系统)
- ✅ binderfs 支持
- ✅ binder 设备
- ✅ ashmem / memfd
- ✅ IPv6 支持
- ✅ 页面大小 (4KB)
- ✅ DMA-BUF / ION
- ✅ Docker 安装
- ✅ SELinux 状态
- ✅ 系统内存
- ✅ 磁盘空间

**输出结果**:
- 通过项数量
- 警告项数量
- 失败项数量
- 针对性的修复建议

## 🎯 使用场景

### 场景 1: 开发测试
```bash
# 快速启动一个 Android 12 实例
start-redroid.sh dev-test ~/test-data 5555 12.0.0_64only-latest
```

### 场景 2: 多版本测试
```bash
# Android 11
start-redroid.sh android11 ~/data11 5551 11.0.0-latest

# Android 12
start-redroid.sh android12 ~/data12 5552 12.0.0-latest

# Android 13
start-redroid.sh android13 ~/data13 5553 13.0.0-latest
```

### 场景 3: 云服务器部署
```bash
# 1. 检查兼容性
sudo bash check-kernel.sh

# 2. 安装环境
sudo bash install-redroid.sh

# 3. 启动服务
start-redroid.sh production ~/prod-data 5555 14.0.0_64only-latest

# 4. 远程连接
adb connect your-server-ip:5555
```

## ⚙️ 高级配置

### 自定义显示参数

```bash
docker run -itd --rm --privileged \
    -v ~/data:/data \
    -p 5555:5555 \
    --name redroid \
    redroid/redroid:12.0.0_64only-latest \
    androidboot.redroid_width=1920 \
    androidboot.redroid_height=1080 \
    androidboot.redroid_dpi=240 \
    androidboot.redroid_fps=60
```

### 启用 GPU 加速

```bash
androidboot.redroid_gpu_mode=host
```

### 使用 memfd (5.18+ 内核)

```bash
androidboot.use_memfd=true
```

### 配置网络代理

```bash
androidboot.redroid_net_proxy_type=static \
androidboot.redroid_net_proxy_host=proxy.example.com \
androidboot.redroid_net_proxy_port=8080
```

## 🐛 故障排除

### 容器启动后立即消失

```bash
# 查看系统日志
dmesg -T | tail -50

# 检查内核模块
lsmod | grep binder
lsmod | grep ashmem

# 手动加载模块
sudo modprobe binder_linux devices="binder,hwbinder,vndbinder"
```

### ADB 无法连接

```bash
# 进入容器检查
docker exec -it redroid sh

# 查看进程
ps -A

# 查看日志
logcat
```

### 内核版本不满足

```bash
# Ubuntu 18.04 升级内核
sudo apt install linux-generic-hwe-18.04

# Arch Linux 安装 zen 内核
sudo pacman -S linux-zen

# 重启系统
sudo reboot
```

## 📚 更多资源

- 🌐 官方项目: https://github.com/remote-android/redroid-doc
- 💬 Slack 社区: https://remote-android.slack.com
- 📖 内核模块: https://github.com/remote-android/redroid-modules
- 🔧 ADB 工具: https://developer.android.com/studio#downloads
- 🖥️ scrcpy: https://github.com/Genymobile/scrcpy

## 📝 许可证

本脚本基于 Apache License 2.0 开源。

Redroid 项目本身也采用 Apache License 2.0，但包含多个第三方模块，请仔细检查相关许可证。

## 🤝 贡献

欢迎提交问题和改进建议！

---

**注意**: 请勿在公网暴露 ADB 端口 (5555)，否则可能导致安全问题。
