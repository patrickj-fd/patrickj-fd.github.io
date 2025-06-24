[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 构建python的基础镜像

**不需要用了，直接修改gpu的构建脚本中的FROM即可**

基于ubuntu 18.04，构建的python 3.6版

```shell
IMAGE_NAME=py-base
IMAGE_TAG=3.6

Dockerfile_Name=Dockerfile.$IMAGE_NAME.$IMAGE_TAG

# ---------------- Dockerfile START ----------------
cat > $Dockerfile_Name <<EOF
FROM ubuntu:18.04

# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:\$PATH

# http://bugs.python.org/issue19846
ENV LANG C.UTF-8

# ENV LD_LIBRARY_PATH /usr/local/nvidia/lib64

# 如果使用https，那么，下面的apt-get要加上： -o Acquire::https::mirrors.tuna.tsinghua.edu.cn::Verify-Peer=false
RUN    echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse' > /etc/apt/sources.list \
    && echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse' >> /etc/apt/sources.list \
    && echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse' >> /etc/apt/sources.list \
    && echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse' >> /etc/apt/sources.list

# extra dependencies (over what buildpack-deps already includes)
RUN apt-get update && apt-get install -y --no-install-recommends \
            python3.6 python3-pip python3-setuptools \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# RUN pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir numpy keras==2.3.1 pandas
# RUN pip3 install --no-cache-dir git+https://www.github.com/bojone/bert4keras.git

RUN mkdir /opt/hrscode

EOF
# ---------------- Dockerfile END  ----------------

docker build -f $Dockerfile_Name -t $IMAGE_NAME:$IMAGE_TAG .
docker image ls

echo 
echo "--------------------------------------"
echo "New image is : ( $IMAGE_NAME:$IMAGE_TAG )"
echo "--------------------------------------"
echo 
```
**【错误】**：Temporary failure resolving 'mirrors.myhuaweicloud.com'
**【解决】**：重启 docker 即可。 systemctl restart docker 

---

[首 页](https://patrickj-fd.github.io/index)
