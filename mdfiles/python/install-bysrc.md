[首 页](https://patrickj-fd.github.io/index)

---

# 编译安装
```shell
# 下载
wget -c https://www.python.org/ftp/python/3.6.9/Python-3.6.9.tgz

# 安装必要的软件
apt install -y zlib zlib-devel openssl openssl-devel openssl-static \
bzip2 bzip2-devel \
ncurses ncurses-devel \
readline readline-devel \
xz lzma xz-devel \
sqlite sqlite-devel \
gdbm gdbm-devel \
tk tk-devel \
gcc gcc-c++

# 编译安装
PYTHON_VERSION=3.6.9
# 设置临时变量：python的安装目录
PYTHON_HOME=/opt/Python-$PYTHON_VERSION

tar zxf Python-$PYTHON_VERSION.tgz -C /tmp
cd /tmp/Python-$PYTHON_VERSION
# 不加也行： --enable-loadable-sqlite-extensions --with-system-expat --with-system-ffi
# 可以加上： --enable-optimizations --enable-shared
./configure --prefix=$PYTHON_HOME
make -j 8
make install

# 3. 配置软连接
ln -s $PYTHON_HOME/bin/python3 /usr/bin/python3
ln -s $PYTHON_HOME/bin/pip3 /usr/bin/pip3
python3 -V
pip3 -V
```

# 创建虚拟环境
```shell
# 在当前目录下创建名字为 tf15 的虚拟环境
python3 -m venv tf15

# 启动（进入）虚拟环境
source tf15/bin/activate
# 退出
deactivate
```
- 如果要继承系统中的包，增加参数：--system-site-packages
- 使用--prompt 指定vm的命令行提示名



python2中，需要单独安装virtualenv软件
```shell
pip3 install virtualenv -i https://mirrors.aliyun.com/pypi/simple/
ln -s $PYTHON_HOME/bin/virtualenv /usr/bin/virtualenv
```

# 常用包安装
```shell
pip3 install --upgrade setuptools pip -i https://mirrors.aliyun.com/pypi/simple/
pip3 install matplotlib numpy scipy pandas scikit-learn python-dateutil
```

# 设置全局加速
```shell
# 执行了 upgrade setuptools pip 之后，下面命令才能使用
pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/
```

或者直接修改配置文件 ： ~/.config/pip/pip.conf
```
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
```

---

[首 页](https://patrickj-fd.github.io/index)
