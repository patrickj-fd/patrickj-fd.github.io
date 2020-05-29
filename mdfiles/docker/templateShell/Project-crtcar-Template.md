[首 页](https://patrickj-fd.github.io/index)

---

```shell
#!/bin/bash

set -e
. func.sh

# ========== 命令行参数处理 ==========
function usage() {
  echo
	echo "Usage:  `basename $0` [Options]"
	echo "Options :"
	echo "    -n <car name>       : 新构建的容器名字。在其所用镜像范围的，必须唯一"
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

echo 
while getopts 'n:m:t:N:' arg_opt; do
  case ${arg_opt} in
    n) CAR_NAME="$OPTARG"
      ;;
    m) IMAGE_NAME="$OPTARG"
      ;;
    t) IMAGE_TAG="$OPTARG"
      ;;
    N) CAR_NETWORK="$OPTARG"
      ;;
    \?) usage
      ;;
    esac
done

# 命令行参数检查
[ "Null$CAR_NAME" == "Null" ] && usage "Missing <car name>"
CAR_NAME="hrs-$CAR_NAME"
[ "Null$IMAGE_NAME" == "Null" ] && usage "Missing <image name>"
[ "Null$IMAGE_TAG" == "Null" ] && usage "Missing <image tag>"
[ "Null$CAR_NETWORK" != "Null" ] && CAR_NETWORK="--net=${CAR_NETWORK}"
# 回显命令行参数值
echo
echo "============================================="
echo_info "car name      : $CAR_NAME"
echo_info "image name    : $IMAGE_NAME"
echo_info "image tag     : $IMAGE_TAG"
echo_info "car network   : $CAR_NETWORK"
echo "============================================="
echo

# ========== 前置检查 ==========
echo
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
    if [ $sleeps -gt 3 ]; then break; fi
    echo -n ".."
    sleep 1
    sleeps=$(expr $sleeps + 1 )
done
echo "."
# 确认容器启动日志
confirm_carlog "$CAR_NAME"

# ========== 检查容器启动状况 ==========
docker container ls | grep $CAR_NAME > /dev/null || die "container <$CAR_NAME>  starting failed !"

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
