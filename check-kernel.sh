#!/bin/bash

################################################################################
# Redroid 内核特性检查工具
# 用于检查系统是否满足 Redroid 运行要求
################################################################################

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查结果统计
PASSED=0
FAILED=0
WARNING=0

# 打印函数
print_header() {
    echo ""
    echo "=========================================="
    echo "  $1"
    echo "=========================================="
    echo ""
}

print_check() {
    echo -n "检查 $1 ... "
}

print_pass() {
    echo -e "${GREEN}✓ 通过${NC}"
    PASSED=$((PASSED + 1))
}

print_fail() {
    echo -e "${RED}✗ 失败${NC}"
    [ -n "$1" ] && echo -e "  ${RED}原因: $1${NC}"
    FAILED=$((FAILED + 1))
}

print_warn() {
    echo -e "${YELLOW}⚠ 警告${NC}"
    [ -n "$1" ] && echo -e "  ${YELLOW}说明: $1${NC}"
    WARNING=$((WARNING + 1))
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
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
        OS="unknown"
        OS_NAME="Unknown"
    fi
}

# 检查内核版本
check_kernel_version() {
    print_check "内核版本"
    
    KERNEL_VERSION=$(uname -r)
    KERNEL_MAJOR=$(echo $KERNEL_VERSION | cut -d. -f1)
    KERNEL_MINOR=$(echo $KERNEL_VERSION | cut -d. -f2)
    
    echo ""
    print_info "当前内核: $KERNEL_VERSION"
    print_info "系统: $OS_NAME"
    
    # 根据文档要求，针对不同系统检查内核
    case $OS in
        ubuntu)
            # Ubuntu 18.04: 文档明确要求 5.0+
            if [ "$OS_VERSION" = "18.04" ]; then
                if [ "$KERNEL_MAJOR" -lt 5 ]; then
                    print_fail "Ubuntu 18.04 必须升级内核到 5.0+"
                    print_info "升级命令: sudo apt install linux-generic-hwe-18.04"
                    print_info "文档参考: deploy/ubuntu.md"
                    return 1
                else
                    print_pass
                    print_info "满足 Ubuntu 18.04 要求 (>= 5.0)"
                    return 0
                fi
            # Ubuntu 20.04/22.04: 文档显示默认内核即可
            elif [ "$OS_VERSION" = "20.04" ] || [ "$OS_VERSION" = "22.04" ]; then
                print_pass
                print_info "Ubuntu $OS_VERSION 默认内核满足要求"
                return 0
            else
                # 其他版本
                if [ "$KERNEL_MAJOR" -ge 5 ]; then
                    print_pass
                    return 0
                else
                    print_warn "内核版本较低，建议升级到 5.0+"
                    return 0
                fi
            fi
            ;;
            
        debian)
            # Debian 11/12: 文档显示默认内核即可
            if [ "$OS_VERSION" = "11" ] || [ "$OS_VERSION" = "12" ]; then
                print_pass
                print_info "Debian $OS_VERSION 默认内核已包含 binder 支持"
                print_info "文档参考: deploy/debian.md"
                return 0
            else
                print_warn "建议使用 Debian 11 或 12"
                return 0
            fi
            ;;
            
        centos|rhel|almalinux|rocky)
            # CentOS/RHEL: 文档明确要求自定义 5.10 内核
            print_warn "CentOS/RHEL 默认内核不支持 Redroid"
            print_warn "文档要求: 自定义 5.10+ 内核"
            print_info "当前内核: $KERNEL_VERSION"
            print_info ""
            print_info "必需的内核配置:"
            print_info "  CONFIG_ANDROID_BINDER_IPC=y"
            print_info "  CONFIG_ANDROID_BINDERFS=y"
            print_info "  CONFIG_DMABUF_HEAPS=y"
            print_info "  CONFIG_DMABUF_HEAPS_SYSTEM=y"
            print_info ""
            print_info "或使用 redroid-modules:"
            print_info "  https://github.com/remote-android/redroid-modules"
            print_info "文档参考: deploy/centos.md"
            return 0
            ;;
            
        fedora)
            # Fedora 38/39: 文档显示默认内核即可
            if [ -n "$OS_VERSION" ]; then
                if [ "$OS_VERSION" -ge 38 ]; then
                    print_pass
                    print_info "Fedora $OS_VERSION 默认内核满足要求"
                    print_info "文档参考: deploy/fedora.md"
                    return 0
                else
                    print_warn "建议使用 Fedora 38 或更高版本"
                    print_info "当前: Fedora $OS_VERSION"
                    return 0
                fi
            else
                print_warn "无法确定 Fedora 版本"
                print_info "建议使用 Fedora 38+"
                return 0
            fi
            ;;
            
        arch|manjaro)
            # Arch Linux: 文档建议安装 zen 内核
            if uname -r | grep -q "zen"; then
                print_pass
                print_info "正在使用 linux-zen 内核 (推荐配置)"
                print_info "文档参考: deploy/arch-linux.md"
                return 0
            else
                print_warn "建议安装并使用 linux-zen 内核"
                print_info "安装命令: sudo pacman -S linux-zen"
                print_info "文档参考: deploy/arch-linux.md"
                return 0
            fi
            ;;
            
        pop)
            # Pop!_OS: 文档建议安装 xanmod 内核
            if dpkg -l 2>/dev/null | grep -q linux-xanmod; then
                print_pass
                print_info "已安装 linux-xanmod 内核 (推荐)"
                return 0
            else
                print_warn "Pop!_OS 建议安装 linux-xanmod 内核"
                print_info "参考: https://xanmod.org"
                print_info "文档参考: deploy/pop_os.md"
                return 0
            fi
            ;;
            
        linuxmint|mint)
            # Linux Mint: 与 Ubuntu 相同
            print_pass
            print_info "Linux Mint 配置与 Ubuntu 相同"
            print_info "文档参考: deploy/mint.md"
            return 0
            ;;
            
        deepin)
            # Deepin 23: 默认内核即可
            # Deepin 20.9: 需要手动设置权限
            if [ -n "$OS_VERSION" ]; then
                if [[ "$OS_VERSION" =~ ^23 ]]; then
                    print_pass
                    print_info "Deepin 23 默认内核满足要求"
                    print_info "文档参考: deploy/deepin.md"
                    return 0
                elif [[ "$OS_VERSION" =~ ^20 ]]; then
                    print_warn "Deepin 20.9 同时只能运行一个容器"
                    print_info "需要手动设置 binder 权限: chmod 666 /dev/{,hw,vnd}binder"
                    print_info "文档参考: deploy/deepin.md"
                    return 0
                fi
            fi
            print_pass
            print_info "Deepin 系统基本满足要求"
            return 0
            ;;
            
        gentoo)
            # Gentoo: 5.18.5+ 内核已测试通过
            if [ "$KERNEL_MAJOR" -ge 5 ] && [ "$KERNEL_MINOR" -ge 18 ]; then
                print_pass
                print_info "Gentoo 内核已包含 binderfs 等特性"
                print_info "文档参考: deploy/gentoo.md"
                return 0
            else
                print_warn "建议使用 5.18+ 内核"
                print_info "已在 5.18.5-gentoo-dist 上测试通过"
                print_info "文档参考: deploy/gentoo.md"
                return 0
            fi
            ;;
            
        openeuler)
            # openEuler: 需要自定义 5.10 LTS 内核
            print_warn "openEuler 需要自定义 5.10 LTS 内核"
            print_info "必需的内核配置:"
            print_info "  CONFIG_DMABUF_HEAPS=y"
            print_info "  CONFIG_ANDROID_BINDER_IPC=y"
            print_info "  CONFIG_ANDROID_BINDERFS=y"
            print_info "文档参考: deploy/openeuler.md"
            return 0
            ;;
            
        openkylin)
            # openKylin 2: 需要手动设置权限
            print_warn "openKylin 同时只能运行一个容器"
            print_info "需要手动设置 binder 权限: chmod 666 /dev/{,hw,vnd}binder"
            print_info "建议启用 binderfs 以支持多容器"
            print_info "文档参考: deploy/openkylin.md"
            return 0
            ;;
            
        amzn)
            # Amazon Linux: 文档明确支持 5.4 和 4.14 (需要 redroid-modules)
            if [ "$KERNEL_MAJOR" -eq 5 ] && [ "$KERNEL_MINOR" -eq 4 ]; then
                print_pass
                print_info "Amazon Linux 5.4 内核 (需要 redroid-modules)"
                print_info "参考: https://github.com/remote-android/redroid-modules"
                print_info "文档参考: deploy/amazon-linux.md"
                return 0
            elif [ "$KERNEL_MAJOR" -eq 4 ] && [ "$KERNEL_MINOR" -eq 14 ]; then
                print_pass
                print_info "Amazon Linux 4.14 内核 (需要 redroid-modules)"
                print_info "参考: https://github.com/remote-android/redroid-modules"
                print_info "文档参考: deploy/amazon-linux.md"
                return 0
            else
                print_warn "Amazon Linux 当前仅支持 5.4 和 4.14 内核"
                print_info "当前内核: $KERNEL_VERSION"
                print_info "5.10 支持正在开发中"
                print_info "文档参考: deploy/amazon-linux.md"
                return 0
            fi
            ;;
            
        *)
            # 未知系统：通用检查
            print_warn "未识别的系统: $OS_NAME"
            if [ "$KERNEL_MAJOR" -lt 4 ] || ([ "$KERNEL_MAJOR" -eq 4 ] && [ "$KERNEL_MINOR" -lt 14 ]); then
                print_fail "内核版本过低 (< 4.14)，无法运行 Redroid"
                return 1
            elif [ "$KERNEL_MAJOR" -lt 5 ]; then
                print_warn "内核版本较低 (< 5.0)，可能需要 redroid-modules"
                print_info "参考: https://github.com/remote-android/redroid-modules"
                return 0
            else
                print_pass
                print_info "内核版本基本满足要求"
                return 0
            fi
            ;;
    esac
}

