[首 页](https://patrickj-fd.github.io/index)

---

# 配置WiFi和SSH
方便无屏幕和键盘的情况

## WiFi 网络配置

### 直接修改SD卡
将刷好 Raspbian 系统的 SD 卡用电脑读取，在SD卡根新建文件：wpa_supplicant.conf
安装下面例子填写实际信息

```ini
country=CN
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
 
network={
ssid="WiFi-A"
psk="12345678"
key_mgmt=WPA-PSK
priority=1
scan_ssid=1
}
```

* 多个wifi就写多个network
* ssid:网络的ssid
* psk:密码
* key_mgmt: 使用WPA/WPA2加密填写“WPA-PSK”，否则填写“NONE”
* priority:连接优先级，数字越大优先级越高（不可以是负数）
* scan_ssid: 可以不写（连接隐藏WiFi时需要指定该值为1）

### 已开机情况
编辑文件： /etc/wpa_supplicant/wpa_supplicant.conf

### 设置固定IP

编辑文件： /etc/dhcpcd.conf
```ini
interface wlan0
 
static ip_address=192.168.0.123/24
static routers=192.168.0.1
static domain_name_servers=192.168.0.1 114.114.114.114 119.29.29.29
```

有线网络配置，修改 /boot/interfaces 文件
```ini
# interfaces(5) file used by ifup(8) and ifdown(8)
# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d
## Used dhcp ip address set eth0 inet to dhcp,
## or used static ip address set eth0 to static
## and change other ip settings.
## If you wanna let settings to take effect,
## uncomment symbol in front.

#auto eth0
#allow-hotplug eth0

#iface eth0 inet dhcp
#iface eth0 inet static
#address 172.16.192.168
#netmask 255.255.255.0
#gateway 172.16.192.1
#dns-nameservers 8.8.8.8
```

## 开启 SSH 服务

树莓派开机后：sudo touch /boot/ssh
如果不行，将文件复制到SD卡根目录试试。

---

[首 页](https://patrickj-fd.github.io/index)
