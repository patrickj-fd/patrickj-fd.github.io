[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 使用Etcher烧录
- [Etcher下载地址](https://www.balena.io/etcher/)

# Linux上使用dd烧录
- [官网教程](https://www.raspberrypi.org/documentation/installation/installing-images/linux.md)

```shell
# status=progress 参数是为了看到拷贝过程
dd bs=4M if=2020-08-20-raspios-buster-armhf-lite.img of=/dev/sdX status=progress conv=fsync

unzip -p 2020-08-20-raspios-buster-armhf-lite.zip | sudo dd of=/dev/sdX bs=4M conv=fsync
```

# Mac上使用dd烧录
- [官网教程](https://www.raspberrypi.org/documentation/installation/installing-images/mac.md)

```shell
# 1. 插入SD卡，用df命令查看当前已挂载的卷
df -h
# 一般是： /dev/disk1s1

# 2. 卸载该分区（不要拔出）
diskutil unmount /dev/disk1s1

# 3. 确认
diskutil list
# 应该只有两行：
# FDisk_partition_scheme           *15.8 GB
#           Windows_NTFS 未命名     15.8 GB

# 4. 使用dd命令将系统镜像写入
sudo dd bs=1m if=2020-08-20-raspios-buster-armhf-lite.img of=/dev/rdisk1; sync
# 注意：这里使用 rdisk1 ！ （/dev/disk1s1是分区，/dev/disk1是块设备，/dev/rdisk1是原始字符设备）
# 假如报错 dd: bs: illegal numeric value。 change the block size bs=1m to bs=1M

# 5. 弹出SD卡盘
diskutil eject /dev/rdisk1
```

---

[首 页](https://patrickj-fd.github.io)
