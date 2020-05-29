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
	echo "    -d <resource dir>   : 构建镜像时的工作目录，也就是ADD/COPY使用的根目录"
	echo "    -n <image name>     : 新构建的镜像名字"
	echo "    -t <image tag>      : 新构建的镜像标签。可空，默认为 1.0"
	echo "    -W <car workdir>    : 容器的WORKDIR。可空，默认为 /opt/hrs_root"
	echo
  if [ "Null$1" != "Null" ]; then
    echo_warn "$1"
    echo
  fi
	exit 1
}

echo 
while getopts 'd:n:t:W:' arg_opt; do
  case ${arg_opt} in
    d) IMAGE_RESDIR="$OPTARG"
      ;;
    n) IMAGE_NAME="$OPTARG"
      ;;
    t) IMAGE_TAG="$OPTARG"
      ;;
    W) CONTAINER_WORKDIR="$OPTARG"
      ;;
    \?) usage
      ;;
    esac
done

# 命令行参数检查
[ -d "$IMAGE_RESDIR" ] || usage "image resource dir <$IMAGE_RESDIR> is not regular dir !"
[ "Null$IMAGE_NAME" == "Null" ] && usage "Missing <image name>"
IMAGE_TAG=${IMAGE_TAG:="1.0"}
CONTAINER_WORKDIR=${CONTAINER_WORKDIR:="/opt/hrs_root"}
# 回显命令行参数值
echo
echo "============================================="
echo_info "resource dir  : $IMAGE_RESDIR"
echo_info "image name    : $IMAGE_NAME"
echo_info "image tag     : $IMAGE_TAG"
echo_info "car workdir   : $CONTAINER_WORKDIR"
echo "============================================="
echo

# ========== 设置构建镜像时的资源环境 ==========
# '*' 行下面，填写所有需要构建进镜像的目录和文件，以半角感叹号起头。例如：
# !start-app.sh
# !service/resources
cat > $IMAGE_RESDIR/.dockerignore << EOF
*
EOF

# ========== 创建 Dockerfile ==========
# 1. 把需要写入镜像的文件/目录，拷贝到资源环境中
# CONTAINER_START_SH="start-app.sh"
# cp -rf $START_SH $IMAGE_RESDIR

# 2. 设置Dockerfile里面需要的各种变量
DBINFO_CONF="service/resources/fdconfig/dbinfo.conf"

# 3. 编写Dockerfile。注意：正确使用反斜线！
#  * 必须设置环境变量：HRS_BUILD_TIME=$BUILD_TIME
#  * 非必要软件，不要安装。如果一定需要编辑器，安装nano（不要装vi）
#  * 基础镜像不允许使用网上自己下载的！
DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
cat > $DFILE_NAME << EOF
FROM swr.cn-east-2.myhuaweicloud.com/hrs/java-basic:openjdk-8-jre-slim

ENV HRS_BUILD_TIME=$BUILD_TIME \\
    ......

ADD  . $CONTAINER_WORKDIR

RUN  set -ex && \\
	 ...... && \\
     echo "Done!"

WORKDIR $CONTAINER_WORKDIR

#EXPOSE 80

CMD ["bash", "$CONTAINER_START_SH"]

EOF
# echo "=====>>>>> debug exit : $DFILE_NAME"; exit 1

sleep 1

# ========== 构建镜像 ==========
docker build -f $DFILE_NAME -t ${IMAGE_NAME}:${IMAGE_TAG} $IMAGE_RESDIR
assert_mkimg "${IMAGE_NAME}" "${IMAGE_TAG}"
```

---

[首 页](https://patrickj-fd.github.io)
