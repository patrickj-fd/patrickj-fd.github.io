
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
whoami  # is hyren
su - hyren

# 项目根目录
PROJECT_ROOT=/hyren/hrsapp
mkdir -p ${PROJECT_ROOT}/bin
mkdir -p ${PROJECT_ROOT}/dist
# 临时目录，可定期清理
TEMP_DIR=/hyren/temp
mkdir -p ${TEMP_DIR}/nongan
# 创建存储预测结果图片的目录
mkdir ${TEMP_DIR}/nongan/pred-result-images

# 取基础 shell 库 feedwork-shell
cd ${PROJECT_ROOT}/dist
git clone http://139.9.126.19:38111/FdcoreHyren/feedwork-shell.git

sudo ln -s ${PROJECT_ROOT}/dist/feedwork-shell/fd_utils.sh /usr/local/bin/fd_utils.sh && ls -l /usr/local/bin/fd*

# =====》【安装应用】- 方式1:解压安装
cd ~
# 获取介质
scp fd@172.168.0.216:/data1/project-repos/nongan/ProductHostBackup/dist-c.* .
# OR:
curl -s -O ftp://ftp:@172.168.0.100/nano/dist-c.tar.gz
curl -s -O ftp://ftp:@172.168.0.100/nano/dist-c.tar.gz.sha256

# 验证介质并解压，即完成安装了
sha256sum -c dist-c.tar.gz.sha256  # show : dist-c.tar.gz: OK
tar xf dist-c.tar.gz -C hrsapp/dist/

# =====》【安装应用】- 方式2
# 建立本项目的目录结构
mkdir ${PROJECT_ROOT}/dist/c
mkdir ${PROJECT_ROOT}/dist/c/nongan
mkdir ${PROJECT_ROOT}/dist/c/nongan/weights

# 从nano开发机上获得项目文件：hrdarknet.bin hr-predict.sh prj.names prj.cfg weights
# TODO 改成文件从gogs上取，权重和执行程序从开发机上取
ProjectRes=hyren@172.168.0.172:/hyren/project/nongan  # PROJECT_ROOT=/hyren/hrsapp
scp ${ProjectRes}/prj.* ${ProjectRes}/hr*.bin ${ProjectRes}/hr*.sh ${PROJECT_ROOT}/dist/c/nongan
scp ${ProjectRes}/weights/prj_final.* ${PROJECT_ROOT}/dist/c/nongan/weights/

cd ${PROJECT_ROOT}/dist/c/nongan/weights
sha256sum -c <(grep prj_final.weights prj_final.weights.sha256)
cd ..
# 清理掉不需要的文件
[ -n "${PROJECT_ROOT}" ] && rm -f prj.data || echo "Missing PROJECT_ROOT"
chmod u+x *.sh && ls -l
mv hrdarknet-gdb.bin .hrdarknet-gdb.bin && ls -l
# =====》【安装应用】- 方式2 -- 结束

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
# =====》 使用方式1安装的：
TEST_ROOT=/hyren/hrsapp/dist/c/nongan/test && ls ${TEST_ROOT}/pic

