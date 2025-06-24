[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# Frp+公网IP主机实现内网穿透

软件官网：https://github.com/fatedier/frp

## 安装
wget 其 release 版本，如 0.32.0
任意目录解压，即可直接使用了，不需要安装。
解压文件分为server端（公网IP的主机）和client端（内网需要被访问的主机）。
其中，frps系列的文件是server的，frpc系列的文件是client的。

## 配置
### 配置server端（公网IP的主机）

- vi frps.ini

```
[common]
bind_port = 37000

#log_file = ./frps.log
# trace, debug, info, warn, error
#log_level = info
#log_max_days = 3
```
bind_port 是与客户端通讯用的内部服务端口

- 启动：

```
frps -c frps.ini
```

### 配置client端（内网需要被访问的主机）

- vi frpc.ini

```
[common]
# frp server internet ip
server_addr = 139.9.126.19
# frp server port : bind_port in frps.ini
server_port = 37000

[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 35001

[web]
type = tcp
local_ip = 127.0.0.1
local_port = 8080
remote_port = 35002
```

如上所示
- [common] 指定server的ip和port  
- [ssh]和[web] 分别配置了两个可以被通过公网访问的方式  
  其中：
  * local_port  ：为内网主机开放的服务端口
  * remote_port ：为该端口对应的公网访问映射端口，这个端口被server开放出去的

- 启动：

```
frpc -c frpc.init
```

外部通过SSH访问这个内网主机的方式如下：
```
ssh -oPort=35001 fd@139.9.126.19
```
内网主机在8080端口启动HTTP服务后，即可外网访问：  
http://139.9.126.19:35002

### 配置不同主机上的client

如果每个主机都连向同一个frps，那么，各个主机上的frpc.ini中的配置名字不能重复。  
比如都叫[ssh]是不行的，要分开起名字。

---

[首 页](https://patrickj-fd.github.io/index)
