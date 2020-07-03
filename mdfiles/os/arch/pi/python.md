[首 页](https://patrickj-fd.github.io/index)

---

# 更换源
```shell
mkdir ~/.pip
echo "[global]" > ~/.pip/pip.conf
# trusted-host=mirrors.aliyun.com
# index-url = https://mirrors.aliyun.com/pypi/simple/
echo "trusted-host=pypi.tuna.tsinghua.edu.cn" >> ~/.pip/pip.conf
echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> ~/.pip/pip.conf

# 也配置给root，以便适用sudo pip3 install
su -
mkdir ~/.pip
cp /home/pi/.pip/pip.conf ~/.pip
```

# 安装 pip
树莓派版本b4，自带python为3.7.3，无pip。
```shell
wget -c --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-19.6.tar.gz
tar -zxvf setuptools-19.6.tar.gz && cd setuptools-19.6/
python3 setup.py build
sudo python3 setup.py install

sudo apt-get install python3-pip
# 若报错： No module named ‘distutils.util’
sudo apt-get install python3-distutils
# 若报错： Package python3-distutils has no installation candidate
sudo apt update

pip3 -V
# 更新到最新版，要用sudo，否则setuptools是装在当前用户下
sudo python3 -m pip install -U pip setuptools


# ========= 另外一种安装方式 =========
wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py
```

---

[首 页](https://patrickj-fd.github.io)
