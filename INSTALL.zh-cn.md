# Redroid 一键安装脚本使用说明

## 简介

这是一个自动化安装脚本，可以在多种 Linux 发行版上快速部署 Redroid 环境。

## 支持的系统

- ✅ Ubuntu (18.04, 20.04, 22.04+)
- ✅ Debian (11, 12)
- ✅ Linux Mint
- ✅ Pop!_OS
- ✅ CentOS / RHEL / AlmaLinux / Rocky Linux
- ✅ Fedora (38, 39+)
- ✅ Arch Linux / Manjaro
- ✅ Deepin (20.9, 23)
- ✅ Gentoo
- ✅ openEuler
- ✅ openKylin
- ✅ Amazon Linux
- ✅ Alibaba Cloud Linux
- ✅ WSL2

## 系统要求

### 必需的内核特性
- `binderfs` - Android Binder IPC 支持
- `ashmem` / `memfd` - 共享内存支持
- `IPv6` - 网络支持
- `ION` / `DMA-BUF Heaps` - 图形缓冲区支持
- 4KB 页面大小

### 各系统内核要求

| 系统 | 最低内核版本 | 推荐版本 | 说明 |
|------|------------|---------|------|
| **Ubuntu 22.04+** | 默认内核 | 默认内核 | 开箱即用 ✅ |
| **Ubuntu 20.04** | 默认内核 | 默认内核 | 开箱即用 ✅ |
| **Ubuntu 18.04** | 5.0+ | 5.4+ | 需安装 HWE 内核 |
| **Debian 12** | 默认内核 | 默认内核 | 开箱即用 ✅ |
| **Debian 11** | 默认内核 | 默认内核 | 开箱即用 ✅ |
| **Fedora 38+** | 默认内核 | 默认内核 | 开箱即用 ✅ |
| **Arch Linux** | 默认内核 | linux-zen | 推荐 zen 内核 |
| **CentOS/RHEL** | 5.10+ | 自定义内核 | 需自定义内核或 redroid-modules ⚠️ |
| **Amazon Linux** | 4.14 / 5.4 | 5.10+ | 需 redroid-modules ⚠️ |
| **Pop!_OS** | 默认内核 | linux-xanmod | 推荐 xanmod 内核 |
| **Linux Mint** | 同 Ubuntu | 同 Ubuntu | 与 Ubuntu 相同 ✅ |
| **Deepin 23** | 默认内核 | 默认内核 | 开箱即用 ✅ |
| **Deepin 20.9** | 默认内核 | 默认内核 | 需设置权限，单容器 ⚠️ |
| **Gentoo** | 5.18.5+ | 5.18.5+ | 开箱即用 ✅ |
| **openEuler** | 5.10 LTS | 自定义内核 | 需自定义内核 ⚠️ |
| **openKylin 2** | 默认内核 | 默认内核 | 需设置权限，单容器 ⚠️ |
| **WSL2** | 5.10/5.15 | 自定义内核 | 需自定义内核 ⚠️ |

### 硬件要求
- CPU: x86_64 或 ARM64
- 内存: 至少 2GB (推荐 4GB+)
- 存储: 至少 10GB 可用空间

## 快速开始

### 1. 下载并运行安装脚本

```bash
# 下载脚本
wget https://raw.githubusercontent.com/your-repo/install-redroid.sh

# 或使用 curl
curl -O https://raw.githubusercontent.com/your-repo/install-redroid.sh

# 添加执行权限
chmod +x install-redroid.sh

# 以 root 权限运行
sudo bash install-redroid.sh
```

### 2. 脚本会自动完成以下操作

1. ✅ 检测系统类型和版本
2. ✅ 检查内核版本和必需特性
3. ✅ 安装 Docker (如果未安装)
4. ✅ 加载必需的内核模块
5. ✅ 配置系统环境 (禁用 SELinux 等)
6. ✅ 创建便捷启动脚本
7. ✅ 可选安装 ADB 工具
8. ✅ 可选测试运行 Redroid

### 3. 启动 Redroid

安装完成后，使用以下命令启动：

