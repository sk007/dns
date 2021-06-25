#!/bin/bash
#Blog:https://moexin.top/archives/Linux%20VPS%20one-click%20add/remove%20Swap%20virtual%20memory%20script

Green="\033[32m"
Font="\033[0m"
Red="\033[31m" 

#root权限
root_need(){
    if [[ $EUID -ne 0 ]]; then
        echo -e "${Red}Error:This script must be run as root!${Font}"
        exit 1
    fi
}

#检测ovz
ovz_no(){
    if [[ -d "/proc/vz" ]]; then
        echo -e "${Red}Your VPS is based on OpenVZ，not supported!${Font}"
        exit 1
    fi
}

add_swap(){
echo -e "${Green}请输入需要添加的Swap，建议为内存的2倍！${Font}"
read -p "请输入swap数值:" swapsize

#检查是否存在SwapFile
grep -q "swapfile" /etc/fstab

#如果不存在将为其创建Swap
if [ $? -ne 0 ]; then
	echo -e "${Green}SwapFile未发现，正在为其创建SwapFile${Font}"
	fallocate -l ${swapsize}M /swapfile
	chmod 600 /swapfile
	mkswap /swapfile
	swapon /swapfile
	echo '/swapfile none swap defaults 0 0' >> /etc/fstab
         echo -e "${Green}Swap创建成功，并查看信息：${Font}"
         cat /proc/swaps
         cat /proc/meminfo | grep Swap
else
	echo -e "${Red}SwapFile已存在，Swap设置失败，请先运行脚本删除Swap后重新设置！${Font}"
fi
}

del_swap(){
#检查是否存在SwapFile
grep -q "swapfile" /etc/fstab

#如果存在就将其移除
if [ $? -eq 0 ]; then
	echo -e "${Green}SwapFile已发现，正在将其移除...${Font}"
	sed -i '/swapfile/d' /etc/fstab
	echo "3" > /proc/sys/vm/drop_caches
	swapoff -a
	rm -f /swapfile
    echo -e "${Green}Swap已删除！${Font}"
else
	echo -e "${Red}SwapFile未发现，Swap删除失败！${Font}"
fi
}

#开始菜单
main(){
root_need
ovz_no
clear
echo -e "———————————————————————————————————————"
echo -e "${Green}Linux VPS一键添加/删除Swap脚本${Font}"
echo -e "${Green}1、添加Swap${Font}"
echo -e "${Green}2、删除Swap${Font}"
echo -e "———————————————————————————————————————"
read -p "请输入数字 [1-2]:" num
case "$num" in
    1)
    add_swap
    ;;
    2)
    del_swap
    ;;
    *)
    clear
    echo -e "${Green}请输入正确数字 [1-2]${Font}"
    sleep 2s
    main
    ;;
    esac
}
main
