[首 页](https://patrickj-fd.github.io/index)

---

# 一、配置环境
## 1. Java
```shell
wget -c https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u191-b12/OpenJDK8U-jdk_aarch64_linux_hotspot_8u191b12.tar.gz
tar to /usr/java/jdk8u191-b12
ln -s /usr/java/jdk8u191-b12 /usr/java/default
sudo echo "export JAVA_HOME=/usr/java/default" >> /etc/profile
sudo echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
source /etc/profile
java -version
```

## 2. Maven
```shell
wget -c https://archive.apache.org/dist/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz
tar to /opt/apache-maven-3.5.4
sudo echo "export MAVEN_HOME=/opt/apache-maven-3.5.4" >> /etc/profile
sudo echo "export PATH=\$PATH:\$MAVEN_HOME/bin" >> /etc/profile
source /etc/profile
mvn -v
```
- 修改仓库配置：apache-maven-3.5.4/conf/settings.xml
  * <localRepository>/path/to/local/repo</localRepository>

## 3. cmake
```shell
wget -c https://cmake.org/files/v3.14/cmake-3.14.7.tar.gz
tar -zxf cmake-3.12.4.tar.gz
cd cmake-3.12.4
sudo ./bootstrap
sudo make -j4
sudo make install
cmake --version
```

## 4. protobuf
```shell
# 下载针对 Arm64 架构的源码补丁
wget https://mirrors.huaweicloud.com/kunpeng/archive/kunpeng_solution/bigdata/Patch/protoc.zip
# 下载源码。必须用这个版本！
wget -c https://github.com/protocolbuffers/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz
tar -zxf protobuf-2.5.0.tar.gz
mv protobuf-2.5.0 /opt/protobuf-2.5.0
cd /opt/protobuf-2.5.0
cp "protoc.zip解压路径"/protoc.patch ./src/google/protobuf/stubs/
patch -p1 < protoc.patch
cd -
sudo apt-get install autoconf automake libtool curl make g++ unzip libffi-dev
sudo ./autogen.sh
# 可以--prefix=自定义的目录，后面libprotobuf.conf要使用这个目录。 CFLAGS是针对 Arm 平台才需要的参数
sudo ./configure CFLAGS='-fsigned-char'
sudo make -j4
# make check
sudo make install
echo "/usr/local/lib" > /etc/ld.so.conf.d/libprotobuf.conf
ldconfig
protoc --version
```
## 5. snappy(可选)
```shell
wget -c https://github.com/google/snappy/archive/1.1.8.tar.gz
# 解压进入
cd snappy-1.1.8
mkdir build
cd build
sudo cmake ../
sudo make install

# 开启动态链接库编译，将该选项从“OFF”改为“ON”
cd ..
vim CMakeLists.txt
修改：option(BUILD_SHARED_LIBS "Build shared libraries(DLLs)." ON)
```

# 二、编译Hadoop
## 编译
```shell
wget https://archive.apache.org/dist/hadoop/common/hadoop-3.1.3/hadoop-3.1.3-src.tar.gz
tar -zxf hadoop-3.1.1-src.tar.gz
cd hadoop-3.1.3-src
mvn package -DskipTests -Pdist,native -Dtar -Dmaven.javadoc.skip=true

# （可选）添加snappy库编译命令
# 找到snappy位置，一般在：/usr/local/lib64 或 /usr/local/lib
mvn package -DskipTests -Pdist,native -Dtar -Dsnappy.lib=/usr/local/lib -Dbundle.snappy -Dmaven.javadoc.skip=true
```

## 安装验证
- [单节点安装](https://hadoop.apache.org/docs/r3.1.3/hadoop-project-dist/hadoop-common/SingleCluster.html)
- [集群安装](https://hadoop.apache.org/docs/r3.1.3/hadoop-project-dist/hadoop-common/ClusterSetup.html)

使用hadoop自带测试程序计算PI值:
```shell
./hadoop-3.1.3/bin/yarn jar hadoop-3.1.3/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.1.3.jar pi 5 10
```

# 三、编译Hive

# 四、编译Spark

---

[首 页](https://patrickj-fd.github.io)
