[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

```shell
#!/bin/bash

# set -e
. func_docker.sh

# ========== 命令行参数处理 ==========
function usage() {
    echo
	echo "Usage:  `basename $0` [Options]"
	echo "Options :"
	echo "    -c <car name>       : 新构建的容器名字。在其所用镜像范围的，必须唯一"
	echo "    -m <image name>     : 容器使用的镜像名字"
	echo "    -t <image tag>      : 容器使用的镜像标签"
	echo "    -N <car network>    : 容器归属网络。可空"
	echo
    if [ "Null$1" != "Null" ]; then
        echo_warn "$1"
        echo
    fi
    exit 1
}

while getopts ':c:m:t:N:D' arg_opt; do
  case ${arg_opt} in
    c) CAR_NAME="$OPTARG"     ;;
    m) IMAGE_NAME="$OPTARG"   ;;
    t) IMAGE_TAG="$OPTARG"    ;;
    N) CAR_NETWORK="$OPTARG"  ;;
    D) ARG_debug="true" ;;
    \?) usage ;;
  esac
done
# 获得剩余的命令行参数
shift $((OPTIND-1))
OTHER_VALUES="$@"
# 回显命令行参数值
if [ "$ARG_debug" == "true" ]; then
    echo
    echo "============================================="
    echo_info "car name      : $CAR_NAME"
    echo_info "image name    : $IMAGE_NAME"
    echo_info "image tag     : $IMAGE_TAG"
    echo_info "car network   : $CAR_NETWORK"
    echo "============================================="
    echo
fi
echo
# 参数检查
[ "Null$CAR_NAME" == "Null" ] && usage "Missing <car name>"
CAR_NAME="hrs-$CAR_NAME"
[ "Null$IMAGE_NAME" == "Null" ] && usage "Missing <image name>"
[ "Null$IMAGE_TAG" == "Null" ] && usage "Missing <image tag>"
[ "Null$CAR_NETWORK" != "Null" ] && CAR_NETWORK="--net=${CAR_NETWORK}"

# ========== 前置检查: 该名字的容器是否已经存在 ==========
echo_info "Create hrs container <$CAR_NAME> starting ... ..."
docker container ls | grep "$CAR_NAME" > /dev/null && die "container <$CAR_NAME> is running !"
assert_diedcar "$CAR_NAME"

# ========== 创建容器 ==========
docker container run -d --name $CAR_NAME $CAR_NETWORK \
    -p ...... \
    -v ...... \
    -e ...... \
    $IMAGE_NAME:$IMAGE_TAG

# 等待容器启动完成
sleeps=1
while true; do
    if [ $sleeps -gt 5 ]; then break; fi
    echo -n ".."
    sleep 1
    sleeps=$(expr $sleeps + 1 )
done
echo "."
# 确认容器启动日志
confirm_carlog "$CAR_NAME"

# ========== 检查容器启动状况 ==========
docker container ls | grep $CAR_NAME > /dev/null || die "container <$CAR_NAME>  starting failed ! check logs: docker logs $CAR_NAME"

echo
echo "container <$CAR_NAME>  starting success !"
echo "$(docker inspect $CAR_NAME | grep IPAddress)"
echo 
echo "Tips :"
echo "  1. <enter container  >: docker container exec -it $CAR_NAME_BACKEND bash"
echo "  2. <trace logs       >: docker logs -f $CAR_NAME_BACKEND"
echo

```

---

[首 页](https://patrickj-fd.github.io)