```bash
# 使用默认参数启动
start-redroid.sh

# 或自定义参数
start-redroid.sh [容器名] [数据目录] [端口] [Android版本]

# 示例：启动 Android 13
start-redroid.sh redroid13 ~/data-android13 5555 13.0.0_64only-latest
```

### 4. 连接 Redroid

```bash
# 连接 ADB
adb connect localhost:5555

# 查看设备
adb devices

# 安装应用
adb install app.apk
```

### 5. 查看屏幕 (需要 scrcpy)

```bash
# 安装 scrcpy
# Ubuntu/Debian:
sudo apt install scrcpy

# Arch Linux:
sudo pacman -S scrcpy

# 连接并显示屏幕
scrcpy -s localhost:5555
```

## 启动参数说明

### 基本参数

```bash
start-redroid.sh [容器名] [数据目录] [端口] [版本]
```

- **容器名**: Docker 容器名称 (默认: redroid11)
- **数据目录**: 数据持久化目录 (默认: ~/data-redroid)
- **端口**: ADB 端口 (默认: 5555)
- **版本**: Android 版本 (默认: 12.0.0_64only-latest)

### 支持的 Android 版本

| 版本 | 镜像标签 |
|------|---------|
| Android 16 | `16.0.0-latest` / `16.0.0_64only-latest` |
| Android 15 | `15.0.0-latest` / `15.0.0_64only-latest` |
| Android 14 | `14.0.0-latest` / `14.0.0_64only-latest` |
| Android 13 | `13.0.0-latest` / `13.0.0_64only-latest` |
| Android 12 | `12.0.0-latest` / `12.0.0_64only-latest` |
| Android 11 | `11.0.0-latest` |
| Android 10 | `10.0.0-latest` |

### 高级配置

手动启动 Redroid 并自定义显示参数：

```bash
docker run -itd --rm --privileged \
    --pull always \
    -v ~/data:/data \
    -p 5555:5555 \
    --name redroid \
    redroid/redroid:12.0.0_64only-latest \
    androidboot.redroid_width=1080 \
    androidboot.redroid_height=1920 \
    androidboot.redroid_dpi=480 \
    androidboot.redroid_fps=60
```

### 可用配置参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `androidboot.redroid_width` | 显示宽度 | 720 |
| `androidboot.redroid_height` | 显示高度 | 1280 |
| `androidboot.redroid_fps` | 帧率 | 30 (GPU) / 15 (软件) |
| `androidboot.redroid_dpi` | DPI | 320 |
| `androidboot.use_memfd` | 使用 memfd 替代 ashmem | false |
| `androidboot.redroid_gpu_mode` | GPU 模式: auto/host/guest | guest |

## 各系统特殊说明

### Ubuntu 18.04
**内核要求**: 5.0+

- 默认内核版本过低，需要升级
- 脚本会自动提示安装 HWE 内核
- 升级命令: `sudo apt install linux-generic-hwe-18.04`
- 升级后需要重启系统

### Ubuntu 20.04 / 22.04
**内核要求**: 默认内核即可 ✅

- 默认内核已包含所有必需特性
- 无需额外配置
- 开箱即用

### Debian 11 / 12
**内核要求**: 默认内核即可 ✅

- 默认内核已包含 binder 支持
- 启动容器时需要手动挂载 binder 设备
- 建议启用 `CONFIG_ANDROID_BINDERFS` 以支持多容器

**Debian 启动示例**:
```bash
# 加载 binder 模块
sudo modprobe binder_linux devices=binder1,binder2,binder3,binder4,binder5,binder6
sudo chmod 666 /dev/binder*

# 启动容器时挂载设备
docker run -itd --rm --privileged \
    -v /dev/binder1:/dev/binder \
    -v /dev/binder2:/dev/hwbinder \
    -v /dev/binder3:/dev/vndbinder \
    -v ~/data:/data \
    -p 5555:5555 \
    redroid/redroid:12.0.0_64only-latest
```

### CentOS / RHEL / AlmaLinux / Rocky Linux
**内核要求**: 自定义 5.10+ 内核 ⚠️

