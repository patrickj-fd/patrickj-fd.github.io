[首 页](https://patrickj-fd.github.io/index)

---

# 构建镜像
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

RUN  set -ex && \
$SOURCES_LIST
     apt-get update && \
     apt-get install -y --no-install-recommends tzdata && \
     ln -sf /usr/share/zoneinfo/\$TZ /etc/localtime && echo \$TZ > /etc/timezone && \
     dpkg-reconfigure -f noninteractive tzdata

RUN  set -ex \
     && apt-get install -yq --no-install-recommends locales \
     && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
     \
     && apt-get install -yq --no-install-recommends openssh-server nano \
# install gcc and so on.
#     && apt-get install -yq --no-install-recommends g++ gcc automake autoconf libtool make \
# install python3 and package.
#     && apt-get install -yq --no-install-recommends python3.6 python3-dev python3-pip python3-setuptools \
#     && mkdir ~/.pip && echo "[global]" > ~/.pip/pip.conf \
#     && echo "index-url = https://mirrors.aliyun.com/pypi/simple/" >> ~/.pip/pip.conf \
#     && pip3 install --upgrade setuptools pip \
#     && pip3 install --no-cache-dir numpy scipy pandas scikit-learn python-dateutil h5py \
# clean
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/* \
     \
     && mkdir /run/sshd \
     && echo "root:Hyren188" | chpasswd \
     && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
     \
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