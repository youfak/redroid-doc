#!/bin/bash

################################################################################
# Redroid 一键安装脚本
# 支持自动检测系统并安装所需环境
# 作者: Auto-generated
# 日期: 2025-11-15
################################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为 root 用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用 root 权限运行此脚本"
        log_info "使用方法: sudo bash $0"
        exit 1
    fi
}

# 检测系统类型
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
        OS_NAME=$NAME
    elif [ -f /etc/redhat-release ]; then
        OS="centos"
        OS_NAME="CentOS"
    else
        log_error "无法检测操作系统类型"
        exit 1
    fi
    
    log_info "检测到系统: $OS_NAME $OS_VERSION"
}

# 检查内核版本
check_kernel() {
    KERNEL_VERSION=$(uname -r)
    KERNEL_MAJOR=$(echo $KERNEL_VERSION | cut -d. -f1)
    KERNEL_MINOR=$(echo $KERNEL_VERSION | cut -d. -f2)
    
    log_info "当前内核版本: $KERNEL_VERSION"
    
    # 根据文档要求，针对不同系统检查内核
    case $OS in
        ubuntu)
            # Ubuntu 18.04: 明确要求升级到 5.0+
            if [ "$OS_VERSION" = "18.04" ]; then
                if [ "$KERNEL_MAJOR" -lt 5 ]; then
                    log_error "Ubuntu 18.04 必须升级内核到 5.0+ 才能运行 Redroid"
                    log_info "当前内核: $KERNEL_VERSION (不满足要求)"
                    return 1
                else
                    log_success "内核版本满足 Ubuntu 18.04 要求 (>= 5.0)"
                fi
            # Ubuntu 20.04/22.04: 默认内核即可
            elif [ "$OS_VERSION" = "20.04" ] || [ "$OS_VERSION" = "22.04" ]; then
                log_success "Ubuntu $OS_VERSION 默认内核满足要求"
            else
                # 其他 Ubuntu 版本：通用检查
                if [ "$KERNEL_MAJOR" -ge 5 ]; then
                    log_success "内核版本满足要求"
                else
                    log_warning "内核版本较低，建议升级到 5.0+"
                fi
            fi
            ;;
            
        debian)
            # Debian 11/12: 文档显示默认内核即可，无特殊版本要求
            if [ "$OS_VERSION" = "11" ] || [ "$OS_VERSION" = "12" ]; then
                log_success "Debian $OS_VERSION 默认内核已包含 binder 支持"
            else
                log_warning "建议使用 Debian 11 或 12"
            fi
            ;;
            
        centos|rhel|almalinux|rocky)
            # CentOS/RHEL: 文档明确要求自定义 5.10 内核
            log_warning "CentOS/RHEL 默认内核不支持 Redroid"
            log_warning "必须使用自定义 5.10+ 内核或安装 redroid-modules"
            log_info "当前内核: $KERNEL_VERSION"
            log_info "参考文档: deploy/centos.md"
            log_info "redroid-modules: https://github.com/remote-android/redroid-modules"
            # 不返回错误，让用户决定是否继续
            ;;
            
        fedora)
            # Fedora 38/39: 文档显示默认内核即可
            if [ -n "$OS_VERSION" ]; then
                if [ "$OS_VERSION" -ge 38 ]; then
                    log_success "Fedora $OS_VERSION 默认内核满足要求"
                else
                    log_warning "建议使用 Fedora 38 或更高版本"
                    log_info "当前版本: Fedora $OS_VERSION"
                fi
            else
                log_info "无法确定 Fedora 版本，建议使用 Fedora 38+"
            fi
            ;;
            
        arch|manjaro)
            # Arch Linux: 文档建议安装 zen 内核，但不是强制要求
            if uname -r | grep -q "zen"; then
                log_success "正在使用 linux-zen 内核 (推荐配置)"
            else
                log_info "当前使用默认内核"
                log_info "建议安装 linux-zen 内核以获得最佳支持"
            fi
            ;;
            
        amzn)
            # Amazon Linux: 文档明确支持 5.4 和 4.14 (需要 redroid-modules)
            if [ "$KERNEL_MAJOR" -eq 5 ] && [ "$KERNEL_MINOR" -eq 4 ]; then
                log_success "Amazon Linux 5.4 内核 (需要 redroid-modules)"
                log_info "参考: https://github.com/remote-android/redroid-modules"
            elif [ "$KERNEL_MAJOR" -eq 4 ] && [ "$KERNEL_MINOR" -eq 14 ]; then
                log_success "Amazon Linux 4.14 内核 (需要 redroid-modules)"
                log_info "参考: https://github.com/remote-android/redroid-modules"
            else
                log_warning "Amazon Linux 当前仅支持 5.4 和 4.14 内核"
                log_info "当前内核: $KERNEL_VERSION"
                log_info "5.10 内核支持正在开发中"
            fi
            ;;
            
        pop)
            # Pop!_OS: 类似 Ubuntu，建议安装 xanmod 内核
            log_info "Pop!_OS 建议安装 linux-xanmod 内核"
            if [ "$KERNEL_MAJOR" -ge 5 ]; then
                log_success "当前内核版本基本满足要求"
            else
                log_warning "内核版本较低，建议升级"
            fi
            ;;
            
        linuxmint|mint)
            # Linux Mint: 与 Ubuntu 相同
            log_info "Linux Mint 配置与 Ubuntu 相同"
            if [ "$KERNEL_MAJOR" -ge 5 ]; then
                log_success "内核版本满足要求"
            else
                log_warning "建议升级内核到 5.0+"
            fi
            ;;
            
        deepin)
            # Deepin 23: 默认内核即可
            # Deepin 20.9: 需要手动设置 binder 权限
            if [ -n "$OS_VERSION" ]; then
                if [[ "$OS_VERSION" =~ ^23 ]]; then
                    log_success "Deepin 23 默认内核满足要求"
                elif [[ "$OS_VERSION" =~ ^20 ]]; then
                    log_info "Deepin 20.9 需要手动设置 binder 权限"
                    log_info "注意: 同时只能运行一个容器，除非启用 binderfs"
                else
                    log_info "Deepin 版本: $OS_VERSION"
                fi
            fi
            log_success "Deepin 系统基本满足要求"
            ;;
            
        gentoo)
            # Gentoo: 5.18.5+ 内核已包含所需特性
            if [ "$KERNEL_MAJOR" -ge 5 ] && [ "$KERNEL_MINOR" -ge 18 ]; then
                log_success "Gentoo 内核已包含 binderfs 等特性"
            else
                log_warning "建议使用 5.18+ 内核"
            fi
            ;;
            
        openeuler)
            # openEuler: 需要自定义 5.10 LTS 内核
            log_warning "openEuler 需要自定义 5.10 LTS 内核"
            log_info "必需的内核配置:"
            log_info "  - CONFIG_ANDROID_BINDER_IPC=y"
            log_info "  - CONFIG_ANDROID_BINDERFS=y"
            log_info "  - CONFIG_DMABUF_HEAPS=y"
            log_info "参考文档: deploy/openeuler.md"
            ;;
            
        openkylin)
            # openKylin 2: 需要手动设置 binder 权限
            log_info "openKylin 2 需要手动设置 binder 权限"
            log_info "注意: 同时只能运行一个容器，除非启用 binderfs"
            log_success "openKylin 系统基本满足要求"
            ;;
            
        *)
            # 未知系统：通用检查
            log_warning "未识别的系统: $OS"
            if [ "$KERNEL_MAJOR" -lt 4 ] || ([ "$KERNEL_MAJOR" -eq 4 ] && [ "$KERNEL_MINOR" -lt 14 ]); then
                log_error "内核版本过低 (< 4.14)，无法运行 Redroid"
                return 1
            elif [ "$KERNEL_MAJOR" -lt 5 ]; then
                log_warning "内核版本较低 (< 5.0)，可能需要 redroid-modules"
                log_info "参考: https://github.com/remote-android/redroid-modules"
            else
                log_success "内核版本基本满足要求"
            fi
            ;;
    esac
    
    return 0
}

