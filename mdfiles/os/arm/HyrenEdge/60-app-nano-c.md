
# 在 Nano 上安装 AI 应用

---

# 总体说明

1. 配置frpc（目前AI端不需要给应用配穿透，跳过本步骤）
2. 安装项目
3. 把项目配置成开机启动

# 操作步骤

## 1. 配置frpc

目前AI端不需要给应用配穿透，跳过本步骤


## 2. 安装项目

**使用 hyren 用户工作**

### 2.1 安装

```shell
su - hyren

# 项目根目录
PROJECT_ROOT=/hyren/hrsapp
mkdir -p ${PROJECT_ROOT}/bin
mkdir -p ${PROJECT_ROOT}/dist
# 临时目录，可定期清理
TEMP_DIR=/hyren/temp
mkdir -p ${TEMP_DIR}/nongan

# 取基础 shell 库 feedwork-shell
cd ${PROJECT_ROOT}/dist
git clone http://139.9.126.19:38111/FdcoreHyren/feedwork-shell.git
sudo ln -s feedwork-shell/fd_utils.sh /usr/local/bin/fd_utils.sh

# 建立本项目的目录结构
mkdir ${PROJECT_ROOT}/dist/c
mkdir ${PROJECT_ROOT}/dist/c/nongan
mkdir ${PROJECT_ROOT}/dist/c/nongan/weights
# 创建存储预测结果图片的目录
mkdir ${TEMP_DIR}/nongan/pred-result-images

# 从nano开发机上获得项目文件：hrdarknet.bin hr-predict.sh prj.names prj.cfg weights
# TODO 改成文件从gogs上取，权重和执行程序从开发机上取
ProjectRes=hyren@172.168.0.172:/hyren/project/nongan
scp ${ProjectRes}/prj.* ${ProjectRes}/hr*.bin ${ProjectRes}/hr*.sh ${PROJECT_ROOT}/dist/c/nongan
scp ${ProjectRes}/weights/prj_final.* ${PROJECT_ROOT}/dist/c/nongan/weights/

cd ${PROJECT_ROOT}/dist/c/nongan/weights
sha256sum -c <(grep prj_final.weights prj_final.weights.sha256)
cd ..
# 清理掉不需要的文件
[ -n "${PROJECT_ROOT}" ] && rm -f prj.data || echo "Missing PROJECT_ROOT"
chmod u+x *.sh && ls -l
mv hrdarknet-gdb.bin .hrdarknet-gdb.bin && ls -l
```

- 安装 python 环境

目前不需要python，安装备用
```shell
source ~/pyvenv-tf15  # cp from : /hyren/python/venv/tf-1.15/bin/activate

python3 -m pip install -U git+http://139.9.126.19:38111/FdcoreHyren/feedwork-py.git
python3 -m pip install flask==1.1.2 requests==2.25.0 pillow==8.0.1
# python3 -m pip install matplotlib==3.3.2 h5py==2.10.0

# 退出python虚拟环境
deactivate
```

### 2.2 测试项目
```shell
# 建立测试环境
[ -n "${PROJECT_ROOT}" ] && TEST_ROOT=${PROJECT_ROOT}/dist/c/nongan/test || echo "Missing PROJECT_ROOT"
mkdir -p ${TEST_ROOT}/pic && ls ${TEST_ROOT}

# 获取测试用的采摘图片
#scp root@172.168.0.100:/data1/HyrenEdge/nano/app-test-pic/pic/* ${TEST_ROOT}/pic  # 5t6y0524A!
scp ${ProjectRes}/test/pic/* ${TEST_ROOT}/pic
ls ${TEST_ROOT}/pic

# 启动
cd ${PROJECT_ROOT}/dist/c/nongan && ls
sudo ./hr-predict.sh -s -p ${TEST_ROOT}/pic

# 开始测试
cd ${TEST_ROOT}/pic
curl http://localhost:38010/behavior_detect -X POST -d imgfile=no-1.jpg
curl http://localhost:38010/behavior_detect -X POST -d imgfile=no-2.jpg
curl http://localhost:38010/behavior_detect -X POST -d imgfile=no-3.jpg
curl http://localhost:38010/behavior_detect -X POST -d imgfile=no-4.jpg
curl http://localhost:38010/behavior_detect -X POST -d imgfile=no-5.jpg
curl http://localhost:38010/behavior_detect -X POST -d imgfile=no-6.jpg
curl http://localhost:38010/behavior_detect -X POST -d imgfile=you-1.jpg
curl http://localhost:38010/behavior_detect -X POST -d imgfile=you-2.jpg

# 测试通过后，Ctrl+C 退出即可。
```

