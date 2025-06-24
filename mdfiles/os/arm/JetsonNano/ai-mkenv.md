[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 设置 OS 软件环境

以下软件包，对OpenCV，以及后续做Tensorflow/Pytorch编译和运行，都是必须的

```shell
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
sudo python3 -m pip install -U setuptools
```

## 安装 venv
```shell
sudo apt install -y python3-venv
```

# 安装 protobuf
 
**注意：** 不要使用apt安装。应该基于源码编译安装较新的版本，比如3.8.0。 protobuf libraries 对tensorflow等软件产生巨大的性能影响。

```shell
mkdir -p /data1/protobuf/src && cd /data1/protobuf/src
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
cd /data1/protobuf/src/protobuf-3.8.0/python/
python3 setup.py build --cpp_implementation
python3 setup.py test --cpp_implementation
sudo python3 setup.py install --cpp_implementation
```

- 验证

1) vi app/people.proto
```txt
syntax = "proto3";
message people
{
    string name = 1;
    int32 height = 2;
}
```

2) 编译
```shell
protoc -I=./app --python_out=./app_out/ app/people.proto
```

3) vi app_out/test.py
```python
import people_pb2

pbFirstPeople = people_pb2.people()
pbFirstPeople.name = "joey"
pbFirstPeople.height = 160
print(pbFirstPeople)
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

# 下载tensorflow wheels文件：
# https://developer.download.nvidia.cn/compute/redist/jp/v44/tensorflow/
axel -n 16 https://developer.download.nvidia.cn/compute/redist/jp/v44/tensorflow/tensorflow-1.15.2+nv20.6-cp36-cp36m-linux_aarch64.whl

# 官方提供的安装方式：
# TF-2.x
$ sudo pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v44 tensorflow==2.2.0+nv20.6
# TF-1.15
$ sudo pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v44 ‘tensorflow<2’
# 指定版本安装： https://..../v44 tensorflow==$TF_VERSION+nv$NV_VERSION
# TF_VERSION 例如 1.13.1
# NV_VERSION 例如 20.04
```

## 2) 创建虚拟环境
```shell
python3 -m venv /data1/python/venv/tf-1.15
cp /data1/python/venv/tf-1.15/bin/activate ~/pyvenv-tf15
source ~/pyvenv-tf15

# ===== 安装 pip 包
# 官方推荐：numpy==1.16.1 future==0.17.1 mock==3.0.5 h5py==2.9.0 keras_preprocessing==1.0.5 keras_applications==1.0.8 gast==0.2.2 futures protobuf pybind11
python3 -m pip install -U pip setuptools
python3 -m pip install -U testresources
# 把系统中安装的opencv拷贝到虚拟环境中
cp -r /usr/lib/python3.6/dist-packages/cv2 /data1/python/venv/tf-1.15/lib/python3.6/site-packages/
python3 -c "import cv2; print(cv2.__version__)"
```

## 3) 安装 protobuf

使用上面《安装 protobuf》章节中的 “安装python运行库” 的命令进行安装！