# 检查必需的内核特性
check_kernel_features() {
    log_info "检查内核特性..."
    
    local missing_features=0
    
    # 检查 binderfs
    if [ -d /sys/fs/binder ]; then
        log_success "binderfs 支持已启用"
    else
        log_warning "binderfs 可能未启用"
        missing_features=$((missing_features + 1))
    fi
    
    # 检查 IPv6
    if [ -f /proc/net/if_inet6 ]; then
        log_success "IPv6 支持已启用"
    else
        log_warning "IPv6 未启用"
        missing_features=$((missing_features + 1))
    fi
    
    # 检查页面大小
    PAGE_SIZE=$(getconf PAGE_SIZE)
    if [ "$PAGE_SIZE" -eq 4096 ]; then
        log_success "页面大小为 4KB"
    else
        log_warning "页面大小不是 4KB: $PAGE_SIZE"
    fi
    
    return $missing_features
}

# 安装 Docker
install_docker() {
    log_info "检查 Docker 安装状态..."
    
    if command -v docker &> /dev/null; then
        log_success "Docker 已安装: $(docker --version)"
        return 0
    fi
    
    log_info "开始安装 Docker..."
    
    case $OS in
        ubuntu|debian|linuxmint|pop)
            # 安装依赖
            apt-get update
            apt-get install -y ca-certificates curl gnupg lsb-release
            
            # 添加 Docker 官方 GPG key
            install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/$OS/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            chmod a+r /etc/apt/keyrings/docker.gpg
            
            # 添加 Docker 仓库
            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS \
              $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            # 安装 Docker
            apt-get update
            apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
            
        centos|rhel|fedora|almalinux|rocky)
            # 安装依赖
            yum install -y yum-utils
            
            # 添加 Docker 仓库
            yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            
            # 安装 Docker
            yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
            
        arch|manjaro)
            pacman -Sy --noconfirm docker
            ;;
            
        *)
            log_error "不支持的系统类型: $OS"
            log_info "请手动安装 Docker: https://docs.docker.com/engine/install/"
            exit 1
            ;;
    esac
    
    # 启动 Docker 服务
    systemctl start docker
    systemctl enable docker
    
    log_success "Docker 安装完成"
}

