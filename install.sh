#!/bin/bash

# # 下载wslip-x64.rar
# wget https://github.com/Doraemonkeys/WSL_IP/releases/download/v0.0.1/wslip-x64.rar

# chmod +x wslip-x64.rar

# # 解压rar文件
# sudo apt-get install unrar
# unrar x wslip-x64.rar

# # 将可执行文件移动到目标目录
# mv wslip "$HOME/.local/bin/"

# chmod +x "$HOME/.local/bin/wslip"

# # 删除多余文件
# rm wslip-x64.rar

# bashrc_file="$HOME/.bashrc"
readonly profile_file="$HOME/.bash_profile"

# create .bash_profile file if it doesn't exist
if [ ! -f "$profile_file" ]; then
    touch "$profile_file"
fi
echo "请输入Windows代理端口号："
read -r port

# append the proxy functions to .bash_profile file

WSL_PROXY_START="#-------------------WSL_PROXY_START-------------------"
WSL_PROXY_END="#-------------------WSL_PROXY_END-------------------"

str1="
function proxy_on() {
export http_proxy=\"http://\$(ip route | grep default | awk '{print \$3}'):"

str2="\"
export https_proxy=\$http_proxy
export HTTP_PROXY=\$http_proxy
export HTTPS_PROXY=\$http_proxy
echo -e \"终端代理已开启，windows ip 为 \$(ip route | grep default | awk '{print \$3}')。\"
if curl --silent --head --max-time 3 https://www.google.com/ | grep \"HTTP.*200\" > /dev/null; then
        echo \"Google 连通性正常。\"
else
        echo \"无法连接到 Google。\"
        unset http_proxy HTTP_PROXY https_proxy HTTPS_PROXY
        echo -e \"终端代理已关闭。\"
fi
}


function proxy_off(){
    unset http_proxy HTTP_PROXY https_proxy HTTPS_PROXY
    echo -e \"终端代理已关闭。\"
}

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
"

# 判断是否存在 WSL_PROXY_START
if grep -q "$WSL_PROXY_START" "$profile_file"; then
    # 存在(删除start到end之间的内容)
    sed -i "/$WSL_PROXY_START/,/$WSL_PROXY_END/d" "$profile_file"
fi

echo "" >>"$profile_file"
echo "$WSL_PROXY_START$str1$port$str2$WSL_PROXY_END" >>"$profile_file"

# 将/etc/wsl.conf文件中的
# [network]
# generateResolvConf = true
# 修改为
# [network]
# generateResolvConf = false

# 判断是否存在 generateResolvConf
if grep -q "generateResolvConf" /etc/wsl.conf; then
    # 存在
    sudo sed -i 's/generateResolvConf = true/generateResolvConf = false/g' /etc/wsl.conf
else
    # 不存在
    echo "[network]" | sudo tee -a /etc/wsl.conf
    echo "generateResolvConf = false" | sudo tee -a /etc/wsl.conf
fi

# 将/etc/resolv.conf中nameserver一行修改为'nameserver 114.114.114.114'
targetFile="/etc/resolv.conf"

if [ ! -f "$targetFile" ]; then
    echo "$targetFile 文件不存在, 创建文件"
    sudo touch "$targetFile"
fi

newNameserver="nameserver 114.114.114.114"

# 获取第一行nameserver
nameserver=$(grep "nameserver" $targetFile | head -n 1)

# 判空
if [ -z "$nameserver" ]; then
    echo "nameserver为空"
    # 设置可修改
    sudo chattr -i $targetFile
    # 添加nameserver
    echo "$newNameserver" | sudo tee -a "$targetFile"
    # 设置不可修改
    sudo chattr +i $targetFile
elif [ "$nameserver" != "$newNameserver" ]; then
    echo "nameserver不相等：$nameserver"
    # 不相等
    # 设置可修改
    sudo chattr -i $targetFile
    # 替换第一个nameserver
    sudo sed -i "0,/nameserver/s/nameserver.*/$newNameserver/g" $targetFile
    # 设置不可修改
    sudo chattr +i $targetFile
fi

# echo "nameserver 114.114.114.114" | sudo tee -a /etc/resolv.conf

# 重新加载bash配置文件
# shellcheck source=/dev/null
source "$profile_file"

echo "配置完成，请重启终端。"
echo "请在终端输入 proxy_on 开启代理，输入 proxy_off 关闭代理。"
