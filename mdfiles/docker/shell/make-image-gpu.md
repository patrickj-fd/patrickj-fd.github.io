[首 页](https://patrickj-fd.github.io/index)

---

# 构建 Nvidia 基础镜像
所有需要gpu环境的python docker的基础镜像。
```
#!/bin/bash

set -e

# 【设置 .dockerignore】
cat > .dockerignore << EOF

# *表示将当前所有的目录下的文件都作为构建上下文的例外文件
*

EOF

# 【构建镜像】

IMAGE_NAME="nvidia-gpu"
IMAGE_TAG="cuda10.0-cudnn7-ubuntu18.04-py3.6"

DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
# ----------------- Dockerfile Start -----------------
cat >$DFILE_NAME <<EOF
FROM nvidia/cuda:10.0-cudnn7-runtime-ubuntu18.04

ENV  TZ=Asia/Shanghai DEBIAN_FRONTEND=noninteractive

RUN  set -ex && \
     echo "deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse" > /etc/apt/sources.list && \
     echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
     apt-get update && \
     mkdir ~/.pip/ && \
     apt-get install -y --no-install-recommends python3.6 python3-pip python3-setuptools tzdata && \
     echo "[global]" > ~/.pip/pip.conf && \
     echo "index-url = https://mirrors.aliyun.com/pypi/simple/" >> ~/.pip/pip.conf && \
     pip3 install --upgrade setuptools pip && \
     ln -sf /usr/share/zoneinfo/\$TZ /etc/localtime && echo \$TZ > /etc/timezone && \
     dpkg-reconfigure -f noninteractive tzdata

RUN  set -ex \
     && apt-get install -yq --no-install-recommends openssh-server locales xz-utils vim wget bzip2 unzip curl git ffmpeg \
     && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
     && mkdir /run/sshd

ENV LANG=en_US.utf8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8

RUN  pip3 install matplotlib numpy scipy pandas scikit-learn texttable python-dateutil

CMD  ["/usr/sbin/sshd", "-D"]

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

# 构建 pytorch jupyter 镜像
注意对 '\\$' 的用法。因为是在shell脚本中书写的Dockerfile。
```
#!/bin/bash

set -e

VERSION=$1
if [ "x$VERSION" == "x" ]; then
  echo
  echo "Must input pytorch version !"
  echo
  exit 1
fi

# 【设置 .dockerignore】
cat > .dockerignore << EOF
*

!soft/node-v12.16.1-linux-x64.tar.xz
# 所有需要本地上传的wheels文件放到这个目录下
!soft/whl-tor

EOF

# 把wheels文件保存过去
if [ ! -f soft/whl-tor/torch-1.4.0-cp36-cp36m-manylinux1_x86_64.whl ]; then
    cp /data1/python/pkgs/wheels/torch-1.4.0-cp36-cp36m-manylinux1_x86_64.whl soft/whl-tor/
fi
if [ ! -f soft/whl-tor/torchvision-0.5.0-cp36-cp36m-manylinux1_x86_64.whl ]; then
    cp /data1/python/pkgs/wheels/torchvision-0.5.0-cp36-cp36m-manylinux1_x86_64.whl soft/whl-tor/
fi

# 【构建镜像】

IMAGE_NAME="pytorch-gpu"
IMAGE_TAG="$VERSION-jupyter"

DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
# -------------------------------- Dockerfile Start --------------------------------------
cat >$DFILE_NAME <<EOF
FROM nvidia-gpu:cuda10.0-cudnn7-ubuntu18.04-py3.6

ARG  WORKDIR_VAL=/jpbook

# ========== install jupyter ==========
ENV PATH=\$PATH:/opt/node-v12.16.1-linux-x64/bin
WORKDIR \$WORKDIR_VAL
ADD  soft/node-v12.16.1-linux-x64.tar.xz /opt/
RUN  set -ex \
     && pip3 install jupyterlab \
     && jupyter labextension install @jupyterlab/toc \
     && echo "nohup jupyter lab --notebook-dir=\$WORKDIR_VAL --ip 0.0.0.0 --no-browser --allow-root > /var/log/jupyterlab.log 2>&1 &" > /bin/start-jupyterlab.sh \
     && echo "echo " >> /bin/start-jupyterlab.sh \
     && echo "echo 'Waitting log : /var/log/jupyterlab.log ... ...'" >> /bin/start-jupyterlab.sh \
     && echo "tail -f /var/log/jupyterlab.log" >> /bin/start-jupyterlab.sh \
     && chmod a+x /bin/start-jupyterlab.sh
# jupyter port
EXPOSE 8888

# ========== install pytorch and others ==========
COPY soft/whl-tor/ /tmp/
RUN  set -ex \
     && pip3 install /tmp/*.whl jieba gensim transformers \
     && rm -rf /tmp/*.whl


CMD  ["/usr/sbin/sshd", "-D"]
#CMD  ["python3", "-m", "http.server"]
#CMD ["bash", "-c", "jupyter lab --notebook-dir=/jpbook --ip 0.0.0.0 --no-browser --allow-root"]

EOF
# -------------------------------- Dockerfile End  -------------------------------------

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