# Ubuntu/Debian 系统配置
configure_ubuntu_debian() {
    log_info "配置 Ubuntu/Debian 系统..."
    
    # Ubuntu 18.04 特殊处理 - 需要先升级内核
    if [ "$OS" = "ubuntu" ] && [ "$OS_VERSION" = "18.04" ]; then
        log_info "检测到 Ubuntu 18.04"
        if [ "$KERNEL_MAJOR" -lt 5 ]; then
            log_warning "Ubuntu 18.04 需要内核 5.0+ 才能运行 Redroid"
            read -p "是否升级内核到 HWE 版本? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                apt-get update
                apt-get install -y linux-generic-hwe-18.04
                log_success "内核升级完成，请重启系统后再次运行此脚本"
                exit 0
            else
                log_error "内核版本不满足要求，无法继续安装"
                exit 1
            fi
        fi
        
        # 加载可能缺失的模块
        modprobe nfnetlink || true
    fi
    
    # 安装内核模块包
    apt-get update
    apt-get install -y linux-modules-extra-$(uname -r) || true
    
    # 加载 binder 模块
    if ! lsmod | grep -q binder_linux; then
        log_info "加载 binder_linux 模块..."
        if modprobe binder_linux devices="binder,hwbinder,vndbinder" 2>/dev/null; then
            log_success "binder_linux 模块加载成功"
        else
            log_warning "binder_linux 模块加载失败，容器启动时会尝试使用 binderfs"
        fi
    else
        log_success "binder_linux 模块已加载"
    fi
    
    # 加载 ashmem 模块 (仅 5.18 之前的内核需要)
    if [ "$KERNEL_MAJOR" -lt 5 ] || ([ "$KERNEL_MAJOR" -eq 5 ] && [ "$KERNEL_MINOR" -lt 18 ]); then
        if ! lsmod | grep -q ashmem_linux; then
            log_info "加载 ashmem_linux 模块..."
            if modprobe ashmem_linux 2>/dev/null; then
                log_success "ashmem_linux 模块加载成功"
            else
                log_warning "ashmem_linux 模块加载失败，将使用 memfd 替代"
                log_info "启动容器时需添加参数: androidboot.use_memfd=true"
            fi
        else
            log_success "ashmem_linux 模块已加载"
        fi
    else
        log_info "内核 >= 5.18，使用 memfd (无需 ashmem)"
    fi
    
    log_success "Ubuntu/Debian 配置完成"
}

