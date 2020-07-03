[首 页](https://patrickj-fd.github.io/index)

---


```shell
sudo apt install build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libhdf5-dev  python3-dev gfortran libblas-dev liblapack-dev libopenblas-dev libatlas-base-dev

# grpcio 安装非常慢，最好下载下来，用nohup单独装
sudo nohup python3 -m pip install grpcio &
# grpcio 安装时可能报错：command: 'install_requires' must string or list of strings containing ...
sudo python3 -m pip install -U setuptools

# sudo pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple tensorflow==1.14.0
wget -c https://www.piwheels.org/simple/tensorflow/tensorflow-1.14.0-cp37-none-linux_armv7l.whl
sudo python3 -m pip install tensorflow-1.14.0-cp37-none-linux_armv7l.whl

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

- [树莓派4 安装OPENCV3](https://blog.csdn.net/weixin_43287964/article/details/101696036)


---

[首 页](https://patrickj-fd.github.io/index)