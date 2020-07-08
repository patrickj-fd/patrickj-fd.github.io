[首 页](https://patrickj-fd.github.io/index)

---

# tensorflow
```shell
sudo apt install build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libhdf5-dev  python3-dev gfortran libblas-dev liblapack-dev libopenblas-dev libatlas-base-dev

# grpcio 安装非常慢，最好下载下来，用nohup单独装
sudo nohup python3 -m pip install grpcio &
# grpcio 安装时可能报错：command: 'install_requires' must string or list of strings containing ...
sudo python3 -m pip install -U setuptools

# 安装 numpy 因为旧版本的TF不支持高版本的numpy，所以干脆装一个最后的一个py2.7兼容版 1.16.6
sudo python3 -m pip install numpy==1.16.6

# 截止到 2020年7月1日 ，还是不要装1.14。因为不能和opencv3共存，keras会报错：找不到libhdfs.so
# sudo pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple tensorflow==1.13.1
wget -c https://www.piwheels.org/simple/tensorflow/tensorflow-1.13.1-cp37-none-linux_armv7l.whl
sudo python3 -m pip install tensorflow-1.13.1-cp37-none-linux_armv7l.whl

sudo python3 -m pip install h5py pandas
# wget -c https://www.piwheels.org/simple/pandas/pandas-1.0.5-cp37-cp37m-linux_armv7l.whl

sudo python3 -m pip install keras==2.3.1

# 验证
python3

import keras
print(keras.__version__)

import tensorflow as tf
a = tf.placeholder(tf.float32)
b = tf.placeholder(tf.float32)
add = tf.add(a, b)
sess = tf.Session()
binding = {a: 1.5, b: 2.5}
c = sess.run(add, feed_dict=binding)
print(c)
sess.close()
```

如果要同时安装Opencv3和tensorflow，那么只能用python3.7安装tensorflow1.13版本的！

# OpenCV
## 安装
### 1) OpenCV3
- 方式1
```shell
sudo apt install -y python3-opencv
```

- 方式2

用方式1，安装的是3.2.0（截止2020年6月），而且，创建虚拟环境时，默认无法使用cv。  
可以直接下载指定版本的whl文件进行安装。[下载地址](https://www.piwheels.org/simple/opencv-python/)  
```shell
sudo apt install -y libqtgui4 libqt4-test
sudo apt-get install libjpeg-dev libtiff5-dev libjasper-dev libpng-dev -y
python3 -m pip install opencv_python-3.4.7.28-cp37-cp37m-linux_armv7l.whl
```

如果 import cv2 报错类似： ImportError: ... undefined symbol: ... arm-linux-gnueabihf.so __atomic_fetch_add_8。 这是一个bug，需要加载一个库文件来解决：
```shell
sudo find / -name "libatomic.so*"  # 找到 libatomic.so.1.2.0 的路径，导入环境变量
echo "export LD_PRELOAD=/usr/lib/arm-linux-gnueabihf/libatomic.so.1.2.0" >> ~/.bashrc
source ~/.bashrc
# 或者，把 LD_PRELOAD 加到虚拟环境的启动脚本中（bin/activate）
```

用这种方式，或者也可以装OpenCV4。（未验证）

### 2) OpenCV4
```shell
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install build-essential cmake pkg-config -y
sudo apt-get install libjpeg-dev libtiff5-dev libjasper-dev libpng-dev -y
sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev -y
sudo apt-get install libxvidcore-dev libx264-dev -y
sudo apt-get install libfontconfig1-dev libcairo2-dev -y
sudo apt-get install libgdk-pixbuf2.0-dev libpango1.0-dev -y
sudo apt-get install libgtk2.0-dev libgtk-3-dev -y
sudo apt-get install libatlas-base-dev gfortran -y
sudo apt-get install libhdf5-dev libhdf5-serial-dev libhdf5-103 -y
sudo apt-get install -y libqtgui4 libqtwebkit4 libqt4-test python3-pyqt5
sudo python3 -m pip install opencv-python
```

## 编译安装
```shell
git clone https://github.com/opencv/opencv.git
git clone https://github.com/opencv/opencv_contrib.git

git checkout 自己要的版本

# 创建一个临时构建目录
mkdir -p ~/opencv_build/opencv/build
cd ~/opencv_build/opencv/build

```

## 验证
```shell
python3
import cv2
# 显示已经安装的 opencv 版本
cv2.__version__
```

- [树莓派4 安装OPENCV3](https://blog.csdn.net/weixin_43287964/article/details/101696036)

# pytorch

官网上已经有了aarch64版，如果在armv7l下，只能源码编译安装。

### python 3.7 下源码编译安装

```shell
# 下载源码。必须加上recursive，下载pytorch依赖的各种外部链接库
git clone --recursive https://github.com/pytorch/pytorch
cd pytorch
git tag
git checkout v1.5.1
# git submodule update --init
git submodule sync
git submodule update --init --recursive
# 解决协议缓冲区的一个bug。否则编译到caffe2会出错
git submodule update --remote third_party/protobuf

# 安装依赖软件
sudo apt install -y libopenblas-dev cython3 libatlas-base-dev m4 libblas-dev cmake

# 创建虚拟环境
sudo apt install -y python3-venv
mkdir -p ~/python/venv && python3 -m venv ~/python/venv/pytorch
source ~/python/venv/pytorch/bin/activate
python3 -m pip install -U setuptools pip

# 安装依赖包：python3 -m pip -r requirements.txt
# 因为使用的是旧版本，为了避免numpy可能出现版本太高的问题，最好明确指定版本
# 先安装numpy，否则编译出来的PyTorch不支持numpy。
# 如果不用虚拟环境，前面加上 sudo
python3 -m pip install future numpy==1.18.6 pyyaml requests six

# 设置环境变量(树莓派不支持GPU)： vi setup.py 看看应该怎么设置这些参数
export USE_CUDA=0
export USE_CUDNN=0
export USE_MKLDNN=0
export USE_DISTRIBUTED=0
export USE_NNPACK=0
export USE_QNNPACK=0
echo $USE_CUDA $USE_CUDNN $USE_MKLDNN $USE_DISTRIBUTED $USE_NNPACK $USE_QNNPACK
# 下面这些参数是旧版本才使用的，比如v1.0.1
# export NO_CUDA=1
# export NO_DISTRIBUTED=1
# export NO_MKLDNN=1 
# export NO_NNPACK=1
# export NO_QNNPACK=1
# echo $NO_CUDA $NO_DISTRIBUTED $NO_MKLDNN

# 编译安装
# 1) 编译成wheel文件，以便到处安装
python3 setup.py bdist_wheel
# 如果报错： error: invalid command 'bdist_wheel'
# pip install wheel
# pip install --upgrade setuptools

# -- 安装
python3 -m pip install dist/yours.whl

# 2) 编译在本机后安装
python3 setup.py build
# 数小时后，看到 no longer necessary to use ‘build’ or 'rebuild’意思就是成功啦
# -- 安装
python3 setup.py install
# 如果不用虚拟环境，直接sudo安装（-E : 在sudo执行时保留当前用户已存在的环境变量，不会被sudo重置）
sudo -E python3 setup.py install

# 验证
# 要离开当前的源码编译目录，否则会报告报错：No module named 'torch._C'。
# 参见：https://github.com/pytorch/pytorch/issues/574
cd ~
python3
import torch
torch.__version__
```

### 编译 torchvision

```shell
# 不是上面的虚拟环境的话，要加上 sudo
python3 -m pip install pillow

git clone https://github.com/pytorch/vision.git
cd vision
git tag
git checkout v0.6.1
python3 setup.py bdist_wheel
```

---

[首 页](https://patrickj-fd.github.io/index)