# Debian 特殊配置
configure_debian() {
    log_info "配置 Debian 系统..."
    
    # Debian 11/12 的 binder 设备配置方式不同
    if ! lsmod | grep -q binder_linux; then
        log_info "加载 binder_linux 模块 (Debian 方式)..."
        # Debian 需要创建多个 binder 设备
        if modprobe binder_linux devices=binder1,binder2,binder3,binder4,binder5,binder6 2>/dev/null; then
            log_success "binder_linux 模块加载成功"
            
            # 设置权限
            if ls /dev/binder* &>/dev/null; then
                chmod 666 /dev/binder* 2>/dev/null || true
                log_info "binder 设备权限已设置"
            fi
        else
            log_warning "binder_linux 模块加载失败"
        fi
    else
        log_success "binder_linux 模块已加载"
    fi
    
    log_success "Debian 配置完成"
    log_info ""
    log_info "Debian 启动容器时需要手动挂载 binder 设备:"
    log_info "  -v /dev/binder1:/dev/binder \\"
    log_info "  -v /dev/binder2:/dev/hwbinder \\"
    log_info "  -v /dev/binder3:/dev/vndbinder \\"
    log_info ""
    log_warning "建议在内核中启用 CONFIG_ANDROID_BINDERFS 以支持多容器"
}

# CentOS/RHEL/Fedora 系统配置
configure_redhat() {
    log_info "配置 RedHat 系列系统..."
    
    # 禁用 SELinux
    if command -v getenforce &> /dev/null; then
        if [ "$(getenforce)" != "Disabled" ]; then
            log_info "临时禁用 SELinux..."
            setenforce 0 || true
            
            log_info "永久禁用 SELinux..."
            sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config 2>/dev/null || true
            log_warning "SELinux 已禁用，建议重启系统使配置生效"
        else
            log_success "SELinux 已禁用"
        fi
    fi
    
    # CentOS/RHEL 特殊处理 - 可能需要自定义内核
    if [ "$OS" = "centos" ] || [ "$OS" = "rhel" ] || [ "$OS" = "almalinux" ] || [ "$OS" = "rocky" ]; then
        log_warning "CentOS/RHEL 系统可能需要自定义内核或 redroid-modules"
        log_info "必需的内核特性:"
        log_info "  - CONFIG_ANDROID_BINDER_IPC=y"
        log_info "  - CONFIG_ANDROID_BINDERFS=y"
        log_info "  - CONFIG_DMABUF_HEAPS=y (或 CONFIG_ION=y)"
        log_info "  - CONFIG_ASHMEM=y (可选，可用 memfd 替代)"
        log_info ""
        log_info "参考文档: deploy/centos.md"
        log_info "redroid-modules: https://github.com/remote-android/redroid-modules"
        echo ""
        read -p "是否继续? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "安装已取消"
            exit 0
        fi
    fi
    
    # Fedora 特殊处理
    if [ "$OS" = "fedora" ]; then
        log_info "配置 Fedora 系统..."
        
        # 通过 GRUB 禁用 SELinux
        if command -v grubby &> /dev/null; then
            if ! grep -q "selinux=0" /proc/cmdline; then
                log_info "在 GRUB 中禁用 SELinux..."
                grubby --update-kernel ALL --args selinux=0
                grub2-mkconfig > /boot/grub2/grub.cfg 2>/dev/null || \
                grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null || true
                log_warning "GRUB 配置已更新，建议重启系统"
            fi
        fi
        
        # Fedora 39+ 需要加载 nfnetlink
        if [ -n "$OS_VERSION" ] && [ "$OS_VERSION" -ge 39 ]; then
            modprobe nfnetlink || log_warning "nfnetlink 模块加载失败"
        fi
        
        log_success "Fedora 配置完成"
    fi
    
    # 加载 fuse 模块 (Amazon Linux 等需要)
    modprobe fuse 2>/dev/null || true
    
    log_success "RedHat 系列系统配置完成"
}

