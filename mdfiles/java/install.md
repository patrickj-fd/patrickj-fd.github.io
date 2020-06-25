[首 页](https://patrickj-fd.github.io/index)

---

# x86
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

# arm
## 二进制预编译包安装
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

## 源码编译方式
```shell
sudo apt install mercurial
hg clone http://hg.openjdk.java.net/aarch64-port/jdk8u/

sudo apt install libx11-dev libxext-dev libxrender-dev libxtst-dev libxt-dev libcups2-dev libasound2-dev

cd jdk8u
sh get_source.sh

./configure
make all
```

---

[首 页](https://patrickj-fd.github.io)
