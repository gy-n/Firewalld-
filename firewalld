#!/bin/bash

# 设置封禁时长（以秒为单位，默认为5天）
BAN_DURATION=$((5 * 24 * 60 * 60))

# 获取登录失败的IP地址
FAILED_IPS=$(grep 'Failed password' /var/log/secure | awk '{print $(NF-3)}' | sort -u)

# 封禁IP的函数
block_ip() {
    local ip=$1

    # 检查IP是否已经在封禁列表中
    if sudo firewall-cmd --list-rich-rules | grep "$ip"; then
        echo "IP $ip 已经被封禁."
    else
        # 添加封禁规则到firewalld
        sudo firewall-cmd --permanent --zone=public --add-rich-rule="rule family='ipv4' source address='$ip' reject"
        echo "IP $ip 已被成功封禁."

        # 设置解封时间
        local unban_time=$(( $(date +%s) + $BAN_DURATION ))
        echo "$unban_time $ip" >> /path/to/unban_list.txt
        echo "IP $ip 将在 $(date -d@$unban_time) 解封."
    fi
}

# 解封IP的函数
unblock_ip() {
    local ip=$1

    # 移除封禁规则
    sudo firewall-cmd --permanent --zone=public --remove-rich-rule="rule family='ipv4' source address='$ip' reject"
    echo "IP $ip 已解封."

    # 从解封列表中删除记录
    sed -i "/$ip/d" /path/to/unban_list.txt
}

# 检查并解封过期的IP
check_unban_list() {
    local current_time=$(date +%s)
    local unban_list="/path/to/unban_list.txt"

    while read -r line; do
        local unban_time=$(echo "$line" | awk '{print $1}')
        local ip=$(echo "$line" | awk '{print $2}')

        if [[ $unban_time -lt $current_time ]]; then
            unblock_ip "$ip"
        fi
    done < "$unban_list"
}

# 执行封禁操作
IFS=$'\n'
for ip in $FAILED_IPS; do
    block_ip "$ip"
done

# 检查并解封过期的IP
check_unban_list


