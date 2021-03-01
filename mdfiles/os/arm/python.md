[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---
# conda
官方不提供 aarch64 的安装包，因此，使用别人编译好：
> https://github.com/Archiconda/build-tools/releases

最终安装好之后，输入python，应该能看到 Anaconda 的字样。

# 更换源
```shell
mkdir ~/.pip
# https://repo.huaweicloud.com/repository/pypi/simple/ 华为
# https://mirrors.aliyun.com/pypi/simple/   阿里
# https://pypi.mirrors.ustc.edu.cn/simple/  中科大，据说是最好的
#echo "trusted-host = pypi.tuna.tsinghua.edu.cn" >> ~/.pip/pip.conf
#echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> ~/.pip/pip.conf
echo "[global]" > ~/.pip/pip.conf
echo "trusted-host = pypi.mirrors.ustc.edu.cn" >> ~/.pip/pip.conf
echo "index-url = https://pypi.mirrors.ustc.edu.cn/simple/" >> ~/.pip/pip.conf
echo "timeout = 120" >> ~/.pip/pip.conf
```

也配置给root，以便适用sudo pip3 install？待确认

# 安装 pip
对于某些系统（如：树莓派b4），系统自带的python没有pip，需要自己安装上。
```shell
# 先安装 setuptools之后才能安装pip
wget -c --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-19.6.tar.gz
tar -zxvf setuptools-19.6.tar.gz && cd setuptools-19.6/
python3 setup.py build
sudo python3 setup.py install

sudo apt-get install -y python3-pip
# 若报错： No module named ‘distutils.util’
sudo apt-get install -y python3-distutils
# 若报错： Package python3-distutils has no installation candidate
sudo apt update

pip3 -V
# 更新到最新版，要用sudo，否则setuptools是装在当前用户下
sudo python3 -m pip install -U pip setuptools
```

---

[首 页](https://patrickj-fd.github.io)
