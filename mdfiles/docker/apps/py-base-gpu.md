[首 页](https://patrickj-fd.github.io/index)

---

# 构建 Nvidia 基础镜像

所有需要gpu环境的python docker的基础镜像。

```
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
# ----------------- Dockerfile Start -----------------
cat >$DFILE_NAME <<EOF
FROM nvidia/cuda:10.0-cudnn7-runtime-ubuntu18.04

ENV  TZ=Asia/Shanghai DEBIAN_FRONTEND=noninteractive HR_OSLABEL=$IMAGE_NAME:$IMAGE_TAG

RUN  set -ex && \
     echo "deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse" > /etc/apt/sources.list && \
     echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list && \
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

RUN  set -ex \
     && apt-get install -yq --no-install-recommends locales xz-utils wget bzip2 unzip curl \
     && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
     && apt-get clean \
     && rm -rf /var/lib/apt/lists/* \
     && mkdir /opt/app

ENV LANG=en_US.utf8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8

RUN  pip3 install --no-cache-dir matplotlib numpy scipy pandas scikit-learn python-dateutil

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

# 构建 jupyter 镜像

注意对 '\\$' 的用法。因为是在shell脚本中书写的Dockerfile。

```
#!/bin/bash

set -e

# 【设置 .dockerignore】
cat > .dockerignore << EOF
*
!soft/node-v12.16.1-linux-x64.tar.xz
EOF

# 【构建镜像】
VERSION=2.0.2
IMAGE_NAME="jupyter"
IMAGE_TAG="${VERSION}-python-GPU"

DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
# -------------------------------- Dockerfile Start --------------------------------------
cat >$DFILE_NAME <<EOF
FROM python-basic:3.6-GPU-cuda10.0-cudnn7

ENV  HR_OSLABEL=$IMAGE_NAME:$IMAGE_TAG
ARG  WORKDIR_VAL=/jpbook

# ========== install soft ==========
# gcc python3-dev : for ujson using by jupyter-lsp
RUN  set -ex \
     && apt-get update \
     && apt-get install -yq --no-install-recommends openssh-server net-tools xz-utils vim wget bzip2 unzip curl git \
     && apt-get install -yq --no-install-recommends gcc python3-dev \
     && mkdir /run/sshd

# install node
ADD  soft/node-v12.16.1-linux-x64.tar.xz /opt/
ENV  PATH=\$PATH:/opt/node-v12.16.1-linux-x64/bin

# ========== install jupyter ==========
WORKDIR \$WORKDIR_VAL
# install python-language-server[all] : for jupyter-lsp
RUN  set -ex \
     && pip3 install jupyterlab==${VERSION} jupyter-lsp \
     && jupyter labextension install @jupyter-widgets/jupyterlab-manager @jupyterlab/toc \
                @krassowski/jupyterlab-lsp @krassowski/jupyterlab_go_to_definition \
     && pip3 install python-language-server[all] \
     
     && echo "nohup jupyter lab --notebook-dir=\$WORKDIR_VAL --ip 0.0.0.0 --no-browser --allow-root > /var/log/jupyterlab.log 2>&1 &" > /bin/start-jupyterlab.sh \
     && echo "echo " >> /bin/start-jupyterlab.sh \
     && echo "echo 'Waitting log : /var/log/jupyterlab.log ... ...'" >> /bin/start-jupyterlab.sh \
     && echo "tail -f /var/log/jupyterlab.log" >> /bin/start-jupyterlab.sh \
     && chmod a+x /bin/start-jupyterlab.sh \
     
     && echo "[pycodestyle]" > ~/.config/pycodestyle \
     && echo "ignore = E402, E703, E251, E121, E122" >> ~/.config/pycodestyle \
     && echo "max-line-length = 120" >> ~/.config/pycodestyle \

     && echo "root:hmfms888" | chpasswd \
     && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
# jupyter port
EXPOSE 8888

CMD  ["/usr/sbin/sshd", "-D"]
#CMD  ["python3", "-m", "http.server"]

EOF
# -------------------------------- Dockerfile End  -------------------------------------

sudo docker build -f $DFILE_NAME -t $IMAGE_NAME:$IMAGE_TAG .
echo 
echo "====================================================================="
echo 
echo "jupyter image build success : ( $IMAGE_NAME:$IMAGE_TAG )"
echo 
echo "====================================================================="
echo 
```

# 构建基于jupyter的开发镜像
## pytorch 镜像

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

WHEEL_DIR="soft/whl-tor"
if [ ! -d $WHEEL_DIR ]; then
  mkdir $WHEEL_DIR
fi
# 【设置 .dockerignore】
cat > .dockerignore << EOF
*
# 所有需要本地上传的wheels文件放到这个目录下
!${WHEEL_DIR}
EOF

# 把wheels文件保存过去
WHL_NAME_ARR=("torch-1.4.0-cp36-cp36m-manylinux1_x86_64.whl" "torchvision-0.5.0-cp36-cp36m-manylinux1_x86_64.whl")
for filename in ${WHL_NAME_ARR[@]}; do
  echo -n "wheel : ${WHEEL_DIR}/${filename}"
  if [ ! -f ${WHEEL_DIR}/${filename} ]; then
    cp /data1/python/pkgs/wheels/${filename} ${WHEEL_DIR}/
    echo -n " copy done!"
  fi
  echo " skip."
done

# 【构建镜像】

IMAGE_NAME="pytorch-gpu"
IMAGE_TAG="$VERSION-jupyter"

DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
# -------------------------------- Dockerfile Start --------------------------------------
cat >$DFILE_NAME <<EOF
FROM jupyter:2.0.2-python-GPU

ENV  HR_OSLABEL=$IMAGE_NAME:$IMAGE_TAG
# ========== install pytorch and others ==========
RUN  set -ex \
     && pip3 install jieba gensim transformers \

COPY ${WHEEL_DIR} /tmp/
RUN  set -ex \
     && pip3 install /tmp/torch*.whl \
     && rm -rf /tmp/torch*.whl


CMD  ["/usr/sbin/sshd", "-D"]
#CMD  ["python3", "-m", "http.server"]
#CMD ["bash", "-c", "jupyter lab --notebook-dir=/jpbook --ip 0.0.0.0 --no-browser --allow-root"]

EOF
# -------------------------------- Dockerfile End  -------------------------------------

sudo docker build -f $DFILE_NAME -t $IMAGE_NAME:$IMAGE_TAG .
echo 
echo "====================================================================="
echo 
echo "pytorch image build success : ( $IMAGE_NAME:$IMAGE_TAG )"
echo 
echo "====================================================================="
echo 
```

## tensorflow 镜像

```
#!/bin/bash

set -e

VERSION=$1
if [ "x$VERSION" == "x" ]; then
  echo
  echo "Must input tensorflow version !"
  echo
  exit 1
fi

WHEEL_DIR="soft/whl-tf"
if [ ! -d $WHEEL_DIR ]; then
  mkdir $WHEEL_DIR
fi
# 【设置 .dockerignore】
cat > .dockerignore << EOF
*
# 所有需要本地上传的wheels文件放到这个目录下
!${WHEEL_DIR}
EOF

# 把wheels文件保存过去
WHL_NAME_ARR=("tensorflow-${VERSION}-cp36-cp36m-manylinux1_x86_64.whl" "tensorflow_gpu-${VERSION}-cp36-cp36m-manylinux1_x86_64.whl")
for filename in ${WHL_NAME_ARR[@]}; do
  echo -n "wheel : ${WHEEL_DIR}/${filename}"
  if [ ! -f ${WHEEL_DIR}/${filename} ]; then
    cp /data1/python/pkgs/wheels/${filename} ${WHEEL_DIR}/
    echo -n " copy done!"
  fi
  echo " skip."
done

# 【构建镜像】

IMAGE_NAME="tensorflow-gpu"
IMAGE_TAG="$VERSION-jupyter"

DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
# -------------------------------- Dockerfile Start --------------------------------------
PIP_KERAS="RUN  pip3 install --no-cache-dir keras==2.3.1"
if [[ $VERSION == 2.* ]]; then
  PIP_KERAS=""
fi

cat >$DFILE_NAME <<EOF
FROM jupyter:2.0.2-python-GPU

ENV  HR_OSLABEL=$IMAGE_NAME:$IMAGE_TAG
# ========== install tensorflow and others ==========
$PIP_KERAS

# pip3 install --no-cache-dir
RUN  set -ex \
     && pip3 install jieba gensim bert4keras \

#RUN  pip3 install tensorflow==$VERSION tensorflow-gpu==$VERSION
COPY ${WHEEL_DIR} /tmp/
RUN  set -ex \
     && pip3 install /tmp/tensorflow*.whl \
     && rm -rf /tmp/tensorflow*.whl

CMD  ["/usr/sbin/sshd", "-D"]
#CMD  ["python3", "-m", "http.server"]
#CMD ["bash", "-c", "jupyter lab --notebook-dir=/jpbook --ip 0.0.0.0 --no-browser --allow-root"]

EOF
# -------------------------------- Dockerfile End  -------------------------------------

sudo docker build -f $DFILE_NAME -t $IMAGE_NAME:$IMAGE_TAG .
echo 
echo "====================================================================="
echo 
echo "tensorflow image build success : ( $IMAGE_NAME:$IMAGE_TAG )"
echo 
echo "====================================================================="
echo 
```

---

[首 页](https://patrickj-fd.github.io/index)