# Arch Linux 系统配置
configure_arch() {
    log_info "配置 Arch Linux 系统..."
    
    # 检查是否安装了 zen 内核
    if ! pacman -Qi linux-zen &> /dev/null; then
        log_warning "未安装 linux-zen 内核"
        log_info "linux-zen 内核包含 Redroid 所需的所有特性"
        echo ""
        read -p "是否安装 linux-zen 内核? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            pacman -Sy --noconfirm linux-zen linux-zen-headers
            log_success "linux-zen 内核安装完成"
            log_warning "请重启系统并在 GRUB 中选择 linux-zen 内核启动"
            echo ""
            read -p "是否现在重启? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                reboot
            else
                log_info "请稍后手动重启系统"
                exit 0
            fi
        else
            log_warning "继续使用当前内核，可能需要手动配置内核模块"
        fi
    else
        log_success "linux-zen 内核已安装"
        
        # 检查当前是否运行在 zen 内核
        if uname -r | grep -q "zen"; then
            log_success "当前正在运行 linux-zen 内核"
        else
            log_warning "linux-zen 已安装但未使用，请在 GRUB 中选择 zen 内核启动"
        fi
    fi
    
    log_success "Arch Linux 配置完成"
}

# Pop!_OS 系统配置
configure_popos() {
    log_info "配置 Pop!_OS 系统..."
    
    # 检查是否安装了 xanmod 内核
    if ! dpkg -l | grep -q linux-xanmod; then
        log_info "建议安装 linux-xanmod 内核以获得 binderfs 支持"
        log_info "访问 https://xanmod.org 了解安装方法"
    fi
    
    # 检查 PSI 是否启用
    if ! grep -q "psi=1" /etc/default/grub; then
        log_info "在 GRUB 中启用 PSI..."
        sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 psi=1"/' /etc/default/grub
        update-grub
        log_warning "GRUB 配置已更新，请重启系统使配置生效"
    fi
    
    # 其他配置同 Ubuntu
    configure_ubuntu_debian
    
    log_success "Pop!_OS 配置完成"
}

# Deepin 系统配置
configure_deepin() {
    log_info "配置 Deepin 系统..."
    
    # 检测 Deepin 版本
    if [ -n "$OS_VERSION" ]; then
        if [[ "$OS_VERSION" =~ ^23 ]]; then
            log_info "检测到 Deepin 23"
            # Deepin 23 使用 podman 或 docker
            log_success "Deepin 23 默认内核已满足要求"
        elif [[ "$OS_VERSION" =~ ^20 ]]; then
            log_info "检测到 Deepin 20.9"
            # Deepin 20.9 需要手动设置权限
            if [ -c /dev/binder ]; then
                log_info "设置 binder 设备权限..."
                chmod 666 /dev/binder /dev/hwbinder /dev/vndbinder 2>/dev/null || true
                log_success "binder 设备权限已设置"
            fi
            log_warning "Deepin 20.9 同时只能运行一个容器"
            log_info "建议启用 binderfs 以支持多容器"
        fi
    fi
    
    log_success "Deepin 配置完成"
}

# Gentoo 系统配置
configure_gentoo() {
    log_info "配置 Gentoo 系统..."
    
    # Gentoo 5.18.5+ 内核已包含所需特性
    if [ "$KERNEL_MAJOR" -ge 5 ] && [ "$KERNEL_MINOR" -ge 18 ]; then
        log_success "Gentoo 内核已包含 binderfs 等必需特性"
    else
        log_warning "建议使用 5.18+ 内核"
        log_info "Gentoo 已在 5.18.5-gentoo-dist 内核上测试通过"
    fi
    
    log_success "Gentoo 配置完成"
}

# openEuler 系统配置
configure_openeuler() {
    log_info "配置 openEuler 系统..."
    
    log_warning "openEuler 需要自定义 5.10 LTS 内核"
    log_info "必需的内核配置:"
    log_info "  - CONFIG_DMABUF_HEAPS=y"
    log_info "  - CONFIG_DMABUF_HEAPS_SYSTEM=y"
    log_info "  - CONFIG_ANDROID_BINDER_IPC=y"
    log_info "  - CONFIG_ANDROID_BINDERFS=y"
    log_info "  - CONFIG_ASHMEM=y (可选)"
    log_info ""
    log_info "参考文档: deploy/openeuler.md"
    echo ""
    read -p "是否已配置自定义内核? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "请先配置自定义内核后再继续"
        exit 0
    fi
    
    log_success "openEuler 配置完成"
}

