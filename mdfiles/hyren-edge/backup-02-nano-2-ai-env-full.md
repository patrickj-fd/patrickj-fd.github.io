[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 1. 操作系统级 OS 软件环境安装

以下软件包，对OpenCV，以及后续做Tensorflow/Pytorch编译和运行，都是必须的

```shell
su - pi
# 最好在官方源上做update和安装。换成国内源后，有可能出现安装失败的情况
sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential make cmake cmake-curses-gui \
         git g++ pkg-config curl libfreetype6-dev \
         libcanberra-gtk-module libcanberra-gtk3-module
sudo apt install -y libpython3.6-dev
sudo apt install -y python3-dev python3-testresources
sudo apt install -y autoconf libtool

sudo apt install -y libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg-dev liblapack-dev libblas-dev gfortran
sudo apt install -y libopenblas-base libopenmpi-dev cmake libopenblas-dev

```

# 2. 操作系统级 python 环境安装

## 2.1 安装 pip
```shell
cd /data
~/mount 1
# 安装 pip
# wget -c --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-19.6.tar.gz
# 华为云上也可以下载软件：sftp root@139.9.126.19 get /data/hre/setuptools-19.6.tar.gz
cp /mnt/usb1/hre/setuptools-19.6.tar.gz .
tar xf setuptools-19.6.tar.gz && cd setuptools-19.6/
python3 setup.py build
sudo python3 setup.py install

sudo apt install -y python3-pip
# 【若报错】： No module named ‘distutils.util’ ：
# sudo apt install -y python3-distutils
# 【若报错】： Package python3-distutils has no installation candidate ：
# sudo apt update

pip3 -V  # show : pip 9.0.1
# 更新到最新版，要用sudo，否则setuptools是装在当前用户下
sudo python3 -m pip install -U pip==20.2.4
sudo python3 -m pip install -U testresources
# 更新 setuptools 。不理报错
sudo python3 -m pip install setuptools==49.6.0 --use-feature=2020-resolver
```

## 2.2 安装 venv
```shell
sudo apt install -y python3-venv
```

# 3. 操作系统级 protobuf安装
 
**注意：** 不要使用apt安装。应该基于源码编译安装较新的版本，比如3.8.0。 protobuf libraries 对tensorflow等软件产生巨大的性能影响。

## 3.1 源码编译安装
```shell
mkdir -p /data/protobuf/src && cd /data/protobuf/src
# Install protoc
# wget -c https://github.com/protocolbuffers/protobuf/releases/download/v3.8.0/protobuf-python-3.8.0.zip
# wget -c https://github.com/protocolbuffers/protobuf/releases/download/v3.8.0/protoc-3.8.0-linux-aarch_64.zip
cp /mnt/usb1/hre/protobuf-python-3.8.0.zip .
cp /mnt/usb1/hre/protoc-3.8.0-linux-aarch_64.zip .
unzip protobuf-python-3.8.0.zip
unzip protoc-3.8.0-linux-aarch_64.zip -d protoc-3.8.0
sudo cp protoc-3.8.0/bin/protoc /usr/local/bin/protoc

# Build and install protobuf-3.8.0 libraries
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp

# 方式1：解压make好的包（/data/protobuf/src）
cp /mnt/usb1/hre/nano/protobuf-3.8.0.make.tar.gz .
tar xf protobuf-3.8.0.make.tar.gz
cd protobuf-3.8.0/
# 方式2：源码编译
cd protobuf-3.8.0/
./autogen.sh
./configure --prefix=/usr/local
make -j4

# 检查make编译结果。这一步非常耗时(半个多小时)。最后应该是7个项目都是PASS。
# 可不做，一般不会有问题，以后有问题了再做。
make check

sudo make install
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
```

### 编译
```shell
mkdir app_out
protoc -I=./app --python_out=./app_out/ app/people.proto
```

### vi app_out/test.py
```shell
cat > app_out/test.py << EOF
import people_pb2

pbFirstPeople = people_pb2.people()
pbFirstPeople.name = "joey"
pbFirstPeople.height = 160
print(pbFirstPeople)
EOF
```

### 查看结果
```shell
python3 app_out/test.py

# 结果显示：
name: "joey"
height: 160
```

# 4. 安装 tensorflow 在虚拟环境中
- [官方安装文档](https://docs.nvidia.com/deeplearning/frameworks/install-tf-jetson-platform/index.html)

## 4.1 安装依赖软件
```shell
sudo apt-get install libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev liblapack-dev libblas-dev gfortran
# sudo apt-get install python3-pip 官方步骤有这个

# 挂上U盘，以便hyren用户能访问
~/mount 1
```

## 4.2 创建虚拟环境
### 构建环境
- 解压nano.pyvenv.tar.gz方式
```shell
su - hyren
cp /mnt/usb1/hre/nano/nano-pyvenv.tar.gz /hyren
tar xf nano-pyvenv.tar.gz
mkdir python
mv venv/ python/ && ls -l python
```

- 从零安装方式
```shell
su - hyren
mkdir -p /hyren/python/venv
python3 -m venv /hyren/python/venv/tf-1.15
```

### 拷贝虚拟环境启动文件方便后续使用
```shell
cp /hyren/python/venv/tf-1.15/bin/activate ~/pyvenv-tf15
```

## 4.3 虚拟环境中安装AI软件包

**解压nano.pyvenv.tar.gz方式，本步骤(4.3)全部跳过**

### 进入虚拟环境
```shell
source ~/pyvenv-tf15
```

### 安装 pip
```shell
python3 -m pip install -U pip
python3 -m pip install -U testresources /mnt/usb1/hre/setuptools-49.6.0-py3-none-any.whl --use-feature=2020-resolver
```

### 安装 protobuf
```shell
python3 -m pip install Cython
cd /data/protobuf/src/protobuf-3.8.0/python/
sudo chown -R hyren.hyren /data
python3 setup.py build --cpp_implementation
python3 setup.py test --cpp_implementation
python3 setup.py install --cpp_implementation

protoc --version
python3 -c "import google.protobuf as p; print(p.__version__)"
```

### 安装 tensorflow
```shell
# ----- 官方命令 ----- 网络不好容易出错，所以可以先下载下来再安装
# TF-2.x
$ sudo pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v44 tensorflow==2.3.1+nv20.10
# TF-1.15
$ sudo pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v44 ‘tensorflow<2’
# ----- 官方命令 -----

# 下载软件包
wget -c https://developer.download.nvidia.cn/compute/redist/jp/v44/tensorflow/tensorflow-1.15.4%2Bnv20.10-cp36-cp36m-linux_aarch64.whl
# wget -c https://developer.download.nvidia.cn/compute/redist/jp/v44/tensorflow/tensorflow-1.15.2%2Bnv20.6-cp36-cp36m-linux_aarch64.whl

# for 1.15.2+nv20.6
# python3 -m pip install numpy==1.16.1 future==0.17.1 mock==3.0.5 h5py==2.9.0 keras_preprocessing==1.0.5 keras_applications==1.0.8 gast==0.2.2 futures protobuf pybind11 -- 这个来自：https://forums.developer.nvidia.com/t/official-tensorflow-for-jetson-nano/71770

# for 1.15.4+nv20.10
python3 -m pip install numpy==1.16.1 future==0.18.2 mock==3.0.5 h5py==2.10.0 keras_preprocessing==1.1.1 keras_applications==1.0.8 gast==0.2.2 futures protobuf pybind11

SOFT_ROOT=/mnt/usb1/hre/nano/tensorflow
# python3 -m pip install ${SOFT_ROOT}/tensorboard-1.15.0-py3-none-any.whl
python3 -m pip install -U tensorboard==1.15.0
# 装tensorboard时会同时安装 grpcio-1.33.2.tar.gz。如果失败了，就下载下载再装一次
# python3 -m pip install ${SOFT_ROOT}/grpcio-1.30.0.tar.gz

TF_VERSION=1.15.4
NV_VERSION=20.10
pip3 install --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v44 tensorflow==$TF_VERSION+nv$NV_VERSION
#python3 -m pip install ${SOFT_ROOT}/tensorflow-1.15.4+nv20.10-cp36-cp36m-linux_aarch64.whl

# scipy 安装非常慢，后台执行
python3 -m pip install ${SOFT_ROOT}/scipy-1.5.1.tar.gz
python3 -m pip install keras==2.3.1
```

### 安装 OpenCV
```shell
# 把系统中安装的opencv拷贝到虚拟环境中即可
cp -r /usr/lib/python3.6/dist-packages/cv2 /hyren/python/venv/tf-1.15/lib/python3.6/site-packages/
```

## 4.4 验证
```shell
source ~/pyvenv-tf15

protoc --version   # show : 3.8.0
python3 -c "import google.protobuf as p; print(p.__version__)"  # show : 3.8.0

python3 -c "import keras; print(keras.__version__)"  # show : 2.3.1
python3 -c "import tensorflow as tf; print(tf.__version__)"  # show : 1.15.4

python3 -c "import cv2; print(cv2.__version__)"  # show : 4.1.1
```

```python
import keras
print(keras.__version__)

import tensorflow as tf
tf.__version__
a = tf.placeholder(tf.float32)
b = tf.placeholder(tf.float32)
add = tf.add(a, b)
sess = tf.Session()
binding = {a: 1.5, b: 2.5}
c = sess.run(add, feed_dict=binding)
print(c)
sess.close()
```

## 4.5 退出虚拟环境
```shell
deactivate
```

---

[首 页](https://patrickj-fd.github.io/index)