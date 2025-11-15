# Redroid 系统支持列表

本文档列出了所有支持的 Linux 发行版及其内核要求。

## 图例说明

- ✅ **开箱即用**: 默认内核即可，无需额外配置
- ⚠️ **需要配置**: 需要额外配置或自定义内核
- 🔧 **需要模块**: 需要安装 redroid-modules

## 完整支持列表

| 系统 | 版本 | 内核要求 | 状态 | 说明 |
|------|------|---------|------|------|
| **Ubuntu** | 22.04+ | 默认内核 | ✅ | 开箱即用 |
| **Ubuntu** | 20.04 | 默认内核 | ✅ | 开箱即用 |
| **Ubuntu** | 18.04 | 5.0+ (HWE) | ⚠️ | 需升级内核 |
| **Debian** | 12 | 默认内核 | ✅ | 需挂载 binder 设备 |
| **Debian** | 11 | 默认内核 | ✅ | 需挂载 binder 设备 |
| **Linux Mint** | 所有版本 | 同 Ubuntu | ✅ | 与 Ubuntu 相同 |
| **Pop!_OS** | 22.04 | 默认/xanmod | ⚠️ | 推荐 xanmod 内核 |
| **Fedora** | 39 | 默认内核 | ✅ | 需禁用 SELinux |
| **Fedora** | 38 | 默认内核 | ✅ | 需禁用 SELinux |
| **CentOS** | 所有版本 | 5.10+ 自定义 | ⚠️🔧 | 需自定义内核或 modules |
| **RHEL** | 所有版本 | 5.10+ 自定义 | ⚠️🔧 | 需自定义内核或 modules |
| **AlmaLinux** | 所有版本 | 5.10+ 自定义 | ⚠️🔧 | 需自定义内核或 modules |
| **Rocky Linux** | 所有版本 | 5.10+ 自定义 | ⚠️🔧 | 需自定义内核或 modules |
| **Arch Linux** | 滚动更新 | 默认/zen | ✅ | 推荐 linux-zen |
| **Manjaro** | 所有版本 | 默认/zen | ✅ | 推荐 linux-zen |
| **Deepin** | 23 | 默认内核 | ✅ | 开箱即用 |
| **Deepin** | 20.9 | 默认内核 | ⚠️ | 单容器限制 |
| **Gentoo** | 滚动更新 | 5.18.5+ | ✅ | 开箱即用 |
| **openEuler** | 所有版本 | 5.10 LTS 自定义 | ⚠️ | 需自定义内核 |
| **openKylin** | 2 | 默认内核 | ⚠️ | 单容器限制 |
| **Amazon Linux** | 2 | 5.4 / 4.14 | 🔧 | 需 redroid-modules |
| **Alibaba Cloud** | 所有版本 | - | 🔧 | 需 redroid-modules |
| **WSL2** | Windows 11 | 5.10/5.15 自定义 | ⚠️ | 需自定义内核 |

## 详细说明

### 开箱即用系统 ✅

这些系统的默认内核已包含所有必需特性，安装脚本后即可直接使用：

1. **Ubuntu 20.04 / 22.04**
2. **Debian 11 / 12**
3. **Linux Mint** (基于 Ubuntu)
4. **Fedora 38+**
5. **Arch Linux / Manjaro**
6. **Deepin 23**
7. **Gentoo** (5.18.5+)

### 需要简单配置的系统 ⚠️

这些系统需要一些额外配置，但不需要重新编译内核：

1. **Ubuntu 18.04**: 安装 HWE 内核
   ```bash
   sudo apt install linux-generic-hwe-18.04
   ```

2. **Debian 11/12**: 需要手动挂载 binder 设备
   ```bash
   -v /dev/binder1:/dev/binder \
   -v /dev/binder2:/dev/hwbinder \
   -v /dev/binder3:/dev/vndbinder
   ```

3. **Pop!_OS**: 建议安装 xanmod 内核
   - 参考: https://xanmod.org