# openKylin 系统配置
configure_openkylin() {
    log_info "配置 openKylin 系统..."
    
    # openKylin 2 需要手动设置权限
    if [ -c /dev/binder ]; then
        log_info "设置 binder 设备权限..."
        chmod 666 /dev/binder /dev/hwbinder /dev/vndbinder 2>/dev/null || true
        log_success "binder 设备权限已设置"
    fi
    
    log_warning "openKylin 同时只能运行一个容器"
    log_info "建议启用 binderfs 以支持多容器"
    
    log_success "openKylin 配置完成"
}

# 通用系统配置
configure_generic() {
    log_info "使用通用配置..."
    
    # 尝试加载常用模块
    log_info "尝试加载内核模块..."
    
    if modprobe binder_linux devices="binder,hwbinder,vndbinder" 2>/dev/null; then
        log_success "binder_linux 模块加载成功"
    else
        log_warning "binder_linux 模块加载失败"
    fi
    
    if modprobe ashmem_linux 2>/dev/null; then
        log_success "ashmem_linux 模块加载成功"
    else
        log_info "ashmem_linux 模块不可用 (可能使用 memfd)"
    fi
    
    modprobe fuse 2>/dev/null || true
    modprobe nfnetlink 2>/dev/null || true
    
    log_success "通用配置完成"
}

# 配置系统
configure_system() {
    case $OS in
        ubuntu|linuxmint|mint)
            configure_ubuntu_debian
            ;;
        debian)
            configure_debian
            ;;
        centos|rhel|almalinux|rocky|fedora)
            configure_redhat
            ;;
        arch|manjaro)
            configure_arch
            ;;
        pop)
            configure_popos
            ;;
        deepin)
            configure_deepin
            ;;
        gentoo)
            configure_gentoo
            ;;
        openeuler)
            configure_openeuler
            ;;
        openkylin)
            configure_openkylin
            ;;
        *)
            log_warning "未识别的系统类型: $OS"
            log_info "将尝试通用配置..."
            configure_generic
            ;;
    esac
}

# 创建启动脚本
create_start_script() {
    log_info "创建 Redroid 启动脚本..."
    
    cat > /usr/local/bin/start-redroid.sh << 'EOF'
#!/bin/bash

# Redroid 启动脚本

CONTAINER_NAME="${1:-redroid11}"
DATA_DIR="${2:-$HOME/data-redroid}"
ADB_PORT="${3:-5555}"
ANDROID_VERSION="${4:-12.0.0_64only-latest}"

# 创建数据目录
mkdir -p "$DATA_DIR"

# 检查容器是否已存在
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "容器 $CONTAINER_NAME 已存在"
    read -p "是否删除并重新创建? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker rm -f "$CONTAINER_NAME"
    else
        echo "取消操作"
        exit 0
    fi
fi

echo "启动 Redroid 容器..."
echo "容器名称: $CONTAINER_NAME"
echo "数据目录: $DATA_DIR"
echo "ADB 端口: $ADB_PORT"
echo "Android 版本: $ANDROID_VERSION"

docker run -itd --rm --privileged \
    --pull always \
    -v "$DATA_DIR":/data \
    -p "$ADB_PORT":5555 \
    --name "$CONTAINER_NAME" \
    redroid/redroid:"$ANDROID_VERSION"

if [ $? -eq 0 ]; then
    echo "Redroid 容器启动成功!"
    echo ""
    echo "连接方法:"
    echo "  adb connect localhost:$ADB_PORT"
    echo ""
    echo "查看屏幕 (需要安装 scrcpy):"
    echo "  scrcpy -s localhost:$ADB_PORT"
    echo ""
    echo "查看日志:"
    echo "  docker logs -f $CONTAINER_NAME"
else
    echo "Redroid 容器启动失败!"
    exit 1
fi
EOF

    chmod +x /usr/local/bin/start-redroid.sh
    log_success "启动脚本已创建: /usr/local/bin/start-redroid.sh"
}

