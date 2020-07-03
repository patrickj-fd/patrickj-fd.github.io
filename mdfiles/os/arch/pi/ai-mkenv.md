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
```shell
sudo apt install -y python3-opencv
```

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


---

[首 页](https://patrickj-fd.github.io/index)