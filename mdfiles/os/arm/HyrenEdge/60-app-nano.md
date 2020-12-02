
# 在 Nano 上安装 AI 应用

---

**使用 hyren 用户工作**

## 安装项目

```shell
PROJECT_ROOT=/hyren/app/zhihuinongan
mkdir -p ${PROJECT_ROOT}
cd ${PROJECT_ROOT}

git clone http://139.9.126.19:38111/zhihuinongan/python.git

cd ${PROJECT_ROOT}/python/resources/module/nongan
# get model file from 63 root/q1w2e3 :
sftp root@172.168.0.63
> get /data1/project/zhihuinongan/hrsapp/dist/python/resources/module/nongan/last1.h5
> bye

source ~/pyvenv-tf15  # cp from : /hyren/python/venv/tf-1.15/bin/activate

python3 -m pip install -U git+http://139.9.126.19:38111/FdcoreHyren/feedwork-py.git
python3 -m pip install flask==1.1.2 requests==2.25.0 pillow==8.0.1
# python3 -m pip install matplotlib==3.3.2 h5py==2.10.0
```

## 测试项目
```shell
# 建立测试环境
TEST_ROOT=${PROJECT_ROOT}/test
mkdir ${TEST_ROOT} ${TEST_ROOT}/pic
cd ${TEST_ROOT} && ls

# 从本机上传测试图片过来
sftp hyren@172.168.0.163
> cd /hyren/app/zhihuinongan/test/pic
> put *.jpg

# 运行测试程序
cd ${PROJECT_ROOT}/python/yolov4-keras
# 进入python环境执行以上代码的方式：
# HRS_RESOURCES_ROOT=${PROJECT_ROOT}/python/resources python3

HRS_RESOURCES_ROOT=${PROJECT_ROOT}/python/resources python3 test.py
# input : /hyren/app/zhihuinongan/test/pic/*.jpg
# 把 *-result.jpg 取出来看结果
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

- 启动服务的工具脚本
```shell
#! /bin/bash

set -e

BINDIR=$(cd $(dirname $0); pwd)

# for kill process
if [ "x$1" == "xstop" ]; then
    PID=$(cat ${BINDIR}/service.pid)
    kill $PID && sleep 1
    ps -ef | grep "python3 service.py" | grep -v grep
    exit
fi

# just for show process
if [ "x$1" == "xshow" ]; then
    ps -ef | grep "python3 service.py" | grep -v grep
    exit
fi

# start new process
cd /hyren/app/zhihuinongan/python/yolov4-keras > /dev/null

export HRS_RESOURCES_ROOT=/hyren/app/zhihuinongan/python/resources

echo "" >> ${BINDIR}/service.log
echo "========== $(date) ==========" >> ${BINDIR}/service.log

nohup python3 service.py >> ${BINDIR}/service.log 2>&1 &
sleep 1
PID=$(ps -ef | grep "python3 service.py" | grep -v grep | awk '{print $2}')
if ps -p $PID > /dev/null
then
    echo "$PID" > ${BINDIR}/service.pid
    echo
    tail -f -n100 /hyren/app/zhihuinongan/service.log
else
    echo "service.py PID(=$PID) not exist!"
fi

cd - > /dev/null
```

---

