[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 1. 操作系统级 OS 软件环境安装

以下软件包，对OpenCV，以及后续做Tensorflow/Pytorch编译和运行，都是必须的

```shell
su - pi
# 最好在官方源上做update和安装。换成国内源后，有可能出现安装失败的情况
# sudo apt update
# sudo apt upgrade -y
sudo apt install -y build-essential make cmake cmake-curses-gui \
         git g++ pkg-config libfreetype6-dev \
         libcanberra-gtk-module libcanberra-gtk3-module

sudo apt install -y curl  libcurl4-openssl-dev

sudo apt install -y libpython3.6-dev
sudo apt install -y python3-dev python3-testresources
sudo apt install -y autoconf libtool

sudo apt install -y libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg-dev liblapack-dev libblas-dev gfortran
sudo apt install -y libopenblas-base libopenmpi-dev libopenblas-dev

```

# 2. 操作系统级 python 环境安装

## 2.1 安装 pip
```shell
cd /data

# 安装 setuptools
# 某些情况下，直接装python3-pip会报错，需要先安装一个低版本的setuptools才能装pip
# wget -c --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-19.6.tar.gz
# 华为云上也可以下载软件：sftp root@139.9.126.19 get /data/hre/setuptools-19.6.tar.gz
# 内网机器上： scp fd@172.168.0.216:/data3/HyrenEdge/setuptools-19.6.tar.gz .
# cp /mnt/usb1/hre/setuptools-19.6.tar.gz .
# tar xf setuptools-19.6.tar.gz && cd setuptools-19.6/
#ssh root@172.168.0.100 "cat /data1/HyrenEdge/setuptools-19.6.tar.gz" | tar -zxf -  # 5t6y0524A!
#cd setuptools-19.6/
#python3 setup.py build
#sudo python3 setup.py install

# 安装 pip
sudo apt install -y python3-pip && pip3 -V  # show : pip 9.0.1
# 【若报错】： No module named ‘distutils.util’ ：
# sudo apt install -y python3-distutils
# 【若报错】： Package python3-distutils has no installation candidate ：
# sudo apt update

# 更新到最新版，要用sudo，否则setuptools是装在当前用户下
# wget https://files.pythonhosted.org/packages/cb/28/91f26bd088ce8e22169032100d4260614fc3da435025ff389ef1d396a433/pip-20.2.4-py2.py3-none-any.whl && sudo python3 -m pip install -U pip-20.2.4-py2.py3-none-any.whl 
sudo python3 -m pip install -U pip==20.2.4

sudo python3 -m pip install -U testresources==2.0.1
# 更新 setuptools 。不理报错
sudo python3 -m pip install setuptools==49.6.0 --use-feature=2020-resolver

# 监控系统运行情况，比如GPU使用率等
sudo -H pip3 install jetson-stats==3.0.2
# Usage : sudo jtop
```

## 2.2 安装 venv
```shell
sudo apt install -y python3-venv
```

# 3. 操作系统级 protobuf安装
 
## 3.1 安装
```shell
mkdir -p /data/protobuf/src && cd /data/protobuf/src
# 内网机器上：
scp fd@172.168.0.216:/data3/HyrenEdge/protobuf-python-3.8.0.zip .
scp fd@172.168.0.216:/data3/HyrenEdge/protoc-3.8.0-linux-aarch_64.zip .
#scp root@172.168.0.100:/data1/HyrenEdge/protobuf-python-3.8.0.zip .  # 5t6y0524A!
#scp root@172.168.0.100:/data1/HyrenEdge/protoc-3.8.0-linux-aarch_64.zip .  # 5t6y0524A!
# OR:
curl -s -O ftp://ftp:@172.168.0.100/protobuf-python-3.8.0.zip
curl -s -O ftp://ftp:@172.168.0.100/protoc-3.8.0-linux-aarch_64.zip

# 解压
ls
unzip protobuf-python-3.8.0.zip && unzip protoc-3.8.0-linux-aarch_64.zip -d protoc-3.8.0
ls

sudo cp protoc-3.8.0/bin/protoc /usr/local/bin/protoc

# Build and install protobuf-3.8.0 libraries
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp
# 方式 1 : 编译安装
# cd protobuf-3.8.0/
# ./autogen.sh
# ./configure --prefix=/usr/local
# make -j4
# 检查make编译结果。这一步非常耗时(半个多小时)。最后应该是7个项目都是PASS。
# 可不做，一般不会有问题，以后有问题了再做。
# make check

# 方式 2 : 解压安装 -- 开始
# cp /mnt/usb1/hre/nano/protobuf-3.8.0.make.tar.gz .
# tar xf protobuf-3.8.0.make.tar.gz
# scp root@172.168.0.100:/data1/HyrenEdge/nano/protobuf-3.8.0.make.tar.gz .  # 5t6y0524A!
# scp fd@172.168.0.216:/data3/HyrenEdge/nano/protobuf-3.8.0.make.tar.gz .
# OR:
curl -O ftp://ftpgets:hre118@172.168.0.216:10021/nano/protobuf-3.8.0.make.tar.gz
#curl -s -O ftp://ftp:@172.168.0.100/nano/protobuf-3.8.0.make.tar.gz

tar xf protobuf-3.8.0.make.tar.gz
cd protobuf-3.8.0/
# make check  # 检查解压包里面make编译结果
# 方式 2 : 解压安装  -- 结束

# 安装
nohup sudo make install &
tail -f /data/protobuf/src/protobuf-3.8.0/nohup.out
sudo ldconfig
```

## 3.2 卸载系统protobuf
```shell
sudo pip3 uninstall -y protobuf
```

## 3.3 安装python运行库

```shell
# Update python3 protobuf module
sudo python3 -m pip install Cython==0.29.21
cd /data/protobuf/src/protobuf-3.8.0/python/
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp
python3 setup.py build --cpp_implementation
python3 setup.py test --cpp_implementation
sudo python3 setup.py install --cpp_implementation
```

## 3.4 验证

```shell
cd /tmp && mkdir app
cat > app/people.proto << EOF
syntax = "proto3";
message people
{
    string name = 1;
    int32 height = 2;
}
EOF

# compile
mkdir app_out
protoc -I=./app --python_out=./app_out/ app/people.proto

# test codefile
cat > app_out/test.py << EOF
import people_pb2

pbFirstPeople = people_pb2.people()
pbFirstPeople.name = "joey"
pbFirstPeople.height = 160
print(pbFirstPeople)
EOF

# 查看结果
python3 app_out/test.py
```

**结果应显示如下：**  
```txt
name: "joey"
height: 160
```

# 4. 安装 tensorflow

## 4.1 安装依赖软件
```shell
sudo apt install -y libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev liblapack-dev libblas-dev gfortran
# sudo apt-get install python3-pip 官方步骤有这个
```

## 4.2 创建虚拟环境
### 构建环境
```shell
cd /data
# 内网机器上：
#scp fd@172.168.0.216:/data3/HyrenEdge/nano/nano-pyvenv.tar.gz .
# cp /mnt/usb1/hre/nano/nano-pyvenv.tar.gz /data
#scp root@172.168.0.100:/data1/HyrenEdge/nano/nano-pyvenv.tar.gz .  # 5t6y0524A!
curl -O ftp://ftpgets:hre118@172.168.0.216:10021/nano/nano-pyvenv.tar.gz

su - hyren

tar xf /data/nano-pyvenv.tar.gz
mkdir python && mv venv/ python/ && ls -l python
```

### 拷贝虚拟环境启动文件方便后续使用
```shell
cp /hyren/python/venv/tf-1.15/bin/activate ~/pyvenv-tf15
```

## 4.3 安装工具软件
```shell
# 监控系统运行情况，比如GPU使用率等
#sudo -H pip3 install jetson-stats==3.0.2
# Usage : sudo jtop
```

## 4.4 验证
```shell
PYTHON_CMD=/hyren/python/venv/tf-1.15/bin/python3

protoc --version   # show : 3.8.0
$PYTHON_CMD -c "import google.protobuf as p; print(p.__version__)"  # show : 3.8.0

$PYTHON_CMD -c "import keras; print(keras.__version__)"  # show : 2.3.1
$PYTHON_CMD -c "import tensorflow as tf; print(tf.__version__)"  # show : 1.15.4

$PYTHON_CMD -c "import cv2; print(cv2.__version__)"  # show : 4.1.1
```

---

[首 页](https://patrickj-fd.github.io/index)