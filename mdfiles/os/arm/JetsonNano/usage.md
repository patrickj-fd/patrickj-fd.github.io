[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

### 关闭、开启 swap
日常使用时，尽量用内存，不要频繁用swap，避免损耗SD卡。当要进行OpenCV等大软件源码编译时，再开启。
```shell
sudo swapoff -a   # 关闭，不用重启
sudo swapon -a    # 开启，不用重启
```
永久禁用：
- 方式1：/etc/fstab文件中swap一行注释掉
- 方式2：/etc/sysctl.conf文件中设置vm.swappiness为0
```shell
# 临时生效
sysctl -w vm.swappiness=0
# 永久生效
echo "vm.swappiness = 0">> /etc/sysctl.conf
swapoff -a && swapon -a   # 将SWAP里的数据转储回内存，并清空SWAP里的数据
sysctl -p                 # 生效，不用重启
```


---

[首 页](https://patrickj-fd.github.io)
