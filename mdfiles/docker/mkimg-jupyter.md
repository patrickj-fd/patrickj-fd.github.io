[首 页](https://patrickj-fd.github.io/index)

---

# 构建jupyter基础镜像
（依赖于python基础镜像）
```
set -e

# 【设置 .dockerignore】
cat > .dockerignore << EOF

# *表示将当前所有的目录下的文件都作为构建上下文的例外文件
*
!files/base/*
# dist/*表示dist目录下的所有文件都是构建上下文所需要使用的文件
# !dist/*

EOF


# 【构建镜像】

IMAGE_NAME="jupyterlab"
IMAGE_TAG="base"

DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
# ------------------------------------------ Dockerfile Start -----------------------------------------------------------
cat >$DFILE_NAME <<EOF
FROM swr.cn-east-2.myhuaweicloud.com/hrs/python-basic:3.6-bionic

ENV  DEBIAN_FRONTEND noninteractive

# RUN apt-get autoremove -y && apt-get remove -y wget
RUN  set -ex \
     && apt-get update && apt-get install -yq --no-install-recommends locales bzip2 unzip curl git ffmpeg \
     && rm -rf /var/lib/apt/lists/* \
	   && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
     && mkdir /jpbook

ENV LANG=en_US.utf8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8

# pip3 -i https://mirrors.aliyun.com/pypi/simple/
# ffmpeg for matplotlib anim : apt-get install -y --no-install-recommends ffmpeg
RUN  set -ex \
     && pip3 install --no-cache-dir jupyterlab matplotlib \
             numpy scipy pandas scikit-learn
#RUN  pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir jupyter_http_over_ws \
#     && jupyter serverextension enable --py jupyter_http_over_ws

COPY files/base/* /jpbook/
WORKDIR /jpbook

CMD ["bash", "-c", "jupyter lab --notebook-dir=/jpbook --ip 0.0.0.0 --no-browser --allow-root"]

EOF
# ------------------------------------------ Dockerfile End  -----------------------------------------------------------

sudo docker build -f $DFILE_NAME -t $IMAGE_NAME:$IMAGE_TAG .
echo 
echo "====================================================================="
echo 
echo "jupyter image build success : ( $IMAGE_NAME:$IMAGE_TAG )"
echo 
echo "====================================================================="
echo 

exit 0

# 【验证】
LOCAL_ROOT=/data1/docker/python/jupyter
mkdir -p $LOCAL_ROOT/app

# 本项目的容器名
CAR_APP_NAME="jupyter-lab"
sudo docker container run -d -p 38888:8888 --name $CAR_APP_NAME \
     -v $LOCAL_ROOT/app:/jpbook \
     $IMAGE_NAME:$IMAGE_TAG

sleep 1
sudo docker container ls | grep $CAR_APP_NAME

# 从启动日志中得到 token
sudo docker logs $CAR_APP_NAME

# 进入容器
sudo docker container exec -it $CAR_APP_NAME bash

# 清理容器
sudo docker container stop $CAR_APP_NAME
sudo docker container rm $CAR_APP_NAME

```

---

[首 页](https://patrickj-fd.github.io/index)