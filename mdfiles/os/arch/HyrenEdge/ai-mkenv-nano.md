[首 页](https://patrickj-fd.github.io/index)

---

# 设置 OS 软件环境

以下软件包，对OpenCV，以及后续做Tensorflow/Pytorch编译和运行，都是必须的

```shell
cd /data

# 最好在官方源上做update和安装。换成国内源后，有可能出现安装失败的情况
sudo apt update
sudo apt install -y build-essential make cmake cmake-curses-gui
sudo apt install -y git g++ pkg-config curl libfreetype6-dev
sudo apt install -y libcanberra-gtk-module libcanberra-gtk3-module
sudo apt install -y libpython3.6-dev
sudo apt install -y python3-dev python3-testresources
sudo apt install -y autoconf libtool

sudo apt install -y libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg-dev liblapack-dev libblas-dev gfortran
sudo apt install -y libopenblas-base libopenmpi-dev cmake libopenblas-dev

```

# 设置 python 环境

## 安装 pip
```shell
# 安装 pip
wget -c --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-19.6.tar.gz
tar xf setuptools-19.6.tar.gz && cd setuptools-19.6/
python3 setup.py build
sudo python3 setup.py install

sudo apt install -y python3-pip
# 若报错： No module named ‘distutils.util’
sudo apt install -y python3-distutils
# 若报错： Package python3-distutils has no installation candidate
sudo apt update

pip3 -V
# 更新到最新版，要用sudo，否则setuptools是装在当前用户下
sudo python3 -m pip install -U pip
sudo python3 -m pip install -U setuptools==49.6.0  # --use-feature=2020-resolver
```

## 安装 venv
```shell
sudo apt install -y python3-venv
```

# 安装 protobuf
 
**注意：** 不要使用apt安装。应该基于源码编译安装较新的版本，比如3.8.0。 protobuf libraries 对tensorflow等软件产生巨大的性能影响。

```shell
mkdir -p /data/protobuf/src && cd /data/protobuf/src
# Install protoc
wget -c https://github.com/protocolbuffers/protobuf/releases/download/v3.8.0/protobuf-python-3.8.0.zip
wget -c https://github.com/protocolbuffers/protobuf/releases/download/v3.8.0/protoc-3.8.0-linux-aarch_64.zip
unzip protobuf-python-3.8.0.zip
unzip protoc-3.8.0-linux-aarch_64.zip -d protoc-3.8.0
sudo cp protoc-3.8.0/bin/protoc /usr/local/bin/protoc

# Build and install protobuf-3.8.0 libraries
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp
cd protobuf-3.8.0/
./autogen.sh
./configure --prefix=/usr/local
make -j4
# 检查make编译结果。这一步非常耗时(半个多小时)。最后应该是7个项目都是PASS
make check
sudo make install
sudo ldconfig

# 卸载系统protobuf
sudo pip3 uninstall -y protobuf
```

#### 安装python运行库

用下面命令，是安装在系统环境中。对于使用py虚拟环境的情况，是否还有执行一遍，待确认！

```shell
# Update python3 protobuf module
sudo python3 -m pip install Cython
cd /data/protobuf/src/protobuf-3.8.0/python/
python3 setup.py build --cpp_implementation
python3 setup.py test --cpp_implementation
sudo python3 setup.py install --cpp_implementation
```

- 验证

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

2) 编译
```shell
mkdir app_out
protoc -I=./app --python_out=./app_out/ app/people.proto
```

3) vi app_out/test.py
```python
cat > app_out/test.py << EOF
import people_pb2

pbFirstPeople = people_pb2.people()
pbFirstPeople.name = "joey"
pbFirstPeople.height = 160
print(pbFirstPeople)
EOF
```

4) 结果
```shell
cd app_out
python3 test.py

# 结果显示：
name: "joey"
height: 160
```

# 安装 tensorflow
参考官方指定：
> https://docs.nvidia.com/deeplearning/frameworks/install-tf-jetson-platform/index.html