# 检查 binderfs
check_binderfs() {
    print_check "binderfs 支持"
    
    if [ -d /sys/fs/binder ]; then
        print_pass
        print_info "binderfs 已挂载"
        return 0
    fi
    
    # 检查内核配置
    if [ -f /boot/config-$(uname -r) ]; then
        if grep -q "CONFIG_ANDROID_BINDERFS=y" /boot/config-$(uname -r); then
            print_warn "binderfs 已编译但未挂载"
            print_info "尝试: sudo mount -t binder binder /sys/fs/binder"
            return 0
        fi
    fi
    
    # 检查模块
    if lsmod | grep -q binder_linux; then
        print_pass
        print_info "binder_linux 模块已加载"
        return 0
    fi
    
    # 尝试加载模块
    if modprobe binder_linux devices="binder,hwbinder,vndbinder" 2>/dev/null; then
        print_pass
        print_info "binder_linux 模块加载成功"
        return 0
    fi
    
    print_fail "binderfs 不可用，可能需要安装 redroid-modules"
    return 1
}

# 检查 binder 设备
check_binder_devices() {
    print_check "binder 设备"
    
    if [ -c /dev/binder ] || [ -c /dev/binderfs/binder ]; then
        print_pass
        ls -la /dev/binder* 2>/dev/null | sed 's/^/  /'
        return 0
    fi
    
    print_warn "binder 设备不存在，容器启动时会自动创建"
    return 0
}

