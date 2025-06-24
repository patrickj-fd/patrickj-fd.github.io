[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 构建基于Jupyter GPU的开发镜像
## pytorch 镜像

```shell
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
RUN  set -ex \\
     && pip3 install jieba gensim transformers \\

COPY ${WHEEL_DIR} /tmp/
RUN  set -ex \\
     && pip3 install /tmp/torch*.whl \\
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

```shell
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