- 启动脚本 hr-predict.sh 内容如下

```shell
#!/bin/bash
# 启动 : 
# 保存预测结果图片：    sudo ./hr-predict.sh -s -p /hyren/hrsapp/dist/c/nongan/test/pic
# 不保存预测结果图片：  sudo ./hr-predict.sh
# 如果是预测本机上的图片，必须指定图片所在根目录来启动： sudo ./hr-predict.sh -p /hyren/hrsapp/dist/c/nongan/test/pic

set -e
. /usr/local/bin/fd_utils.sh
BINDIR="$(cd "$(dirname "$0")" && pwd)"
BIN_NAME="$(basename "$0")"

# ========== cmd args ========== Start
# -s            : 开关变量。是否保存画框的预测结果图片
# -p PATH       : 指定图片根目录。
#                 1. 如果是预测本机上的图片，该目录为这些图片所在的根目录。同时也作为预测结果图片的保存目录
#                 2. 如果是预测网络上的图片，该目录用于存储预测结果图片。需要 '-s' 参数
# -D log level  : 0-trace , 1-debug , 2-info
# -A            : 其他各种要传递的参数
# -Q            : 停止正在运行的进程
# -S            : 显示进程信息，即 ps -ef
declare -A ArgDict
while getopts "SQsp:D:A:" arg_opt; do
    # echo "current arg : $arg_opt=$OPTARG"
    [ "$arg_opt" == "?" ] && usage
    if [ "Nll$OPTARG" == "Nll" ]; then
        ArgDict["$arg_opt"]="TRUE"
    else
        ArgDict["$arg_opt"]="$OPTARG"
    fi
done
# echo "all cmd opts : ${!ArgDict[*]}"; exit 1
# 如果输入参数以'-'开头，那么必须用双引号包裹作为 -A 的值来输入！
# 例如：-A "-json_port 39011 -mjpeg_port 39012"
OtherArgs="${ArgDict["A"]}"
# 剩余的所有参数（不能'-'开头！）
#shift $(($OPTIND - 1))
#OtherArgs="${OtherArgs} $@"
# ========== cmd args ========== End

EXEC=hrdarknet.bin
PID=$(ps -ef|grep -v "$BIN_NAME"|grep -w "$EXEC"|grep -v grep|awk '{print $2}')


# ========== 终止进程 ==========
if [ "${ArgDict["Q"]}" == "TRUE" ]; then
    if [ -n "$PID" ]; then
        kill "$PID"
        echo "stop successful"
    else
        echo "$EXEC is not exist, pid=$PID"
    fi
    exit 0
fi

# ========== 显示进程 ==========
if [ "${ArgDict["S"]}" == "TRUE" ]; then
    ps -ef|grep -v "$BIN_NAME"|grep "$EXEC"|grep -v grep
    exit 0
fi

# ========== 启动进程 ==========
[ -n "$PID" ] && die "$EXEC (pid=$PID) exist!"

if [ "${ArgDict["s"]}" == "TRUE" ]; then
    # 如果要保存预测结果图片，那么必须指定存储图片的根目录
    Save_respic="-save_respic"  # is save predict image
    [ -z "${ArgDict["p"]}" ] && die "Missing image dir by arg '-p'"
fi
Imgfile_root="${ArgDict["p"]}"
if [ -n "$Imgfile_root" ]; then
    [ ! -d "$Imgfile_root" ] && die "Imgfile_root=$Imgfile_root is not regular dir"
fi

Log_level="${ArgDict["D"]}"
# 没给日志级别，默认使用 info
[ -z "${Log_level}" ] && Log_level=2

PRJ_ROOT="/hyren/hrsapp/dist/c/nongan"
[ ! -d "$PRJ_ROOT" ] && die "<$PRJ_ROOT> is not regular path!"

# http port
ARGSTR_PORT="-port 38010"

echo

# HR_LOGLEVEL       : 0-trace , 1-debug , 2-info .....
# HR_LOGOUT_TYPE    : 1-有颜色代码； 2-无颜色代码

LOGFILE=/hyren/temp/nongan/running.log
[ -f "$LOGFILE" ] && mv $LOGFILE $LOGFILE.$(date "+%H%M%S")  # backup last logfile

HR_LOGLEVEL=$Log_level HR_LOGOUT_TYPE=2 "$BINDIR/$EXEC" -t pred $ARGSTR_PORT \
    -namesfile ${PRJ_ROOT}/prj.names \
    -cfgfile ${PRJ_ROOT}/prj.cfg \
    -weightsfile ${PRJ_ROOT}/weights/prj_final.weights \
    -imgfile_root ${Imgfile_root} $Save_respic

echo "Process info :"
ps -ef | grep "$EXEC" | grep -v grep
echo
echo "See log :"
echo "tail -f $LOGFILE"
echo

# 本机调试时启动：
# HR_LOGLEVEL=$Log_level  "$BINDIR/$EXEC" -t pred $ARGSTR_PORT \
#     -namesfile ${PRJ_ROOT}/prj.names \
#     -cfgfile ${PRJ_ROOT}/prj.cfg \
#     -weightsfile ${PRJ_ROOT}/weights/prj_final.weights \
#     -imgfile_root ${Imgfile_root} $Save_respic
```