# 检查 ashmem
check_ashmem() {
    print_check "ashmem/memfd 支持"
    
    KERNEL_MAJOR=$(uname -r | cut -d. -f1)
    KERNEL_MINOR=$(uname -r | cut -d. -f2)
    
    # 5.18+ 内核使用 memfd
    if [ "$KERNEL_MAJOR" -gt 5 ] || ([ "$KERNEL_MAJOR" -eq 5 ] && [ "$KERNEL_MINOR" -ge 18 ]); then
        print_pass
        print_info "内核 >= 5.18，使用 memfd (推荐)"
        return 0
    fi
    
    # 检查 ashmem 设备
    if [ -c /dev/ashmem ]; then
        print_pass
        print_info "ashmem 设备存在"
        return 0
    fi
    
    # 检查 ashmem 模块
    if lsmod | grep -q ashmem_linux; then
        print_pass
        print_info "ashmem_linux 模块已加载"
        return 0
    fi
    
    # 尝试加载模块
    if modprobe ashmem_linux 2>/dev/null; then
        print_pass
        print_info "ashmem_linux 模块加载成功"
        return 0
    fi
    
    print_warn "ashmem 不可用，将使用 memfd (需要在启动参数中指定)"
    print_info "添加参数: androidboot.use_memfd=true"
    return 0
}

