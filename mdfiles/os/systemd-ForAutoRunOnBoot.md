[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

- [参考文章](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)
- [参考文章](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)

对于开机执行的命令，从ubuntu18.04开始，推荐使用systemd而不是initd了。

## 1. 创建一个service文件
vi /etc/systemd/system/frpc.service
```ini
[Unit]
Description=just for test         简介
After=network.target              脚本所需要的前置service，空格分隔写多个

[Service]
Type=simple
ExecStart=/opt/frp-0.33.0/frpc -c /opt/frp-0.33.0/frpc.ini
ExecReload=/opt/frp-0.33.0/frpc reload -c /opt/frp-0.33.0/frpc.ini
# WorkingDirectory=/opt/frp-0.33.0/
# StandardOutput=inherit
# StandardError=inherit
Restart=on-failure                    Or always
RestartSec=5s
User=nobody                           Or other user name

[Install]
WantedBy=multi-user.target
```

## 2. 启停服务
```shell
# 立即开启该服务（立即执行该脚本）
sudo systemctl start frpc
# 设置成开机启动（下次开机时生效）
sudo systemctl enable frpc

# 修改配置文件后，必须重新加载一次后，才能重启服务
# 重新加载配置文件
$ sudo systemctl daemon-reload
# 重启相关服务
$ sudo systemctl restart frpc

# 停止
sudo systemctl stop frpc.service
# 有时候，该命令可能没有响应，服务停不下来，就不得不"杀进程"了
sudo systemctl kill frpc.service
```

## 3. 问题排查

### * 查看服务状态
```shell
sudo systemctl status frpc
```
该命令输出结果说明：
```txt
   Loaded行：配置文件的位置，是否设为开机启动
   Active行：表示正在运行
 Main PID行：主进程ID
   Status行：由应用本身（这里是 httpd ）提供的软件当前状态
   CGroup块：应用的所有子进程
```

### * 查看服务的配置文件
```shell
systemctl cat sshd.service
```

---

[首 页](https://patrickj-fd.github.io/index)
