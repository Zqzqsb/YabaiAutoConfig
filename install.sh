#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # 无颜色

# 打印带颜色的消息
print_message() {
    echo -e "${BLUE}[YabaiAutoConfig]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 检查 SIP 状态
check_sip() {
    print_message "检查 SIP 状态..."
    SIP_STATUS=$(csrutil status)
    if [[ $SIP_STATUS == *"disabled"* ]]; then
        print_success "SIP 已禁用，可以继续安装。"
    else
        print_error "SIP 未禁用！请先禁用 SIP 然后再运行此脚本。"
        print_message "禁用 SIP 的步骤："
        print_message "1. 重启 Mac 并按住 Command + R 进入恢复模式"
        print_message "2. 点击实用工具 -> 终端"
        print_message "3. 输入 'csrutil disable' 并回车"
        print_message "4. 重启 Mac"
        exit 1
    fi
}

# 安装 Homebrew（如果尚未安装）
install_homebrew() {
    print_message "检查 Homebrew 是否已安装..."
    if ! command -v brew &> /dev/null; then
        print_message "安装 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        print_success "Homebrew 安装完成。"
    else
        print_success "Homebrew 已安装。"
    fi
}

# 安装 yabai 和 skhd
install_packages() {
    print_message "安装 yabai 和 skhd..."
    
    # 检查并安装 yabai
    if ! brew list yabai &> /dev/null; then
        print_message "安装 yabai..."
        brew install koekeishiya/formulae/yabai
        print_success "yabai 安装完成。"
    else
        print_success "yabai 已安装。"
    fi
    
    # 检查并安装 skhd
    if ! brew list skhd &> /dev/null; then
        print_message "安装 skhd..."
        brew install koekeishiya/formulae/skhd
        print_success "skhd 安装完成。"
    else
        print_success "skhd 已安装。"
    fi
    
    # 检查并安装 SpaceId（用于在状态栏显示当前桌面编号）
    if ! brew list --cask spaceid &> /dev/null; then
        print_message "安装 SpaceId..."
        brew install --cask spaceid
        print_success "SpaceId 安装完成。"
    else
        print_success "SpaceId 已安装。"
    fi
}

# 配置 yabai
configure_yabai() {
    print_message "配置 yabai..."
    
    # 复制 yabai 配置文件
    cp ./config/yabairc ~/.yabairc
    chmod +x ~/.yabairc
    print_success "yabai 配置文件已复制到 ~/.yabairc"
    
    # 停止 yabai 服务（如果正在运行）
    yabai --stop-service &> /dev/null
    
    # 配置 yabai 脚本添加组件
    print_message "配置 yabai 脚本添加组件..."
    
    # 卸载现有的脚本添加组件
    sudo yabai --uninstall-sa
    
    # 创建 sudoers 文件
    YABAI_HASH=$(shasum -a 256 $(which yabai) | cut -d " " -f 1)
    echo "$(whoami) ALL=(root) NOPASSWD: sha256:$YABAI_HASH $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai
    sudo chmod 644 /private/etc/sudoers.d/yabai
    
    # 安装并加载脚本添加组件
    sudo yabai --load-sa
    
    # 启动 yabai 服务
    yabai --start-service
    print_success "yabai 服务已启动。"
}

# 配置 skhd
configure_skhd() {
    print_message "配置 skhd..."
    
    # 复制 skhd 配置文件
    cp ./config/skhdrc ~/.skhdrc
    print_success "skhd 配置文件已复制到 ~/.skhdrc"
    
    # 创建 skhd 启动项
    mkdir -p ~/Library/LaunchAgents
    cp ./config/com.zq.skhd.plist ~/Library/LaunchAgents/
    
    # 停止现有的 skhd 服务
    launchctl unload -w ~/Library/LaunchAgents/com.zq.skhd.plist &> /dev/null
    
    # 启动 skhd 服务
    launchctl load -w ~/Library/LaunchAgents/com.zq.skhd.plist
    print_success "skhd 服务已启动。"
}

# 启动 SpaceId
start_spaceid() {
    print_message "启动 SpaceId..."
    open -a SpaceId
    print_success "SpaceId 已启动。"
}

# 主函数
main() {
    print_message "开始安装 yabai 和 skhd 自动配置..."
    
    check_sip
    install_homebrew
    install_packages
    configure_yabai
    configure_skhd
    start_spaceid
    
    print_success "安装完成！"
    print_message "yabai 和 skhd 已配置并启动，SpaceId 显示当前桌面编号。"
    print_message "请尝试使用快捷键来测试配置是否正常工作。"
    print_message "如果遇到问题，请查看日志文件："
    print_message "yabai 日志：/tmp/yabai_$(whoami).out.log 和 /tmp/yabai_$(whoami).err.log"
    print_message "skhd 日志：~/Library/Logs/skhd.log"
}

# 执行主函数
main