# 检查 IPv6
check_ipv6() {
    print_check "IPv6 支持"
    
    if [ -f /proc/net/if_inet6 ]; then
        print_pass
        return 0
    fi
    
    print_fail "IPv6 未启用"
    print_info "启用方法: sysctl -w net.ipv6.conf.all.disable_ipv6=0"
    return 1
}

# 检查页面大小
check_page_size() {
    print_check "页面大小"
    
    PAGE_SIZE=$(getconf PAGE_SIZE)
    
    if [ "$PAGE_SIZE" -eq 4096 ]; then
        print_pass
        print_info "页面大小: 4KB"
        return 0
    fi
    
    print_fail "页面大小不是 4KB: $PAGE_SIZE bytes"
    print_info "Redroid 需要 4KB 页面大小"
    return 1
}

# 检查 ION/DMA-BUF
check_dmabuf() {
    print_check "DMA-BUF/ION 支持"
    
    # 检查 DMA-BUF Heaps (新内核)
    if [ -d /dev/dma_heap ]; then
        print_pass
        print_info "DMA-BUF Heaps 可用 (推荐)"
        return 0
    fi
    
    # 检查 ION (旧内核)
    if [ -c /dev/ion ]; then
        print_pass
        print_info "ION 设备可用"
        return 0
    fi
    
    # 检查内核配置
    if [ -f /boot/config-$(uname -r) ]; then
        if grep -q "CONFIG_DMABUF_HEAPS=y" /boot/config-$(uname -r); then
            print_pass
            print_info "DMA-BUF Heaps 已编译"
            return 0
        fi
        
        if grep -q "CONFIG_ION=y" /boot/config-$(uname -r); then
            print_pass
            print_info "ION 已编译"
            return 0
        fi
    fi
    
    print_warn "DMA-BUF/ION 状态未知，可能影响图形性能"
    return 0
}

# 检查 Docker
check_docker() {
    print_check "Docker 安装"
    
    if command -v docker &> /dev/null; then
        print_pass
        print_info "Docker 版本: $(docker --version | cut -d' ' -f3 | tr -d ',')"
        
        # 检查 Docker 服务
        if systemctl is-active --quiet docker 2>/dev/null; then
            print_info "Docker 服务运行中"
        else
            print_warn "Docker 服务未运行"
            print_info "启动方法: sudo systemctl start docker"
        fi
        return 0
    fi
    
    print_fail "Docker 未安装"
    print_info "安装方法: https://docs.docker.com/engine/install/"
    return 1
}

# 检查 SELinux
check_selinux() {
    print_check "SELinux 状态"
    
    if ! command -v getenforce &> /dev/null; then
        print_pass
        print_info "SELinux 未安装"
        return 0
    fi
    
    SELINUX_STATUS=$(getenforce)
    
    if [ "$SELINUX_STATUS" = "Disabled" ] || [ "$SELINUX_STATUS" = "Permissive" ]; then
        print_pass
        print_info "SELinux: $SELINUX_STATUS"
        return 0
    fi
    
    print_warn "SELinux 处于 Enforcing 模式，可能影响 Redroid 运行"
    print_info "临时禁用: sudo setenforce 0"
    return 0
}

