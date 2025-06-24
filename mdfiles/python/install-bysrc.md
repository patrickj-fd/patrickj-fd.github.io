[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 卸载
## 慎重！！！ 这会把很多系统级的依赖库都卸载掉!
apt-get remove python3
apt-get remove --auto-remove python3
# apt-get purge --auto-remove python3

# 编译安装
## Ubuntu(Debian)
```shell
PYTHON_VERSION=3.7.8
PythonHome=/opt/Python-${PYTHON_VERSION}

wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz"

apt install -y --no-install-recommends \
   autoconf automake bzip2 dpkg-dev file g++ gcc imagemagick libbz2-dev libc6-dev \
   libcurl4-openssl-dev libdb-dev libevent-dev libffi-dev libgdbm-dev libglib2.0-dev libgmp-dev \
   libjpeg-dev libkrb5-dev liblzma-dev libmagickcore-dev libmagickwand-dev libmaxminddb-dev \
   libncurses5-dev libncursesw5-dev libpng-dev libpq-dev libreadline-dev libsqlite3-dev \
   libssl-dev libtool libwebp-dev libxml2-dev libxslt-dev libyaml-dev \
   make patch unzip xz-utils zlib1g-dev tk-dev uuid-dev git

mkdir -p /tmp/src/python
tar -xJC /tmp/src/python --strip-components=1 -f python.tar.xz
cd /tmp/src/python

gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"
./configure --prefix="${PythonHome}" --build="$gnuArch" --enable-loadable-sqlite-extensions \
   --enable-optimizations --enable-option-checking=fatal \
   --enable-shared --with-system-expat --with-system-ffi
[ $? -ne 0 ] && echo "configure ... Failed !" || echo "configure done!"

make -j "$(nproc)" PROFILE_TASK='-m test.regrtest --pgo \
   test_array test_base64 test_binascii test_binhex test_binop test_bytes test_class \
   test_c_locale_coercion test_cmath test_codecs test_compile test_complex test_csv \
   test_decimal test_dict test_float test_fstring test_hashlib test_io test_iter \
   test_json test_long test_math test_memoryview test_pickle test_re test_set test_slice \
   test_struct test_threading test_time test_traceback test_unicode'
[ $? -ne 0 ] && echo "make ... Failed !" || echo "make done!"

make install || echo "make install ... Failed !"

# goto root user
su
PYTHON_VERSION=3.7.8
PythonHome=/opt/Python-${PYTHON_VERSION} && echo ${PythonHome}
echo "${PythonHome}/lib" > /etc/ld.so.conf.d/python${PYTHON_VERSION}.conf
ldconfig
exit


ldd ${PythonHome}/bin/python3  # check lib(so)

# delete all test files
find $PythonHome -depth \
   \( \
  \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
  -o \
  \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
   \) -exec rm -rf '{}' +

cd ~ && rm -rf /tmp/src/python
# check
${PythonHome}/bin/python3 --version
${PythonHome}/bin/pip3 --version
ln -s ${PythonHome}/bin/python3 /usr/bin/python${PYTHON_VERSION}
ls -l /usr/bin/python*

#ln -s idle3 idle
#ln -s pydoc3 pydoc
#ln -s python3 python
#ln -s python3-config python-config

# 因为系统有python，所以，这种源码方式安装的python，使用时，一定要先创建虚拟环境，并且虚拟环境中工作！
${PythonHome}/bin/python3 -m venv 虚拟环境目录

```

## CentOS
```shell
# 下载
wget -c https://www.python.org/ftp/python/3.6.9/Python-3.6.9.tgz

# 安装必要的软件
yum install -y zlib zlib-devel openssl openssl-devel openssl-static \
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

# 最好加上： --enable-optimizations --with-system-expat --with-system-ffi
# 一定加上： --enable-shared
# 官方debain系docker中的编译参数：
gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"
./configure --prefix=$PYTHON_HOME --build="$gnuArch" \
    --enable-loadable-sqlite-extensions --enable-optimizations \
    --enable-option-checking=fatal --enable-shared --with-ssl \
    --with-system-expat --with-system-ffi --without-ensurepip

make -j 8 PROFILE_TASK='-m test.regrtest --pgo \
    test_array test_base64 test_binascii test_binhex test_binop test_bytes \
    test_c_locale_coercion test_class test_cmath test_codecs test_compile \
    test_complex test_csv test_decimal test_dict test_float test_fstring \
    test_hashlib test_io test_iter test_json test_long test_math test_memoryview \
    test_pickle test_re test_set test_slice test_struct test_threading test_time \
    test_traceback test_unicode'
make install

# 配置动态链接库（如果configure时，什么参数都没加，可以跳过本步骤）
# 加上那些操作后，不配置动态链接库的位置，运行python3会报错：error while loading shared libraries libpython3.6m.so.1.0
echo "$PYTHON_HOME/lib" > /etc/ld.so.conf.d/python3.6.conf
ldconfig
# 查看libpython3.6m.so.1.0 等动态库是否被成功指向echo中的lib目录下的对应文件
ldd $PYTHON_HOME/bin/python3
# 以上方式也可以通过设置export LD_LIBRARY_PATH=$PYTHON_HOME/lib来完成，但使用LD_LIBRARY_PATH是个临时方案，不推荐


# 配置软连接
rm /usr/bin/python3
ln -s $PYTHON_HOME/bin/python3 /usr/bin/python3
rm /usr/bin/pip3
ln -s $PYTHON_HOME/bin/pip3 /usr/bin/pip3
rm /usr/bin/python3-config
ln -s $PYTHON_HOME/bin/python3-config /usr/bin/python3-config
rm /usr/bin/python3m
ln -s $PYTHON_HOME/bin/python3.7m /usr/bin/python3m
python3 -V
pip3 -V

# 如果没有pip3，安装它：
python3 -m ensurepip

# 升级pip
python3 -m pip install -U pip
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
pip3 install --upgrade setuptools pip -i https://pypi.mirrors.ustc.edu.cn/simple/
pip3 install matplotlib numpy scipy pandas scikit-learn python-dateutil
```

# 设置全局加速
```shell
# 执行了 upgrade setuptools pip 之后，下面命令才能使用
pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/
```

或者直接修改配置文件 ： ~/.pip/pip.conf
```
[global]
trusted-host = pypi.mirrors.ustc.edu.cn
index-url = https://pypi.mirrors.ustc.edu.cn/simple/
```

---

[首 页](https://patrickj-fd.github.io/index)