## 4) 安装 tensorflow
```shell
python3 -m pip install  numpy-1.16.6.zip
# grpcio 安装非常慢，后台执行
nohup python3 -m pip install grpcio-1.30.0.tar.gz &
python3 -m pip install tensorboard-1.15.0.whl
nohup python3 -m pip install tensorflow-1.15.2+nv20.6-cp36-cp36m-linux_aarch64.whl &

# scipy 安装非常慢，后台执行
nohup python3 -m pip install scipy-1.5.1.tar.gz &
python3 -m pip install keras==2.3.1
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
```

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
[参考](https://github.com/jkjung-avt/jetson_nano)

### 准备工作

** 把swap设置成4G，被各种人强烈建议 **

```shell
# 确保已经换了源：/etc/apt/sources.list 和 /etc/apt/sources.list.d/raspi.list
# 安装OpenCV的相关工具：gtk等
sudo apt install -y build-essential cmake git g++ pkg-config libgtk-3-dev libcanberra-gtk*
# 安装视频I/O包
sudo apt install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev
# 安装包括CMake的开发工具
sudo apt install -y build-essential cmake git pkg-config 
# 安装常用图像工具包
sudo apt install -y libjpeg-dev libjpeg8-dev libtiff-dev libtiff5-dev libjasper-dev libpng-dev libpng12-dev
# 安装视频库
sudo apt install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libx264-dev libxvidcore-dev
# 安装GTK2.0
sudo apt install -y libgtk2.0-dev
# 安装OpenCV数值优化函数包（或许还需要：libblas-dev liblapack-dev libopenblas-dev）
sudo apt install -y libatlas-base-dev gfortran
# 其他依赖包
sudo apt-get install -y libqtgui4 libqtwebkit4 libqt4-test python3-pyqt5

sudo python3 -m pip install numpy-1.18.5-cp37-cp37m-linux_armv7l.whl

git clone https://github.com/opencv/opencv.git
git clone https://github.com/opencv/opencv_contrib.git
cd opencv_contrib
git checkout 3.4.10 && git branch   # 自己要的版本
cd ../opencv
git checkout 3.4.10 && git branch   # 自己要的版本
```

Then make sure Jetson Nano is in 10W (maximum) performance mode so the building process could finish as soon as possible.
```shell
sudo nvpmodel -m 0
sudo jetson_clocks
```

### 开始编译
```shell
# 避免编译过程下载文件失败。通过www.ipaddress.com查出来IP
sudo echo "199.232.28.133 raw.githubusercontent.com" >> /etc/hosts

# 创建一个临时构建目录
mkdir build && cd build

# Jetson TX2: CUDA_ARCH_BIN="6.2"
# Jetson AGX Xavier: CUDA_ARCH_BIN="7.2"

# == 配置 ==
# ENABLE_NEON ENABLE_VFPV3 针对ARM架构CPU的。 cat /proc/cpuinfo 能看到支持什么
# -D ENABLE_NEON=ON -D ENABLE_VFPV3=ON
# -D OPENCV_ENABLE_NONFREE=ON
# -D WITH_LIBV4L=ON 开启Video(video for linux 2)
# -D WITH_TBB=ON -D WITH_V4L=ON -D WITH_QT=ON -D WITH_OPENGL=ON
# 下载可以不加，会自动检测出来
#    -D PYTHON3_EXECUTABLE=/usr/bin/python3.7 \
#    -D PYTHON_INCLUDE_DIR=/usr/include/python3.7 \
#    -D PYTHON_LIBRARY=/usr/lib/arm-linux-gnueabihf/libpython3.7m.so \
#    -D PYTHON3_NUMPY_INCLUDE_DIRS=/usr/local/lib/python3.7/dist-packages/numpy/core/include \
cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/opt/opencv3.4.10 \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D ENABLE_NEON=ON -D ENABLE_VFPV3=ON \
    -D INSTALL_C_EXAMPLES=OFF \
    -D INSTALL_CXX_EXAMPLES=OFF \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D BUILD_TESTS=OFF \
    -D OPENCV_EXTRA_MODULES_PATH=/data1/soft/opencv-gitsrc/opencv_contrib/modules \
    -D BUILD_EXAMPLES=OFF \
    ..
## 最后的 .. 表示上级目录
# 在当前目录下生成很多配置、编译相关的文件，其中 CMakeCache.txt文件可以自己修改，关闭不要的功能模块。
# 比如： WITH_1394:BOOL=OFF。make时出错的模块可以不编译可以通过CMakeCache.txt文件配置关掉
vi CMakeCache.txt # WITH_1394:BOOL=OFF

# 对下载失败的文件，在CMakeDownloadLog.txt里面找到下载地址，手动下载
vi CMakeDownloadLog.txt
# 把下载的文件，放到： opencv_contrib/modules/xfeatures2d/src/ 即可开始后面的make了
# 或者也许，提前放到opencv/.cache/xfeatures2d/下的boostdesc和vgg目录下

# face_landmark_model.dat 下载失败，手动下载
vi modules/face/CMakeLists.txt
# 把："https://raw.githubusercontent.com/opencv/opencv_3rdparty/${__commit_hash}/"
# 改："file:///这个文件的全路径"（不带文件名）

# == 编译 ==
# 为了避免怪异问题发生，不用并行编译
make -j1

# == 安装 == 安装到前面指定的目录（CMAKE_INSTALL_PREFIX）
make install
# 验证
/opt/opencv3.4.10/bin/opencv_version

# 安装给python
cp -r /opt/opencv3.4.10/lib/python3.7/dist-packages/cv2 ~/.local/lib/python3.7/site-packages
python3 -c "import cv2; print(cv2.__version__)"
# 如果要安装到其他机器上，把/opt/opencv3.4.10整个复制新机器的opt目录下，即可

# 或者，把so加入到系统中（没验证）
echo "/opt/opencv3.4.10/lib" > /etc/ld.so.conf.d/opencv.conf
# 或许要加上下面这句。？表示一个空格，可能原因是有的语言要求最后有一个空格才可以编译通过。
echo "?" >> /etc/ld.so.conf.d/opencv.conf
ldconfig
```

## 验证
```python
import cv2
# 显示已经安装的 opencv 版本
cv2.__version__

import numpy as np

img = np.zeros((512, 512), np.uint8)         # 生成一张空的灰度图像
cv2.line(img, (0, 0), (511, 511), 255, 5)    # 绘制一条白色直线

# 图形终端下可运行下面代码
#cv2.namedWindow("gray")
#cv2.imshow("gray",img)#显示图像
# 循环等待，按q键退出
#while True:
#    key=cv2.waitKey(1)
#    if key==ord("q"):
#        break
#cv2.destoryWindow("gray")

cv2.imwrite('messigray.png', img)

```

- [树莓派4 安装OPENCV3](https://blog.csdn.net/weixin_43287964/article/details/101696036)

# pytorch

Docker
> https://ngc.nvidia.com/catalog/containers/nvidia:l4t-pytorch

**NOTE :**
- The JetPack 4.4 production release (L4T R32.4.3) only supports PyTorch 1.6.0 or newer.
- PyTorch 1.6.0-rc2, matched to torchvision v0.7.0-rc2.
- [官方发布的预编译whl及讨论](https://forums.developer.nvidia.com/t/pytorch-for-jetson-nano-version-1-5-0-now-available/72048)

## 源码编译安装

#### 安装依赖
```shell
sudo apt install -y python3-dev
# sudo apt install -y libopenblas-dev cython3 libatlas-base-dev m4 libblas-dev cmake
sudo apt install -y libopenblas-base libopenmpi-dev cmake libopenblas-dev

# Max Performance
sudo nvpmodel -m 0     # on Xavier NX, use -m 2  instead
sudo jetson_clocks
```

#### 编译
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

# 创建虚拟环境
sudo apt install -y python3-venv
mkdir -p /data1/python/venv && python3 -m venv /data1/python/venv/pytorch-1.5.1
source /data1/python/venv/pytorch-1.5.1/bin/activate
python3 -m pip install -U setuptools pip

# 设置环境变量： vi setup.py 看看应该怎么设置这些参数
export USE_NCCL=0
export USE_DISTRIBUTED=0                # skip setting this if you want to enable OpenMPI backend
export USE_QNNPACK=0
export USE_PYTORCH_QNNPACK=0
export TORCH_CUDA_ARCH_LIST="5.3;6.2;7.2"
echo "$USE_NCCL $USE_DISTRIBUTED $USE_QNNPACK $USE_PYTORCH_QNNPACK | $TORCH_CUDA_ARCH_LIST"

export PYTORCH_BUILD_VERSION=1.5.1      # without the leading 'v'
export PYTORCH_BUILD_NUMBER=1

# 先安装numpy，否则编译出来的PyTorch不支持numpy。
cat requirements.txt   # 看看版本有什么问题
python3 -m pip install -r requirements.txt
python3 -m pip install scikit-build
python3 -m pip install ninja

# 编译安装
# 1) 编译成wheel文件，以便到处安装
python3 setup.py bdist_wheel
# 如果报错： error: invalid command 'bdist_wheel'
# python3 -m pip install wheel
# python3 -m pip install --upgrade setuptools

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