# =====》 使用方式2安装的，做以下操作
[ -n "${PROJECT_ROOT}" ] && TEST_ROOT=${PROJECT_ROOT}/dist/c/nongan/test || echo "Missing PROJECT_ROOT"
mkdir -p ${TEST_ROOT}/pic && ls ${TEST_ROOT}
# 获取测试用的采摘图片
#scp root@172.168.0.100:/data1/HyrenEdge/nano/app-test-pic/pic/* ${TEST_ROOT}/pic  # 5t6y0524A!
scp ${ProjectRes}/test/pic/* ${TEST_ROOT}/pic
ls ${TEST_ROOT}/pic
# =====》 使用方式2安装 - 结束

# 启动
cd /hyren/hrsapp/dist/c/nongan && ls -l
./hrdarknet.bin -version  # show : v21.029.101724
sudo ./hr-predict.sh -s -p ${TEST_ROOT}/pic

# 开始测试
curl http://localhost:38010/behavior_detect -X POST -d 'imgfile=no-1.jpg&upid=100&force_save_result=1'
curl http://localhost:38010/behavior_detect -X POST -d imgfile=no-2.jpg
curl http://localhost:38010/behavior_detect -X POST -d imgfile=no-3.jpg
curl http://localhost:38010/behavior_detect -X POST -d imgfile=no-4.jpg
curl http://localhost:38010/behavior_detect -X POST -d imgfile=no-5.jpg
curl http://localhost:38010/behavior_detect -X POST -d imgfile=no-6.jpg
curl http://localhost:38010/behavior_detect -X POST -d 'imgfile=you-1.jpg&upid=100&force_save_result=1'
curl http://localhost:38010/behavior_detect -X POST -d imgfile=you-2.jpg

# 使用网络图片做预测（这种方式不需要-s -p参数，可以无参启动： sudo ./hr-predict.sh）
curl http://localhost:38010/behavior_detect -X POST -d 'imgfile=http://139.9.126.19:39080/nongan/validpic/2787a56824e199f315d88c444294d4c3.jpg'
curl http://localhost:38010/behavior_detect -X POST -d 'imgfile=http://139.9.126.19:39080/nongan/validpic/6654baf19df9498d985c274f63ba7efe.jpg'

curl http://localhost:38010/behavior_detect -X POST -d 'imgfile=http://139.9.126.19:39080/nongan/test/cai-000035.jpg'  # class: caizhai
curl http://localhost:38010/behavior_detect -X POST -d 'imgfile=http://139.9.126.19:39080/nongan/test/cai-null-000245.jpg'  # class: people
curl http://localhost:38010/behavior_detect -X POST -d 'imgfile=http://139.9.126.19:39080/nongan/test/nong-000075.jpg'  # class: nongyao
curl http://localhost:38010/behavior_detect -X POST -d 'imgfile=http://139.9.126.19:39080/nongan/test/null-20211103104402.jpg'  # class: people

curl http://localhost:38010/behavior_detect -X POST -d 'imgfile=http://139.9.126.19:39080/nongan/test/cai-1.jpg'

# 通过浏览器看到预测结果图片：
cd ${TEST_ROOT}/pic
python3 -m http.server 49926 &
# 之后即可访问：
http://172.168.0.xxx:49926
```

## 3. 把项目配置成开机启动

### 启动服务的工具脚本
```shell
cd ~
echo PROJECT_ROOT=${PROJECT_ROOT}  # should be : PROJECT_ROOT=/hyren/hrsapp

touch ${PROJECT_ROOT}/bin/zhna-ai.sh
chmod u+x ${PROJECT_ROOT}/bin/zhna-ai.sh && ls -l ${PROJECT_ROOT}/bin

vi ${PROJECT_ROOT}/bin/zhna-ai.sh
```

#### [ zhna-ai.sh ]
拷贝以下内容进 zhna-ai.sh:
```shell
#!/bin/bash
set -e

BINDIR=/hyren/hrsapp/bin
echo BINDIR=$BINDIR
echo PATH=$PATH

APP_SYSTEMOUT_LOGFILE=${BINDIR}/zhna-ai-systemout.log

echo Start At : $(date)
echo LogFile=$APP_SYSTEMOUT_LOGFILE
echo "" >> $APP_SYSTEMOUT_LOGFILE
echo "========== $(date) ==========" >> $APP_SYSTEMOUT_LOGFILE
sudo /hyren/hrsapp/dist/c/nongan/hr-predict.sh -p /hyren/temp/nongan/pred-result-images >> $APP_SYSTEMOUT_LOGFILE 2>&1
# Or setting log level :
# sudo /hyren/hrsapp/dist/c/nongan/hr-predict.sh -D 0 -p /hyren/temp/nongan/pred-result-images >> $APP_SYSTEMOUT_LOGFILE 2>&1
# sudo systemctl restart hre-appai && sudo systemctl status hre-appai
```

**如果希望保存预测结果的画框图片，需要加上参数 '-s'，并重启服务**

**注意**
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
grep "${PROJECT_ROOT}" /etc/systemd/system/hre-appai.service  # see : ExecStart=/hyren/hrsapp/bin/zhna-ai.sh

# 返回 hyren用户
exit

# 启用服务
sudo systemctl start hre-appai && sudo systemctl status hre-appai  # show : BINDIR, PATH, Start At, LogFile, Openjdk version ......
# 启动后，用status看输出。
# 应该把脚本中的各个echo输出出来，包括：BINDIR=/hyren/hrsapp/bin, Start At '当前时间'

# 以上启动成功后，看日志是否正确监听端口了。耐心等待，因为启动很慢
tail -f -n100 /hyren/hrsapp/bin/zhna-ai-systemout.log  # see : http service listen port 38010 and started at : 'current date time'

# 再重启服务一次，看看是否可以正常重启。
sudo systemctl restart hre-appai && sudo systemctl status hre-appai  # if need do this!
tail -f -n100 /hyren/hrsapp/bin/zhna-ai-systemout.log  # see : http service listen port 38010 and started at : 'current date time'

# 验证
curl http://localhost:38010/behavior_detect -X POST \
    -d 'imgfile=http://139.9.126.19:39080/nongan/validpic/2787a56824e199f315d88c444294d4c3.jpg&upid=100'
ls /hyren/temp/nongan/pred-result-images  # nothing in the folder

curl http://localhost:38010/behavior_detect -X POST \
    -d 'imgfile=http://139.9.126.19:39080/nongan/validpic/2787a56824e199f315d88c444294d4c3.jpg&upid=100&force_save_result=1'
curl http://localhost:38010/behavior_detect -X POST \
    -d 'imgfile=http://61.155.158.222:6120/pic?8dd988877-9dob01l*21e842--45ef4ee7c35adi7b2*=8d0i3s1*=idp4*=pd*m4i1t=1e1965576i0s=*0az48a1d4pi-7do=443=4i630&upid=100&force_save_result=1'
ls /hyren/temp/nongan/pred-result-images  # two '.rst.jpg' files in the folder

# 在 pi 上验证
nano1ip=
curl http://${nano1ip}:38010/behavior_detect -X POST \
    -d 'imgfile=http://139.9.126.19:39080/nongan/validpic/2787a56824e199f315d88c444294d4c3.jpg&upid=pi-100'

# 看结果图片
cd /hyren/temp/nongan/pred-result-images
python3 -m http.server 49926
# 之后即可访问：
http://172.168.0.xxx:49926

# 设置为开机启动
sudo systemctl enable hre-appai

# 以下为调试用命令
# sudo systemctl daemon-reload
# 修改脚本后重启服务，并用status看输出，用tail看日志
# sudo systemctl restart hre-appai
# sudo systemctl status hre-appai
# sudo systemctl stop hre-appai
# sudo systemctl disable hre-appai

# 重启：为了验证是否开机启动了
sudo reboot

# 开机后确认是否自动启动成功
ps -ef | grep -v grep | grep hrdarknet.bin
# 查看启动日志，应该看到三行启动时间。第三行就是这次开机自动启动输出的，看时间可知
cat /hyren/hrsapp/bin/zhna-ai-systemout.log | grep "======"
# 监控日志再次验证
tail -f -n100 /hyren/hrsapp/bin/zhna-ai-systemout.log
# 验证服务是否可用
curl http://localhost:38010/behavior_detect -X POST \
    -d 'imgfile=http://139.9.126.19:39080/nongan/validpic/2787a56824e199f315d88c444294d4c3.jpg&upid=100'
# login pi
nano1ip=
curl http://${nano1ip}:38010/behavior_detect -X POST \
    -d 'imgfile=http://139.9.126.19:39080/nongan/validpic/2787a56824e199f315d88c444294d4c3.jpg&upid=100'
```


# 参考内容

## 启动脚本 hr-predict.sh 
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

# 是否需要保存预测结果图片
if [ "${ArgDict["s"]}" == "TRUE" ]; then
    # 如果要保存预测结果图片，那么必须指定存储图片的根目录
    Save_respic="-save_respic"  # is save predict image
    [ -z "${ArgDict["p"]}" ] && die "Missing image dir by arg '-p'"
fi
# 图片根目录
Imgfile_root="${ArgDict["p"]}"
if [ -n "$Imgfile_root" ]; then
    [ ! -d "$Imgfile_root" ] && die "Imgfile_root=$Imgfile_root is not regular dir"
    Imgfile_root="-imgfile_root $Imgfile_root"
fi

Log_level="${ArgDict["D"]}"
# 没给日志级别，默认使用 info
[ -z "${Log_level}" ] && Log_level=2

PRJ_ROOT="/hyren/hrsapp/dist/c/nongan"
[ ! -d "$PRJ_ROOT" ] && die "<$PRJ_ROOT> is not regular path!"

# http port
ARGSTR_PORT="-port 38010"

# =========== 在本机上nohup方式直接启动程序 ============= Start.
# 本脚本应该注册到服务中开机启动，所以，下面这种启动方式仅保留备用
# echo
# LOGFILE=/hyren/temp/nongan/running.log
# [ -f "$LOGFILE" ] && mv $LOGFILE $LOGFILE.$(date "+%H%M%S")  # backup last logfile

# HR_LOGLEVEL=$Log_level HR_LOGOUT_TYPE=2 nohup "$BINDIR/$EXEC" -t pred $ARGSTR_PORT \
#     -namesfile ${PRJ_ROOT}/prj.names \
#     -cfgfile ${PRJ_ROOT}/prj.cfg \
#     -weightsfile ${PRJ_ROOT}/weights/prj_final.weights \
#     -imgfile_root ${Imgfile_root} $Save_respic > $LOGFILE 2>&1 &

# echo "Process info :"
# ps -ef | grep "$EXEC" | grep -v grep
# echo
# echo "See log :"
# echo "tail -f $LOGFILE"
# echo
# =========== 在本机上nohup方式直接启动程序 ============= Start.

HR_LOGLEVEL=$Log_level HR_LOGOUT_TYPE=2 "$BINDIR/$EXEC" -t pred $ARGSTR_PORT \
    -namesfile ${PRJ_ROOT}/prj.names \
    -cfgfile ${PRJ_ROOT}/prj.cfg \
    -weightsfile ${PRJ_ROOT}/weights/prj_final.weights \
    ${Imgfile_root} $Save_respic

```

---

