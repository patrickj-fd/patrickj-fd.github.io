
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

PROJECT_ROOT=/hyren/hrsapp
mkdir -p ${PROJECT_ROOT}/bin ${PROJECT_ROOT}/dist
cd ${PROJECT_ROOT}/dist

git clone http://139.9.126.19:38111/zhihuinongan/python.git

cd ${PROJECT_ROOT}/dist/python/resources/module/nongan
# get model file from 63 root/5t6y0524A!
sftp root@172.168.0.63
> get /data1/project/zhihuinongan/hrsapp/dist/python/resources/module/nongan/last1.h5
> bye

source ~/pyvenv-tf15  # cp from : /hyren/python/venv/tf-1.15/bin/activate

python3 -m pip install -U git+http://139.9.126.19:38111/FdcoreHyren/feedwork-py.git
python3 -m pip install flask==1.1.2 requests==2.25.0 pillow==8.0.1
# python3 -m pip install matplotlib==3.3.2 h5py==2.10.0
```

### 2.2 测试项目
```shell
# 建立测试环境
TEST_ROOT=${PROJECT_ROOT}/test
mkdir ${TEST_ROOT} ${TEST_ROOT}/pic
cd ${TEST_ROOT} && ls

# 从笔记本上传测试图片过来
sftp hyren@172.168.0.nanaip
> cd /hyren/hrsapp/test/pic
> put *.jpg

# 运行测试程序
cd ${PROJECT_ROOT}/dist/python/yolov4-keras

HRS_RESOURCES_ROOT=${PROJECT_ROOT}/dist/python/resources python3 test.py
# input : /hyren/hrsapp/test/pic/*.jpg
# sftp> get *-result.jpg 取出来看结果
```

- test.py中的代码逻辑如下

```python
import os
import sys
import glob
from yolo import YOLO
from PIL import Image

import feedwork.utils.FileHelper as fileu


yolo = YOLO()

while True:
    img_pattern = input("Input image files pattern [ /path/*.jpg ] OR [ quit ] : ")
    if img_pattern == "quit":
        break
    for img_name in glob.iglob(img_dir):
        img_sname = fileu.file_shortname(img_name)
        if img_sname.endswith("-result"):
            continue
        img_path = fileu.file_abspath(img_name)
        img_extname = fileu.file_extname(img_name)
        print(f"\ndeal : {img_path} - {img_sname}{img_extname}")
        # 开始处理
        image = Image.open(img_name)
        img_result = yolo.detect_image(image)
        img_result_fname = f"{img_path}/{img_sname}-result{img_extname}"
        print(f"done : {img_result_fname}")
        img_result.save(img_result_fname)

yolo.close_session()
```

## 3. 把项目配置成开机启动

### 启动服务的工具脚本
```shell
echo PROJECT_ROOT=${PROJECT_ROOT}  # check PROJECT_ROOT should be /hyren/hrsapp

touch ${PROJECT_ROOT}/bin/zhna-ai.sh
chmod u+x ${PROJECT_ROOT}/bin/zhna-ai.sh && ls -l ${PROJECT_ROOT}/bin

vi ${PROJECT_ROOT}/bin/zhna-ai.sh
```
- [ zhna-ai.sh ]
```shell
#!/bin/bash

set -e

RunType="$1"
echo RunType=$RunType

BINDIR=/hyren/hrsapp/bin
echo BINDIR=$BINDIR
echo PATH=$PATH

# [ Func 1 ] : start process
if [ "x$RunType" == "xstart" ]; then
    cd /hyren/hrsapp/dist/python/yolov4-keras > /dev/null

    APP_SYSTEMOUT_LOGFILE=${BINDIR}/zhna-ai-systemout.log

    echo Start At : $(date), APP_SYSTEMOUT_LOGFILE=$APP_SYSTEMOUT_LOGFILE
    echo "" >> $APP_SYSTEMOUT_LOGFILE
    echo "========== $(date) ==========" >> $APP_SYSTEMOUT_LOGFILE

    HRS_RESOURCES_ROOT=/hyren/hrsapp/dist/python/resources /hyren/python/venv/tf-1.15/bin/python3 service.py >> $APP_SYSTEMOUT_LOGFILE 2>&1
fi

# [ Func 2 ] : just show process
if [ "x$RunType" == "xshow" ]; then
    echo && ps -ef | grep "python3 service.py" | grep -v grep && echo
fi

# [ Func 3 ] : kill process. For 'ExecStop=' in hre-appai.service
if [ "x$RunType" == "xstop" ]; then
    # TODO
    echo "Stopped"
fi
```

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
ExecStart=${PROJECT_ROOT}/bin/zhna-ai.sh start
User=hyren

[Install]
WantedBy=multi-user.target
EOF
cat /etc/systemd/system/hre-appai.service

# 启用服务
systemctl start hre-appai
# 启动后，用status看输出。
# 应该把脚本中的各个echo输出出来，包括RunType=start等
systemctl status hre-appai

tail -f -n100 /hyren/hrsapp/bin/zhna-ai-systemout.log

systemctl enable hre-appai

# 以下为调试用命令
# systemctl daemon-reload
# 修改脚本后重启服务，并用status看输出，用tail看日志
systemctl restart hre-appai
systemctl status hre-appai

# systemctl stop hre-appai
# systemctl disable hre-appai
```

---

