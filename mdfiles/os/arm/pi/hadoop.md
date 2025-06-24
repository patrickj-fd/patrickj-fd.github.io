[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

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

- 修改仓库配置：conf下settings.xml

```xml
<localRepository>/path/to/local/repo</localRepository>

<!-- 下面要放到 147 行左右的 <mirrors> 标签里面！ -->
<!-- 务必确保 <mirrors> 标签只有一个！ -->
    <mirror>
      <id>huaweimaven</id>
      <mirrorOf>central</mirrorOf>
      <name>huawei maven</name>
      <url>https://mirrors.huaweicloud.com/repository/maven/</url>
    </mirror>

```

## 3. 设置 gcc 和 g++
**仅在Aarch64平台上需要这样设置gcc**

```shell
# 找到 gcc。一般位于/usr/bin/gcc
command -v gcc
## 看看gcc是符号连接还是真实程序，并相应修改下面脚本文件的指向
ls -l /usr/bin/gcc
echo "#! /bin/sh" > gcc-signed-char.sh
echo "/usr/bin/gcc-8 -fsigned-char "$@"" >> gcc-signed-char.sh
chmod +x gcc-signed-char.sh
ln -s /usr/bin/gcc-signed-char.sh /usr/bin/gcc
```
对 g++ 做同样的处理

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
sudo mv protobuf-2.5.0 /opt/protobuf-2.5.0
cd /opt/protobuf-2.5.0
cp "protoc.zip解压路径"/protoc.patch ./src/google/protobuf/stubs/
cd ./src/google/protobuf/stubs/ && patch -p1 < protoc.patch
cd -
sudo apt-get install autoconf automake libtool curl make g++ unzip libffi-dev
sudo ./autogen.sh
# 可以--prefix=自定义的目录，后面libprotobuf.conf要使用这个目录。 CFLAGS是针对 Arm 平台才需要的参数
sudo ./configure CFLAGS='-fsigned-char'
sudo make -j4
# make check
sudo make install
sudo echo "/usr/local/lib" > /etc/ld.so.conf.d/libprotobuf.conf
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

# 二、编译Hadoop 3.1.3
完成（一、环境配置）的 1-5 步
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

# 四、编译Spark 2.4.6
说明：Spark runs on Java 8, Python 2.7+/3.4+ and R 3.1+. For the Scala API, Spark 2.4.6 uses Scala 2.12. You will need to use a compatible Scala version (2.12.x).

完成（一、环境配置）的 1-2 步

## 安装 R(可选) 一般不需要
```shell
wget -c http://cran.rstudio.com/src/base/R-3/R-3.1.1.tar.gz
tar -zxf R-3.1.1.tar.gz && cd R-3.1.1
./configure --prefix=/opt/R-3.1.1 --enable-R-shlib --enable-R-static-lib --with-libpng --with-jpeglib
sudo make all -j4
sudo make install

export R_HOME=/opt/R-3.1.1
```

## 安装 Scala
### (1) 安装 sbt
```shell
# x86不需要安装sbt
wget -c https://piccolo.link/sbt-0.13.18.tgz
tar -zxf sbt-0.13.18.tgz && mv sbt /opt/
# repositories标签定义了sbt编译时使用的maven仓库顺序。内容参考下面的样例
mkdir ~/.sbt
cp repositories ~/.sbt
sudo echo "export SBT_HOME=/opt/sbt" >> /etc/profile
sudo echo "export PATH=\$PATH:\$SBT_HOME/bin" >> /etc/profile
source /etc/profile
```
- repositories内容样例
```ini
[repositories]
local
huawei-maven: http://mirrors.huaweicloud.com/repository/maven/
sbt-releases-repo: http://repo.typesafe.com/typesafe/ivy-releases/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]
sbt-plugins-repo: http://repo.scala-sbt.org/scalasbt/sbt-plugin-releases/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]
```

### (2) 安装 scala
```shell
# x86平台可直接下载下面的二进制包，解压配置HOME即可
# https://downloads.lightbend.com/scala/2.12.11/scala-2.12.11.tgz
cd /opt/
sudo git clone https://github.com/scala/scala.git
cd scala
git checkout v2.11.12
# scala 2.12.11 不需要加下面这句
sed -i "50,50s%)%),\n\ \ \ \ Keys.\`package\`\ := bundle.value%g" project/Osgi.scala
# 这个sed就是把第50行(50,50就是开始行50、结束行50，也即第50行)改成下面两行：
#    ),
#    Keys.`package` := bundle.value
# 实际上，第50行就是一个括号


sudo sbt package
sudo echo "export SCALA_HOME=/opt/scala" >> /etc/profile
sudo echo "export PATH=\$PATH:\$SCALA_HOME/build/pack/bin" >> /etc/profile
source /etc/profile
```

### (-) 编译 Spark
#### 下载源码
```shell
wget -c https://github.com/apache/spark/archive/v2.4.6.tar.gz
tar xf v2.4.6.tar.gz && cd spark-2.4.6
```
#### 修改配置
- 修改根目录的pom.xml文件，把第1个repository和第1个pluginRepository里面的url标签(googleapis)，改成：https://mirrors.huaweicloud.com/repository/maven/
- 修改编译脚本：dev/make-distribution.sh ：

```
1） 第40行左右，给MVN赋值为自己安装的maven（要使用 3.5.4！）。否则用Spark的mvn又得改一遍setting.xml文件
2） 把130行左右开始的4段 MVN help:evaluate 代码注释掉，直接给 VERSION、SCALA_VERSION赋值即可，如下所示：（否则会及其耗时）
--- 手工设置被注释掉的4个变量：
VERSION=2.4.6
SCALA_VERSION=2.12  # 如果用scala版本是2.11.x，那么设置成：2.11
SPARK_HADOOP_VERSION=
SPARK_HIVE=1  # Hive版本1.x
```

- 使用scala 2.12编译spark
```shell
dev/change-scala-version.sh 2.12
```

#### 开始编译

```shell
# 这个环境变量可以不加，因为在 make-distribution.sh 里面已经设置了
# export MAVEN_OPTS="-Xmx2g -XX:ReservedCodeCacheSize=1g"

# 根据需要，后面增加各种参数，比如：-Phive,hive-thriftserver -PHadoop-2.6(hadoop的大版本号) -Dhadoop.version=2.6.0-cdh5.15.1(详细版本号) -Pyarn
# 编译一个仅仅包含hive-thriftserver的版本。如果不加这个，就是编译了一个最小功能版。
dev/make-distribution.sh --tgz --name 2.4.6-aarch64 -Phive-thriftserver
```
- 如果mvn编译执行一半停止了，再更换源，可能会出现卡死在某个jar一致无法下载。这时要进去本地仓库这个jar包所在目录，把.part、.part.lock等文件删掉，或者把这个jar包目录所有文件都删掉，再重新执行

#### 成果及验证
在当前目录下，会编译出来指定名字后缀的 tgz 文件。解压到任意目录即可使用了。
```shell
echo "export SPARK_HOME=/data1/java/spark-2.4.6-bin-2.4.6-aarch64" >> ~/.bashrc
echo "export PATH=\$PATH:\$SPARK_HOME/bin:\$SPARK_HOME/sbin" >> ~/.bashrc
source ~/.bashrc

# 1）运行计算Pi的程序
spark-submit \
--class org.apache.spark.examples.SparkPi \
--executor-memory 1G \
--total-executor-cores 2 \
$SPARK_HOME/examples/jars/spark-examples_2.11-2.4.6.jar \
100
# 应该看到运行结果： Pi is roughly 3.1409291140929114

# 2）编写wordcount程序
mkdir input
echo "hello spark" >> input/1.txt && echo "hello world" >> input/1.txt
echo "hello fd" >> input/2.txt && echo "hrs spark" >> input/2.txt
# 进入shell
spark-shell
scala> sc.textFile("input").flatMap(_.split(" ")).map((_,1)).reduceByKey(_+_).collect
# 得到结果：
res1: Array[(String, Int)] = Array((hrs,1), (world,1), (hello,3), (fd,1), (spark,2))

# 在启动了shell的状态下，可以浏览器访问 http://ip:4040 查看运行结果

# 3）测试hive-thriftserver可用性（如果编译时，没有加 -Phive-thriftserver ，则不需要做这个测试）
start-thriftserver.sh  # 可以加上：--executor-memory --executor-cores 等参数
# http://ip:4040/sqlserver/ 访问WEB界面
beeline
# 连接到 thrift server 。用户密码：hadoop/hadoop。或者直接加上 -n hadoop 连接。
beeline> !connect jdbc:hive2://localhost:10000
# 在本地任意目录下放上几个csv文件，执行创建外部表：
> create external table test (
    say string comment 'some comment',
    word string comment 'info'
)
row format delimited fields terminated by ','
lines terminated by '\n'
stored as textfile location '/data1/java/app/spark/input';
> show tables;
> select * from test;
```

- [验证 standalone 集群模式](http://spark.apache.org/docs/2.4.6/spark-standalone.html)

把编译出来的spark传到每个主机上，解压。

```shell
# 启动 master：在选定为master的主机上执行：
start-master.sh   # 注意：要把/etc/hosts中本主机名对应的ip改成真实ip，不能是127，否则各个slave连接布上。或者，增加启动参数 -h 明确指定一个名字，并配置到各个slave主机的hosts中。
# 启动 slave ：在其它主机上执行：
start-slave.sh spark://master ip or hostname:7077
# 任意一台主机上执行计算Pi的例子
spark-submit \
--master spark://172.168.0.216:7077 \
--class org.apache.spark.examples.SparkPi \
--executor-memory 1G \
--total-executor-cores 2 \
$SPARK_HOME/examples/jars/spark-examples_2.11-2.4.6.jar \
100
# 观察 master/slave每个主机的日志，会看到计算过程日志
```

---

[首 页](https://patrickj-fd.github.io)