- 默认内核**不包含**必需的 Android 特性
- 需要自定义编译内核或使用 redroid-modules
- 必需的内核配置:
  ```
  CONFIG_ANDROID_BINDER_IPC=y
  CONFIG_ANDROID_BINDERFS=y
  CONFIG_ANDROID_BINDER_DEVICES="binder,hwbinder,vndbinder"
  CONFIG_DMABUF_HEAPS=y
  CONFIG_DMABUF_HEAPS_SYSTEM=y
  CONFIG_ASHMEM=y (可选)
  ```
- 参考: [redroid-modules](https://github.com/remote-android/redroid-modules)
- 自动禁用 SELinux

### Fedora 38+
**内核要求**: 默认内核即可 ✅

- Fedora 38 及更高版本默认内核已满足要求
- 需要禁用 SELinux
- Fedora 39+ 需要加载 `nfnetlink` 模块

### Arch Linux / Manjaro
**内核要求**: 默认内核可用，推荐 linux-zen

- 默认内核基本可用
- **强烈推荐**安装 `linux-zen` 内核以获得最佳支持
- 安装命令: `sudo pacman -S linux-zen linux-zen-headers`
- 安装后需要在 GRUB 中选择 zen 内核启动

### Pop!_OS 22.04
**内核要求**: 默认内核可用，推荐 linux-xanmod

- 推荐安装 `linux-xanmod` 内核以获得 binderfs 支持
- 需要在 GRUB 中启用 PSI: `psi=1`
- 参考: [XanMod 官网](https://xanmod.org)

### Amazon Linux
**内核要求**: 需要 redroid-modules ⚠️

- 支持 5.4 / 4.14 内核 (需要 redroid-modules)
- 5.10 内核支持正在开发中
- 需要加载 `fuse` 模块
- 参考: [redroid-modules](https://github.com/remote-android/redroid-modules)

### Alibaba Cloud Linux
**内核要求**: 需要 redroid-modules ⚠️

- 需要使用 redroid-modules 安装必需的内核模块
- 参考: [redroid-modules](https://github.com/remote-android/redroid-modules)

### Linux Mint
**内核要求**: 与 Ubuntu 相同 ✅

- 配置方法与 Ubuntu 完全相同
- 参考 Ubuntu 对应版本的要求

### Deepin 23
**内核要求**: 默认内核即可 ✅

- 默认内核已满足要求
- 可使用 podman 或 docker
- 开箱即用

### Deepin 20.9
**内核要求**: 默认内核可用 ⚠️

- 需要手动设置 binder 设备权限
- 同时只能运行一个容器
- 建议启用 binderfs 以支持多容器

**Deepin 20.9 配置**:
```bash
# 设置 binder 权限
sudo chmod 666 /dev/binder /dev/hwbinder /dev/vndbinder

# 启动容器
podman run -itd --rm --privileged \
    -v ~/data:/data \
    -p 5555:5555 \
    redroid/redroid:12.0.0_64only-latest
```

### Gentoo
**内核要求**: 5.18.5+ ✅

- 5.18.5-gentoo-dist 内核已测试通过
- binderfs 等特性已默认启用
- 开箱即用

### openEuler
**内核要求**: 自定义 5.10 LTS 内核 ⚠️

- 需要自定义编译 5.10 LTS 内核
- 必需的内核配置:
  ```
  CONFIG_DMABUF_HEAPS=y
  CONFIG_DMABUF_HEAPS_SYSTEM=y
  CONFIG_ANDROID_BINDER_IPC=y
  CONFIG_ANDROID_BINDERFS=y
  CONFIG_ASHMEM=y (可选)
  ```
- 参考文档: deploy/openeuler.md

### openKylin 2
**内核要求**: 默认内核可用 ⚠️

- 需要手动设置 binder 设备权限
- 同时只能运行一个容器
- 建议启用 binderfs 以支持多容器

**openKylin 配置**:
```bash
# 设置 binder 权限
sudo chmod 666 /dev/binder /dev/hwbinder /dev/vndbinder

# 启动容器
docker run -itd --rm --privileged \
    -v ~/data:/data \
    -p 5555:5555 \
    redroid/redroid:12.0.0_64only-latest
```

### WSL2
**内核要求**: 自定义内核 5.10/5.15 ⚠️

- 需要自定义编译 WSL2 内核
- 必需启用 Android 相关内核特性
- 参考文档: deploy/wsl.md
- 内核源码: [WSL2-Linux-Kernel](https://github.com/microsoft/WSL2-Linux-Kernel)

## 常见问题

### 1. 容器启动后立即消失

**原因**: 内核模块未正确加载

**解决方法**:
```bash
# 查看系统日志
dmesg -T | tail -50

# 手动加载模块
sudo modprobe binder_linux devices="binder,hwbinder,vndbinder"
sudo modprobe ashmem_linux  # 5.18 之前的内核
```

### 2. ADB 无法连接 (device offline)

**解决方法**:
```bash
# 进入容器检查
docker exec -it redroid11 sh

# 查看进程
ps -A

# 查看日志
logcat
```

### 3. 内核版本过低

**解决方法**:
- Ubuntu: `sudo apt install linux-generic-hwe-$(lsb_release -rs)`
- 其他系统: 参考官方文档升级内核

### 4. SELinux 阻止运行

**解决方法**:
```bash
# 临时禁用
sudo setenforce 0

# 永久禁用 (需重启)
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
```

### 5. GPU 加速不工作

**解决方法**:
```bash
# 启用 host GPU 模式
docker run -itd --rm --privileged \
    -v ~/data:/data \
    -p 5555:5555 \
    --name redroid \
    redroid/redroid:12.0.0_64only-latest \
    androidboot.redroid_gpu_mode=host
```

## 容器管理

### 查看运行中的容器
```bash
docker ps
```

### 停止容器
```bash
docker stop redroid11
```

### 查看容器日志
```bash
docker logs -f redroid11
```

### 删除容器
```bash
docker rm -f redroid11
```

### 清理数据
```bash
# 删除数据目录
rm -rf ~/data-redroid
```

## 性能优化

### 1. 启用 GPU 加速
```bash
androidboot.redroid_gpu_mode=host
```

### 2. 调整分辨率和 DPI
```bash
androidboot.redroid_width=1920
androidboot.redroid_height=1080
androidboot.redroid_dpi=240
```

### 3. 提高帧率
```bash
androidboot.redroid_fps=60
```

### 4. 使用 overlayfs 共享数据
```bash
androidboot.use_redroid_overlayfs=1
```

## 卸载

### 1. 停止并删除所有 Redroid 容器
```bash
docker ps -a | grep redroid | awk '{print $1}' | xargs docker rm -f
```

### 2. 删除镜像
```bash
docker images | grep redroid | awk '{print $3}' | xargs docker rmi
```

### 3. 删除启动脚本
```bash
sudo rm /usr/local/bin/start-redroid.sh
```

### 4. 卸载 Docker (可选)
```bash
# Ubuntu/Debian
sudo apt remove docker-ce docker-ce-cli containerd.io

# CentOS/RHEL/Fedora
sudo yum remove docker-ce docker-ce-cli containerd.io

# Arch Linux
sudo pacman -R docker
```

## 调试工具

### 收集调试信息
```bash
curl -fsSL https://raw.githubusercontent.com/remote-android/redroid-doc/master/debug.sh | sudo bash -s -- redroid11
```

### 检查内核特性
```bash
# 检查 binderfs
ls -la /sys/fs/binder

# 检查 binder 设备
ls -la /dev/binder*

# 检查已加载的模块
lsmod | grep binder
lsmod | grep ashmem
```

## 更多资源

- 📖 官方文档: https://github.com/remote-android/redroid-doc
- 💬 Slack 社区: https://remote-android.slack.com
- 🐛 问题反馈: https://github.com/remote-android/redroid-doc/issues
- 📧 邮件联系: ziyang.zhou@outlook.com

## 许可证

本脚本基于 Apache License 2.0 开源。

Redroid 项目本身也采用 Apache License 2.0，但包含多个第三方模块，请仔细检查相关许可证。
