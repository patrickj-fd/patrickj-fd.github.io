[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 构建 Nvidia 基础镜像

所有需要gpu环境的python docker的基础镜像。

```shell
#!/bin/bash
# ============================================================
# 所有需要gpu环境的python docker的基础镜像
# ============================================================

set -e

# 【设置 .dockerignore】
cat > .dockerignore << EOF
# *表示将当前所有的目录下的文件都作为构建上下文的例外文件
*
EOF


# 【构建镜像】

IMAGE_NAME="python-basic"
IMAGE_TAG="3.6-GPU-cuda10.0-cudnn7"

DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
SOURCES_LIST=$(cat /data1/docker/apps/apt-sources.list)
# ----------------- Dockerfile Start -----------------
cat >$DFILE_NAME <<EOF
#FROM ubuntu:18.04
FROM nvidia/cuda:10.0-cudnn7-runtime-ubuntu18.04

ENV  TZ=Asia/Shanghai DEBIAN_FRONTEND=noninteractive HR_OSLABEL=$IMAGE_NAME:$IMAGE_TAG

RUN  set -ex && \\
$SOURCES_LIST
     apt-get update && \\
     mkdir ~/.pip/ && \\
     apt-get install -y --no-install-recommends python3.6 python3-dev python3-pip python3-setuptools tzdata && \\
     echo "[global]" > ~/.pip/pip.conf && \\
     echo "index-url = https://mirrors.aliyun.com/pypi/simple/" >> ~/.pip/pip.conf && \\
     pip3 install --upgrade setuptools pip && \\
     ln -sf /usr/share/zoneinfo/\$TZ /etc/localtime && echo \$TZ > /etc/timezone && \\
     dpkg-reconfigure -f noninteractive tzdata

RUN  set -ex \\
     && apt-get install -yq --no-install-recommends locales wget bzip2 unzip curl \\
     && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \\
#     && apt-get clean \\
#     && rm -rf /var/lib/apt/lists/* \\
     && mkdir /opt/app

ENV LANG=en_US.utf8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8

RUN  pip3 install --no-cache-dir numpy scipy pandas scikit-learn python-dateutil h5py

EOF
# ----------------- Dockerfile End  -----------------

sudo docker build -f $DFILE_NAME -t $IMAGE_NAME:$IMAGE_TAG .
echo 
echo "====================================================================="
echo 
echo "GPU base image build success : ( $IMAGE_NAME:$IMAGE_TAG )"
echo 
echo "====================================================================="
echo 
```

[SOURCES_LIST](apt-sources-list.md)

---

[首 页](https://patrickj-fd.github.io/index)