## 3. 把项目配置成开机启动

### 启动服务的工具脚本
```shell
cd ~
echo PROJECT_ROOT=${PROJECT_ROOT}  # should be /hyren/hrsapp

touch ${PROJECT_ROOT}/bin/zhna-ai.sh
chmod u+x ${PROJECT_ROOT}/bin/zhna-ai.sh && ls -l ${PROJECT_ROOT}/bin

vi ${PROJECT_ROOT}/bin/zhna-ai.sh
```

#### [ zhna-ai.sh ]
**除非必要，zhna-ai.sh永远不用直接执行，应该通过systemctl进行启停**
```shell
#!/bin/bash
set -e

BINDIR=/hyren/hrsapp/bin
echo BINDIR=$BINDIR

APP_SYSTEMOUT_LOGFILE=${BINDIR}/zhna-ai-systemout.log

echo Start At : $(date), APP_SYSTEMOUT_LOGFILE=$APP_SYSTEMOUT_LOGFILE
echo "" >> $APP_SYSTEMOUT_LOGFILE
echo "========== $(date) ==========" >> $APP_SYSTEMOUT_LOGFILE
sudo /hyren/hrsapp/dist/c/nongan/hr-predict.sh >> $APP_SYSTEMOUT_LOGFILE 2>&1
```

**再次重申：**
1. 这个脚本仅仅适用开机启动执行。
2. 如果要启停服务，应该使用systemctl命令。
3. 如果日常运行中需要单独启动应用，应以nohup方式启动到后台去！（见下面的命令）
  - 理论上，不存在需要单独启动应用的情况！

### 注册成开机启动
```shell
su -
PROJECT_ROOT=/hyren/hrsapp

cat > /etc/systemd/system/hre-appai.service << EOF
[Unit]
Description=HyrenEdgeAppAI
After=network.target

[Service]
Type=simple
ExecStart=${PROJECT_ROOT}/bin/zhna-ai.sh
User=hyren

[Install]
WantedBy=multi-user.target
EOF
cat /etc/systemd/system/hre-appai.service

# 返回 hyren用户
exit

# 启用服务
sudo systemctl start hre-appai
# 启动后，用status看输出。
# 应该把脚本中的各个echo输出出来，包括：RunType=start, BINDIR=/hyren/hrsapp/bin, PATH..., Start At....
sudo systemctl status hre-appai

# 看看应用的启动日志。
# 耐心等待，因为启动很慢。
tail -f -n100 /hyren/hrsapp/bin/zhna-ai-systemout.log
# 验证
cd ${TEST_ROOT}/pic
curl http://localhost:38010/behavior_detect -X POST -d imgfile=no-1.jpg

# 设置为开机启动
systemctl enable hre-appai

# 以下为调试用命令
# systemctl daemon-reload
# 修改脚本后重启服务，并用status看输出，用tail看日志
# systemctl restart hre-appai
# systemctl status hre-appai
# systemctl stop hre-appai
# systemctl disable hre-appai

# 重启：为了验证是否开机启动了
reboot

# 开机后确认是否自动启动成功
ps -ef|grep hrdarknet.bin

cat /hyren/hrsapp/bin/zhna-ai-systemout.log | grep "="
# 应该看到两行启动时间。第一行是重启前第一次启动服务时输出的，第二行就是这次开机自动启动输出的，看时间可知
```

---

