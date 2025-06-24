[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 二进制预编译包安装
## x86
```shell
sudo mkdir /usr/java
sudo cp jdk-8u181-linux-x64.tar.gz /usr/java
cd /usr/java
sudo tar zxf jdk-8u181-linux-x64.tar.gz
ls -l
sudo ln -s /usr/java/jdk1.8.0_181 /usr/java/default
ls -l

cd -
sudo echo "export JAVA_HOME=/usr/java/default" >> /etc/profile
sudo echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile

source /etc/profile
java -version
```

## arm
```shell
wget -c https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u191-b12/OpenJDK8U-jdk_aarch64_linux_hotspot_8u191b12.tar.gz

sudo mkdir /usr/java
sudo cp OpenJDK8U-jdk_aarch64_linux_hotspot_8u191b12.tar.gz /usr/java
cd /usr/java
sudo tar zxf OpenJDK8U-jdk_aarch64_linux_hotspot_8u191b12.tar.gz
ls -l
sudo ln -s /usr/java/jdk8u191-b12 /usr/java/default
ls -l

cd -
sudo echo "export JAVA_HOME=/usr/java/default" >> /etc/profile
sudo echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile

source /etc/profile
java -version
```

# 源码编译方式
参考：
> https://zhuanlan.zhihu.com/p/115258931
> http://hg.openjdk.java.net/jdk8u/jdk8u/raw-file/tip/README-builds.html

## 下载源文件
```shell
sudo apt install mercurial
hg clone http://hg.openjdk.java.net/aarch64-port/jdk8u/

sudo apt install libx11-dev libxext-dev libxrender-dev libxtst-dev libxt-dev libcups2-dev libasound2-dev

cd jdk8u
sh get_source.sh
# 很慢，最好凌晨执行
# 中间可以出现类似下面的错误：
# WARNING: jaxws exited abnormally (255)
# WARNING: jdk exited abnormally (255)
# WARNING: corba exited abnormally (255)
# 删除这个组件目录，再执行get_source，会继续下载没成功的组件
# 如果卡住长时间不见动静，看一下带宽占用，如果也没有，那么新窗口执行：
ps aux|grep clone
# 把python的clone进程杀掉，则get_source那边就会出现失败
# 把失败的这几个的目录删掉，再执行get_source
# 如果实在慢的不行，直接用控制台上打印的clone的地址去自己下zip包，再来解压缩
```

## 编译
```shell
export PATH=/home/jdk/jdk1.7.0_80/bin:$PATH
java -version
./configure --with-target-bits=64
make all  # 中途出现无数warning
```

漫长等待后编译结束。images下面就是打好的包
- j2sdk-image：JDK
- j2re-image：JRE

进入java -version 查看版本。  
拷贝走就可以用了

---

[首 页](https://patrickj-fd.github.io)
