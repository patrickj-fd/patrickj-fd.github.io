[首 页](https://patrickj-fd.github.io/index)

---

# 构建镜像
构建一个基于ubuntu-18.04的初始操作系统环境，仅拥有如下基本功能：
- 中国的时区
- 支持utf8
- nano编辑器
- SSH服务

**这是所有其他镜像的顶级基础镜像**

```shell
#!/bin/bash
set -e
# 【设置 .dockerignore】
cat > .dockerignore << EOF
*
EOF

# 【构建镜像】
IMAGE_NAME="only-os-ssh"
IMAGE_TAG="ubuntu-18.04"

DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
SOURCES_LIST=$(cat /data1/docker/apps/apt-sources.list)
# -------------------------------- Dockerfile Start --------------------------------------
cat >$DFILE_NAME <<EOF
FROM ubuntu:18.04

ENV  TZ=Asia/Shanghai DEBIAN_FRONTEND=noninteractive HR_OSLABEL=$IMAGE_NAME:$IMAGE_TAG

RUN  set -ex && \\
$SOURCES_LIST
     apt-get update && \\

# 安装时区管理软件
     apt-get install -y --no-install-recommends tzdata && \\
     ln -sf /usr/share/zoneinfo/\$TZ /etc/localtime && echo \$TZ > /etc/timezone && \\
     dpkg-reconfigure -f noninteractive tzdata \\

# 安装 locales
     && apt-get install -yq --no-install-recommends locales \\
     && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \\

# 安装 SSH 和 nano
     && apt-get install -yq --no-install-recommends openssh-server nano \\
     && mkdir /run/sshd \\
     && echo "root:Hyren188" | chpasswd \\
     && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \\

# 安装 gcc make 相关软件
#     && apt-get install -yq --no-install-recommends g++ gcc automake autoconf libtool make \\

# 安装 python
#     && apt-get install -yq --no-install-recommends python3.6 python3-dev python3-pip python3-setuptools \\
#     && mkdir ~/.pip && echo "[global]" > ~/.pip/pip.conf \\
#     && echo "index-url = https://mirrors.aliyun.com/pypi/simple/" >> ~/.pip/pip.conf \\
#     && pip3 install --upgrade setuptools pip \\
# 安装 numpy 等默认需要的包
#     && pip3 install --no-cache-dir numpy scipy pandas scikit-learn python-dateutil h5py \\

# 清理 apt
     && apt-get clean \\
     && rm -rf /var/lib/apt/lists/* \\

# 创建默认工作目录
     && mkdir /data

WORKDIR /data

ENV LANG=en_US.utf8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8

CMD  ["/usr/sbin/sshd", "-D"]

EOF
# -------------------------------- Dockerfile End  -------------------------------------

sudo docker build -f $DFILE_NAME -t $IMAGE_NAME:$IMAGE_TAG .
echo 
echo "====================================================================="
echo 
echo "image build success : ( $IMAGE_NAME:$IMAGE_TAG )"
echo "Container check :"
echo "docker container run --rm -it $IMAGE_NAME:$IMAGE_TAG bash"
echo 
echo "====================================================================="
echo 
```

---

[首 页](https://patrickj-fd.github.io/index)