# 检查架构
check_architecture() {
    print_check "系统架构"
    
    ARCH=$(uname -m)
    
    if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "aarch64" ]; then
        print_pass
        print_info "架构: $ARCH"
        return 0
    fi
    
    print_fail "不支持的架构: $ARCH"
    print_info "Redroid 仅支持 x86_64 和 aarch64"
    return 1
}

# 检查内存
check_memory() {
    print_check "系统内存"
    
    TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
    
    if [ "$TOTAL_MEM" -ge 2048 ]; then
        print_pass
        print_info "总内存: ${TOTAL_MEM}MB"
        
        if [ "$TOTAL_MEM" -lt 4096 ]; then
            print_warn "内存较少，建议至少 4GB"
        fi
        return 0
    fi
    
    print_fail "内存不足: ${TOTAL_MEM}MB (需要至少 2GB)"
    return 1
}

# 检查磁盘空间
check_disk_space() {
    print_check "磁盘空间"
    
    AVAILABLE=$(df -BG / | awk 'NR==2 {print $4}' | tr -d 'G')
    
    if [ "$AVAILABLE" -ge 10 ]; then
        print_pass
        print_info "可用空间: ${AVAILABLE}GB"
        return 0
    fi
    
    print_warn "磁盘空间较少: ${AVAILABLE}GB (建议至少 10GB)"
    return 0
}

# 检查内核模块
check_kernel_modules() {
    print_check "必需的内核模块"
    
    echo ""
    
    local all_ok=true
    
    # 检查 fuse
    if lsmod | grep -q fuse || modprobe fuse 2>/dev/null; then
        print_info "  fuse: ${GREEN}✓${NC}"
    else
        print_info "  fuse: ${YELLOW}⚠${NC} (可选)"
    fi
    
    # 检查 nfnetlink
    if lsmod | grep -q nfnetlink || modprobe nfnetlink 2>/dev/null; then
        print_info "  nfnetlink: ${GREEN}✓${NC}"
    else
        print_info "  nfnetlink: ${YELLOW}⚠${NC} (某些系统需要)"
    fi
    
    if $all_ok; then
        print_pass
    else
        print_warn "部分模块不可用"
    fi
    
    return 0
}

# 生成报告
generate_report() {
    print_header "检查结果汇总"
    
    echo "通过: ${GREEN}$PASSED${NC}"
    echo "警告: ${YELLOW}$WARNING${NC}"
    echo "失败: ${RED}$FAILED${NC}"
    echo ""
    
    if [ "$FAILED" -eq 0 ]; then
        if [ "$WARNING" -eq 0 ]; then
            echo -e "${GREEN}✓ 系统完全满足 Redroid 运行要求！${NC}"
        else
            echo -e "${YELLOW}⚠ 系统基本满足要求，但有一些警告项${NC}"
            echo -e "${YELLOW}  建议查看上述警告并进行相应配置${NC}"
        fi
        echo ""
        echo "可以开始安装 Redroid："
        echo "  sudo bash install-redroid.sh"
    else
        echo -e "${RED}✗ 系统不满足 Redroid 运行要求${NC}"
        echo -e "${RED}  请解决上述失败项后再安装${NC}"
        echo ""
        echo "获取帮助："
        echo "  - 查看文档: https://github.com/remote-android/redroid-doc"
        echo "  - 加入社区: https://remote-android.slack.com"
    fi
    
    echo ""
}

# 主函数
main() {
    print_header "Redroid 系统兼容性检查"
    
    print_info "开始检查系统环境..."
    
    # 检测系统
    detect_os
    
    # 基础检查
    check_architecture
    check_kernel_version
    check_memory
    check_disk_space
    
    # 内核特性检查
    check_binderfs
    check_binder_devices
    check_ashmem
    check_ipv6
    check_page_size
    check_dmabuf
    check_kernel_modules
    
    # 环境检查
    check_docker
    check_selinux
    
    # 生成报告
    generate_report
}

# 运行主函数
main "$@"