4. **Deepin 20.9 / openKylin 2**: 设置 binder 权限
   ```bash
   sudo chmod 666 /dev/binder /dev/hwbinder /dev/vndbinder
   ```
   注意: 同时只能运行一个容器

### 需要自定义内核的系统 ⚠️

这些系统需要重新编译内核并启用特定特性：

1. **CentOS / RHEL / AlmaLinux / Rocky Linux**
   - 需要 5.10+ 内核
   - 必需配置:
     ```
     CONFIG_ANDROID_BINDER_IPC=y
     CONFIG_ANDROID_BINDERFS=y
     CONFIG_DMABUF_HEAPS=y
     ```

2. **openEuler**
   - 需要 5.10 LTS 内核
   - 配置同上

3. **WSL2**
   - 需要自定义 WSL2 内核
   - 下载源码: https://github.com/microsoft/WSL2-Linux-Kernel

### 需要 redroid-modules 的系统 🔧

这些系统可以通过安装预编译的内核模块来支持 Redroid：

1. **Amazon Linux** (5.4 / 4.14 内核)
2. **Alibaba Cloud Linux**
3. **CentOS / RHEL** (替代方案)

redroid-modules 项目: https://github.com/remote-android/redroid-modules

## 内核特性要求

所有系统都需要以下内核特性：

### 必需特性
- `CONFIG_ANDROID_BINDER_IPC=y` - Binder IPC 支持
- `CONFIG_ANDROID_BINDERFS=y` - Binderfs 文件系统
- `CONFIG_ANDROID_BINDER_DEVICES="binder,hwbinder,vndbinder"` - Binder 设备
- `CONFIG_IPV6=y` - IPv6 支持
- 4KB 页面大小

### 推荐特性
- `CONFIG_DMABUF_HEAPS=y` - DMA-BUF Heaps (新内核)
- `CONFIG_DMABUF_HEAPS_SYSTEM=y` - System heap
- 或 `CONFIG_ION=y` - ION 内存管理器 (旧内核)

### 可选特性
- `CONFIG_ASHMEM=y` - Ashmem 共享内存 (5.18 之前)
- 5.18+ 内核可使用 memfd 替代

## 推荐配置

### 最佳选择 (生产环境)
1. **Ubuntu 22.04 LTS** - 长期支持，稳定可靠
2. **Debian 12** - 稳定性极佳
3. **Fedora 39** - 最新特性

### 最佳选择 (开发环境)
1. **Arch Linux + linux-zen** - 最新内核，性能最佳
2. **Gentoo** - 高度可定制
3. **Ubuntu 22.04** - 易用性好

### 云服务器
1. **Ubuntu 20.04/22.04** - 广泛支持
2. **Debian 11/12** - 稳定可靠
3. **Amazon Linux** - AWS 环境 (需 redroid-modules)

## 检查系统兼容性

使用提供的检查脚本：

```bash
sudo bash check-kernel.sh
```

该脚本会检查：
- 系统类型和版本
- 内核版本
- 必需的内核特性
- Docker 安装状态
- SELinux 状态
- 系统资源

## 获取帮助

- 📖 官方文档: https://github.com/remote-android/redroid-doc
- 💬 Slack 社区: https://remote-android.slack.com
- 🐛 问题反馈: https://github.com/remote-android/redroid-doc/issues

## 参考文档

每个系统的详细配置请参考 `deploy/` 目录下的对应文档：

- `deploy/ubuntu.md`
- `deploy/debian.md`
- `deploy/centos.md`
- `deploy/fedora.md`
- `deploy/arch-linux.md`
- `deploy/deepin.md`
- `deploy/gentoo.md`
- `deploy/openeuler.md`
- `deploy/openkylin.md`
- `deploy/amazon-linux.md`
- `deploy/alibaba-cloud-linux.md`
- `deploy/pop_os.md`
- `deploy/mint.md`
- `deploy/wsl.md`
