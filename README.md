## 为WSL2配置Windows代理

1. 执行脚本(bash)，可能需要管理员权限

```bash
bash <(curl -s https://raw.githubusercontent.com/Doraemonkeys/WSL_IP/master/install.sh)
```

2. 按提示输入代理端口号(clash默认7890,v2ray默认10809)

![image-20230509013613785](E:/Doraemon/Pictures/Typora/2023002/image-20230509013613785.png)

3. 暂时关闭windows网络防火墙(只关闭**公用网络**就行)

<img src="E:/Doraemon/Pictures/Typora/2023002/image-20230509014017161.png" alt="image-20230509014017161" style="zoom: 50%;" />

4. 开启代理软件的**允许来自局域网的连接**选项

![image-20230509014522847](E:/Doraemon/Pictures/Typora/2023002/image-20230509014522847.png)

4. 重启终端/WSL2



5. 在终端输入 `proxy_on` 即可开启代理，输入 `proxy_off` 关闭代理。



### windows添加防火墙规则

> 重新开启windows防火墙后若能正常使用则跳过此步骤。

[如何让Windows的代理作用于wsl2?](https://www.zhihu.com/question/435906813/answer/2845515380)



1. 确定联网的进程

我们可以通过资源监视器->网络，去确定对应端口的进程名 xray.exe

![img](E:/Doraemon/Pictures/Typora/2023002/v2-0bae1731994d773cbef8ebed7105c9c8_720w.png)

然后，在任务管理器中右键单击 xray.exe，选择属性，获取其文件路径

![img](E:/Doraemon/Pictures/Typora/2023002/v2-73e91d5af651f0ce9ec156ddab752100_720w.png)

2. 添加防火墙规则

通过允许其他应用按钮，添加 xray.exe 到允许列表

![img](E:/Doraemon/Pictures/Typora/2023002/v2-61386e3ac28495e31432aabd010aed56_720w.png)



## 原始脚本

```bash
function proxy_on() {
# 改成你的 http_proxy（局域网）端口号
export http_proxy="http://$(wslip):7890"
export https_proxy=$http_proxy
export HTTP_PROXY=$http_proxy
export HTTPS_PROXY=$http_proxy
echo -e "终端代理已开启，windows ip 为 $(wslip)。"
if curl --silent --head --max-time 3 https://www.google.com/ | grep "HTTP.*200" > /dev/null; then
        echo "Google 连通性正常。"
else
        echo "无法连接到 Google。"
        unset http_proxy HTTP_PROXY https_proxy HTTPS_PROXY
        echo -e "终端代理已关闭。"
fi
}


function proxy_off(){
    unset http_proxy HTTP_PROXY https_proxy HTTPS_PROXY
    echo -e "终端代理已关闭。"
}

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
```

