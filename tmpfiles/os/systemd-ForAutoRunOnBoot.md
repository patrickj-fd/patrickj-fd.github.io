对于开机执行的命令，从ubuntu18.04开始，推荐使用systemd而不是initd了。

** 1. 创建一个service文件 **
进入/etc/systemd/system/，创建一个xxx.service文件，主要内容如下：
```
[Unit]
Description=just for test         简介
After=BBB.service AAA.service     脚本所需要的前置service，比如：sshd.service

[Service]
ExecStart=/usr/local/my/my.sh     文件路径，后面可以跟参数，比如 -D -I 

[Install]
WantedBy=multi-user.target
```

** 2. 开启服务 **
```
sudo systemctl daemon-reload      service文件改动后要重新装载一下 
sudo systemctl enable my.service  设置成开机启动（下次开机时生效）
sudo systemctl start my.service   立即开启该服务（立即执行该脚本）
```

详细讲解service文件参考：
> http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html

