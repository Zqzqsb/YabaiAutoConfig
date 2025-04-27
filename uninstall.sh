#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
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

# 确认卸载
confirm_uninstall() {
    print_warning "此操作将卸载 yabai、skhd 和 SpaceId，并删除所有相关配置文件。"
    read -p "确定要继续吗？(y/n): " choice
    case "$choice" in 
        y|Y ) return 0;;
        * ) print_message "卸载已取消。"; exit 1;;
    esac
}

# 停止服务
stop_services() {
    print_message "停止 yabai 和 skhd 服务..."
    
    # 停止 yabai 服务
    yabai --stop-service &> /dev/null
    print_success "yabai 服务已停止。"
    
    # 停止 skhd 服务
    launchctl unload -w ~/Library/LaunchAgents/com.zq.skhd.plist &> /dev/null
    print_success "skhd 服务已停止。"
    
    # 关闭 SpaceId
    pkill -x SpaceId &> /dev/null
    print_success "SpaceId 已关闭。"
}

# 卸载软件包
uninstall_packages() {
    print_message "卸载 yabai、skhd 和 SpaceId..."
    
    # 卸载 yabai
    brew uninstall yabai &> /dev/null
    print_success "yabai 已卸载。"
    
    # 卸载 skhd
    brew uninstall skhd &> /dev/null
    print_success "skhd 已卸载。"
    
    # 卸载 SpaceId
    brew uninstall --cask spaceid &> /dev/null
    print_success "SpaceId 已卸载。"
}

# 删除配置文件
remove_config_files() {
    print_message "删除配置文件..."
    
    # 删除 yabai 配置文件
    rm -f ~/.yabairc
    print_success "yabai 配置文件已删除。"
    
    # 删除 skhd 配置文件
    rm -f ~/.skhdrc
    print_success "skhd 配置文件已删除。"
    
    # 删除 skhd 启动项
    rm -f ~/Library/LaunchAgents/com.zq.skhd.plist
    print_success "skhd 启动项已删除。"
    
    # 删除 sudoers 文件
    sudo rm -f /private/etc/sudoers.d/yabai
    print_success "sudoers 文件已删除。"
    
    # 删除日志文件
    rm -f ~/Library/Logs/skhd.log
    rm -f /tmp/yabai_$(whoami).out.log
    rm -f /tmp/yabai_$(whoami).err.log
    print_success "日志文件已删除。"
}

# 主函数
main() {
    print_message "开始卸载 yabai 和 skhd..."
    
    confirm_uninstall
    stop_services
    uninstall_packages
    remove_config_files
    
    print_success "卸载完成！"
    print_message "yabai、skhd 和 SpaceId 已卸载，所有配置文件已删除。"
    print_message "如果您想重新安装，可以运行 install.sh 脚本。"
}

# 执行主函数
main
