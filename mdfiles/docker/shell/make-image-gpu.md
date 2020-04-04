[首 页](https://patrickj-fd.github.io/index)

---

以下内容以构建一个 pytorch 镜像为例。
```shell
#!/bin/bash
# ============================================================
# 使用说明：
# 
# ============================================================

set -e

TF_VERSION=$1
if [ "x$TF_VERSION" == "x" ]; then
  echo
  echo "Must input pytorch version !"
  echo
  exit 1
fi

# 【设置 .dockerignore】
cat > .dockerignore << EOF

# *表示将当前所有的目录下的文件都作为构建上下文的例外文件
*

# dist/*表示dist目录下的所有文件都是构建上下文所需要使用的文件
# !dist/*

EOF


# 【构建镜像】

IMAGE_NAME="pytorch-gpu"
IMAGE_TAG="$TF_VERSION-jupyter"

DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
# -------------------------------- Dockerfile Start -------------------------------------------------
cat >$DFILE_NAME <<EOF
FROM nvidia/cuda:10.0-cudnn7-runtime-ubuntu18.04

ENV  TZ=Asia/Shanghai DEBIAN_FRONTEND=noninteractive

RUN  set -ex && \
     echo "deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse" > /etc/apt/sources.list && \
     echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
     apt-get update && \
     mkdir ~/.pip/ && \
     apt-get install -y --no-install-recommends python3.6 python3-pip python3-setuptools tzdata && \
     echo "[global]" > ~/.pip/pip.conf && \
     echo "index-url = https://mirrors.aliyun.com/pypi/simple/" >> ~/.pip/pip.conf && \
     pip3 install --upgrade setuptools pip && \
     ln -sf /usr/share/zoneinfo/\$TZ /etc/localtime && echo \$TZ > /etc/timezone && \
     dpkg-reconfigure -f noninteractive tzdata


# RUN apt-get autoremove -y && apt-get remove -y wget
RUN  set -ex \
     && apt-get install -yq --no-install-recommends openssh-server locales vim wget bzip2 unzip curl git ffmpeg \
     && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
     && mkdir /jpbook

ENV LANG=en_US.utf8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8

# pip3 -i https://mirrors.aliyun.com/pypi/simple/
# ffmpeg for matplotlib anim : apt-get install -y --no-install-recommends ffmpeg
RUN  set -ex \
     && pip3 install --no-cache-dir jupyterlab matplotlib \
             numpy scipy pandas scikit-learn texttable

RUN  pip3 install jieba gensim python-dateutil transformers
RUN  pip3 install torch torchvision
# numpy pyyaml scipy ipython mkl mkl-include ninja cython typing

#RUN  pip3 install --no-cache-dir jupyter_http_over_ws \
#     && jupyter serverextension enable --py jupyter_http_over_ws

WORKDIR /jpbook

EXPOSE 8888

CMD  ["python3", "-m", "http.server"]
#CMD ["bash", "-c", "jupyter lab --notebook-dir=/jpbook --ip 0.0.0.0 --no-browser --allow-root"]

EOF
# ------------------------------------------ Dockerfile End  -----------------------------------------------------------

sudo docker build -f $DFILE_NAME -t $IMAGE_NAME:$IMAGE_TAG .
echo 
echo "====================================================================="
echo 
echo "pytorch-jupyter image build success : ( $IMAGE_NAME:$IMAGE_TAG )"
echo 
echo "====================================================================="
echo 

```

---

[首 页](https://patrickj-fd.github.io/index)
