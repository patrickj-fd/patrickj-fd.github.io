[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 删除 python2
```shell
sudo apt remove --purge python
sudo apt remove --auto-remove python2.7
sudo apt clean
# 确认
ll /usr/bin/py*
```

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

# ======= 开始编译 =======
# 避免编译过程下载文件失败。通过www.ipaddress.com查出来IP
sudo echo "199.232.28.133 raw.githubusercontent.com" >> /etc/hosts

# 创建一个临时构建目录
mkdir build && cd build

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
make -j4

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

官网上已经有了aarch64版，如果在armv7l下，只能源码编译安装。

### python 3.7 下源码编译安装

```shell
# 下载源码。必须加上recursive，下载pytorch依赖的各种外部链接库
git clone --recursive https://github.com/pytorch/pytorch
cd pytorch
# 在 aarch64 系统下，要使用最新的1.6。v1.5.1无法编译过去，会停在 [53%] XNNPACK 报错。
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
Venv_RootDir=/data1/python/venv
mkdir -p $Venv_RootDir && python3 -m venv $Venv_RootDir/pytorch-1.5.1
cp $Venv_RootDir/pytorch-1.5.1/bin/activate ~/pyv.pytorch-1.5.1
source ~/pyv.pytorch-1.5.1
python3 -m pip install -U setuptools pip

# 安装依赖包：
python3 -m pip install -r requirements.txt
# 因为编译的1.5.1不是最新版本，为了避免numpy可能出现版本太高的问题，最好明确指定版本
# 先安装numpy，否则编译出来的PyTorch不支持numpy。
# 在 Debian-Pi-Aarch64-2020-06-15-U3 的64位环境下，不能指定版本号，否则会报mkl找不到的错误
python3 -m pip install numpy==1.18.5
python3 -m pip install future pyyaml requests six

# 设置环境变量(树莓派不支持GPU)： vi setup.py 看看应该怎么设置这些参数
export USE_CUDA=0
export USE_CUDNN=0
export USE_MKLDNN=0
export USE_DISTRIBUTED=0
export USE_NNPACK=0
export USE_QNNPACK=0
# armv7l 下，不需要把USE_FBGEMM设置为0
export USE_FBGEMM=0
export MAX_JOBS=1
echo USE_CUDA=$USE_CUDA USE_CUDNN=$USE_CUDNN USE_MKLDNN=$USE_MKLDNN USE_DISTRIBUTED=$USE_DISTRIBUTED
echo USE_NNPACK=$USE_NNPACK USE_QNNPACK=$USE_QNNPACK USE_FBGEMM=$USE_FBGEMM MAX_JOBS=$MAX_JOBS

# 编译安装
# 1) 编译成wheel文件，以便到处安装
python3 -m pip install wheel
nohup python3 setup.py bdist_wheel &
tail -f nohup.out
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