## 1) 安装依赖软件
```shell
sudo apt-get install libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev liblapack-dev libblas-dev gfortran
# sudo apt-get install python3-pip 官方步骤有这个

# 各个预先下载好的软件包的根目录
SOFT_ROOT=/mnt/usb1/python/soft

# 以下内容供参考，不需要执行。
# 下载tensorflow wheels文件：
# https://developer.download.nvidia.cn/compute/redist/jp/v44/tensorflow/
axel -n 16 https://developer.download.nvidia.cn/compute/redist/jp/v44/tensorflow/tensorflow-1.15.2+nv20.6-cp36-cp36m-linux_aarch64.whl
axel -n 16 https://developer.download.nvidia.cn/compute/redist/jp/v44/tensorflow/tensorflow-1.15.4+nv20.10-cp36-cp36m-linux_aarch64.whl

# 官方提供的安装方式：
# TF-2.x
$ sudo pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v44 tensorflow==2.2.0+nv20.6
# TF-1.15
$ sudo pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v44 'tensorflow<2'
# 指定版本安装： https://..../v44 tensorflow==$TF_VERSION+nv$NV_VERSION
# TF_VERSION 例如 1.13.1
# NV_VERSION 例如 20.04
```

## 2) 创建虚拟环境
```shell
mkdir -p /hyren/python/venv
python3 -m venv /hyren/python/venv/tf-1.15
cp /hyren/python/venv/tf-1.15/bin/activate ~/pyvenv-tf15
source ~/pyvenv-tf15

# ===== 安装 pip 包
python3 -m pip install -U pip
python3 -m pip install -U testresources setuptools==49.6.0  # --use-feature=2020-resolver
```

## 3) 安装 protobuf
使用上面《安装 protobuf》章节中的 “安装python运行库” 的命令进行安装！注意去掉sudo。
这一步骤目前暂时没做，后面有影响了再搞
```shell
python3 -m pip install Cython
cd /data/protobuf/src/protobuf-3.8.0/python/
python3 setup.py build --cpp_implementation
python3 setup.py test --cpp_implementation
python3 setup.py install --cpp_implementation
```

## 4) 安装 tensorflow
```shell
# TF-2.x
$ sudo pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v44 tensorflow==2.3.1+nv20.10
# TF-1.15
$ sudo pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v44 ‘tensorflow<2’

# python3 -m pip install numpy==1.16.1 future==0.17.1 mock==3.0.5 h5py==2.9.0 keras_preprocessing==1.0.5 keras_applications==1.0.8 gast==0.2.2 futures protobuf pybind11 -- 这个来自：https://forums.developer.nvidia.com/t/official-tensorflow-for-jetson-nano/71770
python3 -m pip install numpy==1.16.1 future==0.18.2 mock==3.0.5 h5py==2.10.0 keras_preprocessing==1.1.1 keras_applications==1.0.8 gast==0.2.2 futures protobuf pybind11
python3 -m pip install -U tensorboard==1.15.0

TF_VERSION=1.15.2
NV_VERSION=20.06
pip3 install --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v44 tensorflow==$TF_VERSION+nv$NV_VERSION
# 上面如果下载不了，就之间下载安装包
 wget -c https://developer.download.nvidia.cn/compute/redist/jp/v44/tensorflow/tensorflow-$TF_VERSION+nv$NV_VERSION-cp36-cp36m-linux_aarch64.whl
python3 -m pip install tensorflow-$TF_VERSION+nv$NV_VERSION-cp36-cp36m-linux_aarch64.whl
# https://developer.download.nvidia.cn/compute/redist/jp/v44/tensorflow/tensorflow-1.15.2%2Bnv20.6-cp36-cp36m-linux_aarch64.whl

# ------ 废弃 ------ Start
#python3 -m pip install  numpy-1.16.6.zip
# grpcio 安装非常慢，可以nohup后台执行
python3 -m pip install ${SOFT_ROOT}/grpcio-1.30.0.tar.gz
python3 -m pip install ${SOFT_ROOT}/tensorboard-1.15.0-py3-none-any.whl
# tensorflow 安装非常慢，可以nohup后台执行
python3 -m pip install ${SOFT_ROOT}/tensorflow-1.15.2+nv20.6-cp36-cp36m-linux_aarch64.whl
# ------ 废弃 ------ End

# scipy 安装非常慢，后台执行
python3 -m pip install ${SOFT_ROOT}/scipy-1.5.1.tar.gz
python3 -m pip install keras==2.3.1
python3 -c "import keras; print(keras.__version__)"
python3 -c "import tensorflow as tf; print(tf.__version__)"
```

## 5) 验证
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

# OpenCV
## 检查系统opencv情况
```shell
# 查看opencv版本
pkg-config opencv --modversion

# 查看opencv安装库
pkg-config opencv --libs

# 把系统中安装的opencv拷贝到虚拟环境中
cp -r /usr/lib/python3.6/dist-packages/cv2 /hyren/python/venv/tf-1.15/lib/python3.6/site-packages/
python3 -c "import cv2; print(cv2.__version__)"  # show : 4.1.1
```

---

[首 页](https://patrickj-fd.github.io/index)