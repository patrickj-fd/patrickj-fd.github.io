[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 1. 调试及发布
## 1.1 连接真机
在手机的设置中，搜索“usb”，找到“usb 调试”选项，打开他。

用usb把手机连接到电脑上，屏幕顶部下滑，会出现“正在通过USB充电”的一个条目，点进去，选择“USB连接方式”为：MIDI。  
对于华为手机来说，务必要选为MIDI方式，否则后面无论如何都找不到设备。

- Win平台上给Android Studio安装驱动包
`Tools -> SDK 管理器 -> SDK Tools` 中选中“Google USB Driver”  
注意：在 Mac/Linux 平台上，不需要做这一步！

进入Android Studio自带的命令行工具，输入adb devices, 可以看到手机设备。

对于Ubuntu等Linux系统，还要做以下步骤：

1. 找到手机的 vendor id
```shell
lsusb
```
显示类似如下信息：
```
Bus 001 Device 008: ID 12d1:107e Huawei Technologies Co., Ltd. 
```
12d1 就是 vendor id

2. 在/etc/udev/rules.d/目录下建立规则文件: 51-android.rules
```
SUBSYSTEM=="usb", ATTR{idVendor}=="12d1", MODE="0666"
```

3. 重启udev服务
```shell
sudo /etc/init.d/udev restart
```

4. 重启adb服务
```shell
# 进入Android Studio自带的命令行工具执行：
cd ~/Android/Sdk/platform-tools
sudo ./adb kill-server
sudo ./adb start-server

# 查看连接的设备
sudo ./adb devices
```

---

[首 页](https://patrickj-fd.github.io/index)
