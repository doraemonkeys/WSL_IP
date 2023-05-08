#!/bin/bash

# 下载wslip-x64.rar
wget https://github.com/Doraemonkeys/WSL_IP/releases/download/v0.0.1/wslip-x64.rar

chmod +x wslip-x64.rar

# 解压rar文件
sudo apt-get install unrar
unrar x wslip-x64.rar

# 将可执行文件移动到目标目录
mv wslip "$HOME/.local/bin/"

# 删除多余文件
rm wslip-x64.rar

# bashrc_file="$HOME/.bashrc"
readonly profile_file="$HOME/.bash_profile"

# create .bash_profile file if it doesn't exist
if [ ! -f "$profile_file" ]; then
    touch "$profile_file"
fi
echo "请输入Windows代理端口号："
read -r port

# append the proxy functions to .bash_profile file

str1="
function proxy_on() {
export http_proxy=\"http://$(wslip):"

str2="\"
export https_proxy=\$http_proxy
export HTTP_PROXY=\$http_proxy
export HTTPS_PROXY=\$http_proxy
echo -e \"终端代理已开启，windows ip 为 \$(wslip)。\"
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

echo "$str1$port$str2" >>"$profile_file"

# 重新加载bash配置文件
# shellcheck source=/dev/null
source "$profile_file"

echo "配置完成，请重启终端。"
echo "请在终端输入 proxy_on 开启代理，输入 proxy_off 关闭代理。"