# 安装 ADB 工具
install_adb() {
    log_info "检查 ADB 工具..."
    
    if command -v adb &> /dev/null; then
        log_success "ADB 已安装: $(adb --version | head -n1)"
        return 0
    fi
    
    read -p "是否安装 ADB 工具? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "跳过 ADB 安装"
        return 0
    fi
    
    case $OS in
        ubuntu|debian|linuxmint|pop)
            apt-get install -y android-tools-adb
            ;;
        centos|rhel|fedora|almalinux|rocky)
            yum install -y android-tools || dnf install -y android-tools
            ;;
        arch|manjaro)
            pacman -Sy --noconfirm android-tools
            ;;
        *)
            log_warning "请手动安装 ADB: https://developer.android.com/studio#downloads"
            return 1
            ;;
    esac
    
    log_success "ADB 安装完成"
}

# 测试 Redroid
test_redroid() {
    read -p "是否立即测试运行 Redroid? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 0
    fi
    
    log_info "启动测试容器..."
    
    TEST_CONTAINER="redroid-test"
    TEST_PORT="5555"
    
    # 清理可能存在的测试容器
    docker rm -f "$TEST_CONTAINER" 2>/dev/null || true
    
    # 启动测试容器
    docker run -itd --rm --privileged \
        --pull always \
        -v ~/redroid-test-data:/data \
        -p "$TEST_PORT":5555 \
        --name "$TEST_CONTAINER" \
        redroid/redroid:12.0.0_64only-latest
    
    if [ $? -eq 0 ]; then
        log_success "测试容器启动成功!"
        log_info "等待容器初始化..."
        sleep 10
        
        log_info "容器状态:"
        docker ps | grep "$TEST_CONTAINER"
        
        echo ""
        log_info "测试连接方法:"
        echo "  adb connect localhost:$TEST_PORT"
        echo ""
        log_info "停止测试容器:"
        echo "  docker stop $TEST_CONTAINER"
    else
        log_error "测试容器启动失败"
        log_info "查看详细日志: docker logs $TEST_CONTAINER"
    fi
}

# 显示使用说明
show_usage() {
    echo ""
    echo "=========================================="
    echo "  Redroid 安装完成!"
    echo "=========================================="
    echo ""
    echo "快速启动:"
    echo "  start-redroid.sh [容器名] [数据目录] [端口] [版本]"
    echo ""
    echo "示例:"
    echo "  start-redroid.sh redroid11 ~/data-redroid 5555 12.0.0_64only-latest"
    echo ""
    echo "或使用默认参数:"
    echo "  start-redroid.sh"
    echo ""
    echo "支持的 Android 版本:"
    echo "  - 16.0.0-latest / 16.0.0_64only-latest"
    echo "  - 15.0.0-latest / 15.0.0_64only-latest"
    echo "  - 14.0.0-latest / 14.0.0_64only-latest"
    echo "  - 13.0.0-latest / 13.0.0_64only-latest"
    echo "  - 12.0.0-latest / 12.0.0_64only-latest"
    echo "  - 11.0.0-latest"
    echo "  - 10.0.0-latest"
    echo ""
    echo "连接 Redroid:"
    echo "  adb connect localhost:5555"
    echo ""
    echo "查看屏幕 (需要安装 scrcpy):"
    echo "  scrcpy -s localhost:5555"
    echo ""
    echo "更多信息:"
    echo "  https://github.com/remote-android/redroid-doc"
    echo "=========================================="
    echo ""
}

# 主函数
main() {
    echo "=========================================="
    echo "  Redroid 一键安装脚本"
    echo "=========================================="
    echo ""
    
    # 检查 root 权限
    check_root
    
    # 检测系统
    detect_os
    
    # 检查内核
    if ! check_kernel; then
        log_warning "内核版本可能不满足要求"
    fi
    
    # 检查内核特性
    check_kernel_features || log_warning "部分内核特性可能未启用"
    
    echo ""
    read -p "是否继续安装? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "安装已取消"
        exit 0
    fi
    
    # 安装 Docker
    install_docker
    
    # 配置系统
    configure_system
    
    # 创建启动脚本
    create_start_script
    
    # 安装 ADB
    install_adb
    
    # 测试运行
    test_redroid
    
    # 显示使用说明
    show_usage
    
    log_success "安装完成!"
}

# 运行主函数
main "$@"
