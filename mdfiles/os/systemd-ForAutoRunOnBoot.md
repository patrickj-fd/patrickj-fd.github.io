[首 页](https://patrickj-fd.github.io/index)

---

对于开机执行的命令，从ubuntu18.04开始，推荐使用systemd而不是initd了。

** 1. 创建一个service文件 **
进入/etc/systemd/system/，创建一个xxx.service文件，主要内容如下：
```ini
[Unit]
Description=just for test         简介
After=network.target              脚本所需要的前置service，空格分隔写多个

[Service]
ExecStart=/usr/bin/python3 -u main.py
WorkingDirectory=/home/pi/myscript    服务会运行 /home/pi/myscript 目录下面的 main.py 脚本
StandardOutput=inherit
StandardError=inherit
Restart=always
User=pi

[Install]
WantedBy=multi-user.target
```

** 2. 开启服务 **
```shell
# sudo systemctl daemon-reload      service文件改动后要重新装载一下 
sudo systemctl start my.service   立即开启该服务（立即执行该脚本）
sudo systemctl enable my.service  设置成开机启动（下次开机时生效）
```

详细讲解service文件参考：
> http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html

---

[首 页](https://patrickj-fd.github.io/index)
