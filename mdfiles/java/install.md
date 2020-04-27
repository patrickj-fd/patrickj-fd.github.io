[首 页](https://patrickj-fd.github.io/index)

---

```shell
sudo mkdir /usr/java
sudo cp jdk-8u181-linux-x64.tar.gz /usr/java
cd /usr/java
sudo tar zxf jdk-8u181-linux-x64.tar.gz
ls -l
sudo ln -s /usr/java/jdk1.8.0_181 /usr/java/default
ls -l

cd -
sudo vi /etc/profile
export JAVA_HOME=/usr/java/default
export PATH=$JAVA_HOME/bin:$PATH

source /etc/profile
java -version
```

---

[首 页](https://patrickj-fd.github.io)
