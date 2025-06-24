[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 删除 python2
```shell
su - pi

# 查看Python的可选项
#update-alternatives --display python
# /usr/bin/python 链接文件，两个可选项必须是一样的，这样这个链接文件才可以选择两个不同的可选项去链接
# 把python3的优先级设置成更大的数字
#sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 100
#sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 150
# 这时如果我们查看 /usr/bin/python 这个文件时，会发现它已经链接到了 /etc/alternatives/python
# sudo update-alternatives --config python

sudo apt remove --purge python
sudo apt remove --auto-remove python2.7
sudo apt clean
ll /usr/bin/py*
# 确认
python -V  # show : Python 3.7.3
```

# tensorflow
```shell
sudo apt install build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libhdf5-dev  python3-dev gfortran libblas-dev liblapack-dev libopenblas-dev libatlas-base-dev

sudo apt install -y python3-pip
# 可以先现在 https://www.piwheels.org/simple/numpy/numpy-1.16.6-cp37-cp37m-linux_armv7l.whl
sudo python3 -m pip install numpy==1.16.6
sudo apt install -y python3-venv

# 截止到 2020年7月1日 ，还是不要装1.14。因为不能和opencv3共存，keras会报错：找不到libhdfs.so
#wget -c https://www.piwheels.org/simple/tensorflow/tensorflow-1.13.1-cp37-none-linux_armv7l.whl
sudo python3 -m pip install tensorflow-1.13.1-cp37-none-linux_armv7l.whl
#sudo python3 -m pip install tensorflow==1.13.1
# absl_py-0.11.0-py3-none-any.whl grpcio-1.34.0-cp37-cp37m-linux_armv7l.whl tensorboard-1.13.1-py3-none-any.whl h5py-3.1.0-cp37-cp37m-linux_armv7l.whl tensorflow-1.13.1-cp37-none-linux_armv7l.whl scipy-1.5.4-cp37-cp37m-linux_armv7l.whl(need by keras)
WHEELS_ROOT=/mnt/usb1/hre/pi/ai
sudo python3 -m pip install *.whl

sudo python3 -m pip install keras==2.3.1

```

# OpenCV 3.4 编译安装
```shell
# 安装OpenCV的相关工具：gtk等
sudo apt install -y build-essential cmake git g++ pkg-config libgtk-3-dev libcanberra-gtk*
# 安装视频I/O包
sudo apt install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev
# 安装包括CMake的开发工具
sudo apt install -y build-essential cmake git pkg-config 
# 安装常用图像工具包 libjpeg8-dev libpng12-dev
sudo apt install -y libjpeg-dev libtiff-dev libtiff5-dev libjasper-dev libpng-dev 
# 安装视频库
sudo apt install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libx264-dev libxvidcore-dev
# 安装GTK2.0
sudo apt install -y libgtk2.0-dev
# 安装OpenCV数值优化函数包（或许还需要：libblas-dev liblapack-dev libopenblas-dev）
sudo apt install -y libatlas-base-dev gfortran
# 其他依赖包
sudo apt-get install -y libqtgui4 libqtwebkit4 libqt4-test python3-pyqt5

# 下载源码
mkdir -p /data/opencv/gitrepo && cd /data/opencv/gitrepo
git clone https://gitee.com/hyren/opencv.git
git clone https://gitee.com/hyren/opencv_contrib.git
cd opencv_contrib
git checkout 3.4.10 && git branch
cd ../opencv
git checkout 3.4.10 && git branch

# ======= 开始编译 =======
# 避免编译过程下载文件失败。通过 www.ipaddress.com 查出来IP
sudo echo "199.232.96.133 raw.githubusercontent.com" >> /etc/hosts

# 创建一个临时构建目录
mkdir build && cd build
CMAKEFILES_ROOT=/mnt/usb1/hre/pi
mkdir -p /data/opencv/gitrepo/opencv/build/downloads/xfeatures2d/
cp ${CMAKEFILES_ROOT}/raw.githubusercontent.com/xfeatures2d/* /data/opencv/gitrepo/opencv/build/downloads/xfeatures2d/
mkdir -p /data/opencv/gitrepo/opencv/build/share/OpenCV/testdata/cv/face/
cp ${CMAKEFILES_ROOT}/raw.githubusercontent.com/face_landmark_model.dat /data/opencv/gitrepo/opencv/build/share/OpenCV/testdata/cv/face/

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
#    -D PYTHON3_NUMPY_INCLUDE_DIRS=/usr/local/lib/python3.7/dist-packages/numpy/core/include \  (sudo find / -type d -name "numpy")
nohup cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/opt/opencv3.4.10 \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D ENABLE_NEON=ON -D ENABLE_VFPV3=ON \
    -D INSTALL_C_EXAMPLES=OFF \
    -D INSTALL_CXX_EXAMPLES=OFF \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D BUILD_TESTS=OFF \
    -D OPENCV_EXTRA_MODULES_PATH=/data/opencv/gitrepo/opencv_contrib/modules \
    -D PYTHON3_NUMPY_INCLUDE_DIRS=/usr/local/lib/python3.7/dist-packages/numpy/core/include \
    -D BUILD_EXAMPLES=OFF \
    .. > cmake.log 2>&1 &
## 最后的 .. 表示上级目录
tail -f cmake.log

# ---------------------------------------------------------------------
# cmake成功，最后显示三行：
-- Configuring done
-- Generating done
-- Build files have been written to: /data/opencv/gitrepo/opencv/build
# ---------------------------------------------------------------------

# 在当前目录下生成很多配置、编译相关的文件，其中 CMakeCache.txt文件可以自己修改，关闭不要的功能模块。
# 比如： WITH_1394:BOOL=OFF。make时出错的模块可以不编译可以通过CMakeCache.txt文件配置关掉
vi CMakeCache.txt # WITH_1394:BOOL=OFF

# CMakeDownloadLog.txt
# 因为上面已经把要下载的文件拷贝过来了，所以这个文件里面都是do_copy
# 如果从零开始下载，很可能会下载失败，这时就需要在这个文件里面找到下载地址，手动下载
# 把下载的文件，放到： opencv_contrib/modules/xfeatures2d/src/ 即可开始后面的make了。这个路径有问题
# face_landmark_model.dat 下载失败，手动下载
#vi modules/face/CMakeLists.txt
# 把："https://raw.githubusercontent.com/opencv/opencv_3rdparty/${__commit_hash}/"
# 改："file:///这个文件的全路径"（不带文件名）

# == 编译 ==
nohup make -j4 > make.log 2>&1 &
tail -f make.log
# make 过程中，可能会失败，一般报错为：
# make: *** [Makefile:163: all] Error 2
# 这时，要往上看很多行的日志输出，直到找到有更明确的 Error 信息
# 成功显示：[100%] Built target opencv_python3

# == 安装 == 安装到前面指定的目录（CMAKE_INSTALL_PREFIX）
nohup make install > makeinstall.log 2>&1 &
tail -f makeinstall.log
# 验证
/opt/opencv3.4.10/bin/opencv_version

# 安装给 python
cp -r /opt/opencv3.4.10/lib/python3.7/dist-packages/cv2 /usr/local/lib/python3.7/dist-packages/
# cp -r /opt/opencv3.4.10/lib/python3.7/dist-packages/cv2 虚拟环境/lib/python3.7/site-packages

python3 -c "import cv2; print(cv2.__version__)"

# 或者，把so加入到系统中（没验证）
echo "/opt/opencv3.4.10/lib" > /etc/ld.so.conf.d/opencv.conf
# 或许要加上下面这句。？表示一个空格，可能原因是有的语言要求最后有一个空格才可以编译通过。
echo "?" >> /etc/ld.so.conf.d/opencv.conf
ldconfig
```

## 验证
```python
# cat > /tmp/opencvtest.py << EOF
import cv2
import numpy as np

img = np.zeros((512, 512), np.uint8)         # 生成一张空的灰度图像
cv2.line(img, (0, 0), (511, 511), 255, 5)    # 绘制一条白色直线
cv2.imwrite('messigray.png', img)
```

---

[首 页](https://patrickj-fd.github.io/index)
