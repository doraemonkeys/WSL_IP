package main

import (
	"errors"
	"flag"
	"fmt"
	"net"
	"os"

	"github.com/Doraemonkeys/mylog"
	"github.com/sirupsen/logrus"
)

func init() {
	mylog.InitGlobalLogger(mylog.LogConfig{LogFileDisable: true})
}

// 获取指定网卡的ipv4地址,如WLAN
func GetIPv4ByInterfaceName(name string) (net.IP, error) {
	inter, err := net.InterfaceByName(name)
	if err != nil {
		return nil, err
	}
	addrs, err := inter.Addrs()
	if err != nil {
		return nil, err
	}
	for _, addr := range addrs {
		if ip, ok := addr.(*net.IPNet); ok && !ip.IP.IsLoopback() {
			if ip.IP.To4() != nil {
				return ip.IP, nil
			}
		}
	}
	return nil, errors.New(name + " interface not found")
}

// 获取指定网卡的ipv4子网掩码
func GetIpv4MaskByInterfaceName(name string) (net.IPMask, error) {
	inter, err := net.InterfaceByName(name)
	if err != nil {
		return nil, err
	}
	addrs, err := inter.Addrs()
	if err != nil {
		return nil, err
	}
	for _, addr := range addrs {
		if ip, ok := addr.(*net.IPNet); ok && !ip.IP.IsLoopback() {
			if ip.IP.To4() != nil {
				return ip.Mask, nil
			}
		}
	}
	return nil, errors.New(name + " interface not found")
}

var IFName = flag.String("name", "eth0", "interface name")

var help = flag.Bool("h", false, "help")

func main() {
	flag.Parse()
	if *help {
		flag.Usage()
		return
	}
	// 获取WSL的eth0的ipv4地址
	eth0 := *IFName
	ip, err := GetIPv4ByInterfaceName(eth0)
	if err != nil {
		logrus.Error("get ip failed, err:", err)
	}
	// 获取WSL的eth0的ipv4子网掩码(e.g. ffffff00)
	mask, err := GetIpv4MaskByInterfaceName(eth0)
	if err != nil {
		logrus.Error("get mask failed, err:", err)
		os.Exit(1)
	}
	// 通过ipv4地址和子网掩码计算出ipv4网段
	network := ip.Mask(mask)
	// 172.18.96.0 -> 172.18.96.1
	network[3] = network[3] + 1

	fmt.Println(network.String())
}
