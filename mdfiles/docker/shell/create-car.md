[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

以使用 pytorch jupyter GPU 镜像为例，创建容器：

```shell
#!/bin/bash

# 容器对应的宿主机上的根目录，所有ipynb等程序文件被保存在这下面
APP_ROOT=/data1/python/app/jupyter/TestOnPytorch

PROJECT_NAME=$1
if [ "x$PROJECT_NAME" == "x" ]; then
  echo 
  echo "============================================================="
  echo "[ERROR] Missing project name !"
  echo "1. Choice exist dirname below :"
  ValueList=$(ls $APP_ROOT)
  value_arr=($ValueList)
  for val in ${value_arr[@]}; do
    if [ -d $APP_ROOT/$val ]; then
      echo -ne "\033[34m${val}\033[0m "
    else
      echo -n "${val} "
    fi
  done
  echo 
  echo "2. OR input new name, It will be created in $APP_ROOT"
  echo
  echo 
  exit -1
fi

HTTP_PORT=39013
if [ "x$2" != "x" ]; then
  HTTP_PORT=$2
fi

BINDIR=$(cd $(dirname $0); pwd)

PROJECT_DIR=$APP_ROOT/$PROJECT_NAME
echo "====>  PROJECT_DIR=$PROJECT_DIR"
if [ ! -d "$PROJECT_DIR" ]; then
  mkdir -p $PROJECT_DIR
fi

# check or create data volume
DVName="DataVolume-AI"
DVID=$(docker container ls -a --filter name=$DVName | grep "$DVName" | awk '{print $1 }')
if [ "x$DVID" == "x" ]; then
  echo
  echo "Must create DataVolume, like : docker container run -v /data1/dataset:/RawDataset:ro --name $DVName ubuntu:18.04 /bin/bash"
  echo
  exit -2
fi

# --privileged=true
CAR_NAME="jp-tor-gpu.$PROJECT_NAME"
docker container run --gpus all -d -p $HTTP_PORT:8888 --name $CAR_NAME \
  -v $PROJECT_DIR:/jpbook \
  --volumes-from $DVName \
  pytorch-gpu:1.4-jupyter

sleep 1

CAR=$(docker container ls | grep $HTTP_PORT | grep $CAR_NAME)
if [ "x$CAR" == "x" ]; then
  echo "container <$CAR_NAME> starting failed !"
  exit 1
fi

echo
echo "====> Jupyter container <$CAR_NAME> create success, HTTP Port is : $HTTP_PORT"
echo "====> And now you're inside this container !"
echo "====> You can start jupyterlab by running [ start-jupterlab.sh ]"
echo
docker container exec -it $CAR_NAME bash

```

---

[首 页](https://patrickj-fd.github.io/index)

