
启动脚本：`startWeChat.sh`

```shell
#!/bin/bash

BINDIR=/data1/docker/apps/bestwu-wechat
echo "APP ROOT DIR : $BINDIR"
QQ_IMAGE_DIR="/home/fd/.config/tencent-qq/AppData/file"
HOME_DIR="/home/fd"
HOME_DOC_DIR="${HOME_DIR}/Documents"
HOME_IMAGE_DIR="${HOME_DIR}/Pictures"
GITEE_PAN_DIR="/data3/gitee/pan"


CAR_NAME=bestwu-wechat
#
# --privileged: enable sound (/dev/snd/)
# --ipc=host:   enable MIT_SHM (XWindows)
#
docker run -d --name $CAR_NAME --device /dev/snd \
    --ipc=host \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $BINDIR/WeChatFiles:/WeChatFiles \
    -v $QQ_IMAGE_DIR:/QQ-Image \
    -v $HOME_DOC_DIR:/Host-doc \
    -v $HOME_IMAGE_DIR:/Host-image \
    -v $GITEE_PAN_DIR:/Gitee-Pan \
    -e DISPLAY=unix$DISPLAY \
    -e XMODIFIERS=@im=fcitx \
    -e QT_IM_MODULE=fcitx \
    -e GTK_IM_MODULE=fcitx \
    -e AUDIO_GID=`getent group audio | cut -d: -f3` \
    -e GID=`id -g` \
    -e UID=`id -u` \
    bestwu/wechat

sleep 1

docker container ls | grep bestwu-wechat
CAR=$(docker container ls | grep $CAR_NAME)
if [ "x$CAR" == "x" ]; then
  echo "container <$CAR_NAME> starting failed !"
  exit 1
fi

echo 
echo "=====>>>>> bestwu-wechat started successfully ! running logs :"
docker logs $CAR_NAME

```