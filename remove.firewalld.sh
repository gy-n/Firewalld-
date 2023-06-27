#!/bin/bash

# 封禁IP的函数
block_ip() {
    local ip=$1

    # 检查IP是否已经在封禁列表中
    if sudo firewall-cmd --list-rich-rules | grep  "$ip"; then
        echo "IP $ip 已经被封禁."
    else
        # 添加封禁规则到firewalld
        sudo firewall-cmd --permanent --zone=public --add-rich-rule="rule family='ipv4' source address='$ip' reject"
        echo "IP $ip 已被成功封禁."
    fi

    # 载入firewall规则
    sudo firewall-cmd --reload
}

# 解封单个IP的函数
unblock_ip() {
    local ip=$1

    # 检查IP是否在封禁列表中
    if sudo firewall-cmd --list-rich-rules | grep "$ip"; then
        # 移除封禁规则
        sudo firewall-cmd --permanent --zone=public --remove-rich-rule="rule family='ipv4' source address='$ip' reject"
        echo "IP $ip 已解封."
    else
        echo "IP $ip 未被封禁."
    fi

  # 载入firewall规则
   sudo firewall-cmd --reload
}

# 解封2天前的IP地址
unblock_2_days_ago() {
    local cutoff_date=$(date -d "2 days ago" +"%Y-%m-%d")
    local blocked_ips=$(sudo firewall-cmd --list-rich-rules | grep "reject" | grep "$cutoff_date" | awk '{print $11}')

    if [ -z "$blocked_ips" ]; then
        echo "2天前没有被封禁的IP地址."
    else
        for ip in $blocked_ips; do
            unblock_ip "$ip"
        done
    fi
  # 载入firewall规则
   sudo firewall-cmd --reload

}

# 解封全部封禁的IP地址
unblock_all_ips() {
#    local blocked_ips=$(sudo firewall-cmd --list-rich-rules | grep "reject" | awk '{print $11}')
     local blocked_ips=$(sudo firewall-cmd --list-rich-rules | grep "reject" | awk --re-interval '{match($0,/([0-9]{1,3}\.){3}[0-9]{1,3}/,a); print a[0]}')
    if [ -z "$blocked_ips" ]; then
        echo "没有被封禁的IP地址."
    else
        for ip in $blocked_ips; do
            unblock_ip "$ip"
        done
    fi
  # 载入firewall规则
   sudo firewall-cmd --reload

}

# 查询IP封禁状态
check_ip_status() {
    local ip=$1

    # 检查IP是否在封禁列表中
    if sudo firewall-cmd --list-rich-rules | grep "$ip"; then
        echo "IP $ip 已被封禁."
    else
        echo "IP $ip 未被封禁."
    fi
}

# 添加自定义封禁IP
add_custom_blocked_ip() {
    local ip=$1

    block_ip "$ip"
}

# 列出当前防火墙开放端口
list_open_ports() {
    sudo firewall-cmd --list-ports
}
# 列出当前防火墙策略
list_rich_rules() {
    sudo firewall-cmd --list-rich-rules
}
# 主菜单
main_menu() {
    clear
    echo "1. 封禁IP地址"
    echo "2. 解封IP地址"
    echo "3. 解封2天前的IP地址"
    echo "4. 解封全部封禁的IP地址"
    echo "5. 查询IP封禁状态"
    echo "6. 添加自定义封禁IP"
    echo "7. 列出当前防火墙开放端口"
    echo "8. 列出当前防火墙策略"   
    echo "9. 退出"
    echo
    read -p "请输入选项号码: " choice
    echo

    case $choice in
        1)
            read -p "请输入要封禁的IP地址: " ip
            block_ip "$ip"
            ;;
        2)
            read -p "请输入要解封的IP地址: " ip
            unblock_ip "$ip"
            ;;
        3)
            unblock_2_days_ago
            ;;
        4)
            unblock_all_ips
            ;;
        5)
            read -p "请输入要查询的IP地址: " ip
            check_ip_status "$ip"
            ;;
        6)
            read -p "请输入要封禁的IP地址: " ip
            add_custom_blocked_ip "$ip"
            ;;
        7)
            list_open_ports
            ;;
        8)
            list_rich_rules
            ;;
        9)
             exit 0
            ;;
        *)
            echo "无效的选项，请重试."
            ;;
    esac

    echo
    read -n 1 -s -r -p "按任意键返回主菜单..."
    echo
    main_menu
}

# 执行主菜单
main_menu

