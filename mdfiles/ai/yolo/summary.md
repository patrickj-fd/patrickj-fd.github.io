[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 参考
**对各种参数的疑问先看**： https://blog.csdn.net/qq_37662375/article/details/107774183


Freeze Keras model and convert into TensorRT model
> https://www.dlology.com/blog/how-to-run-keras-model-on-jetson-nano/

YoloV4 系列学习
> https://blog.csdn.net/JIEJINQUANIL/article/details/106459950

训练自己的YOLO V4数据集
> https://blog.csdn.net/weixin_38353277/article/details/105841023

用YOLOv4训练和测试数据集（保姆级）
> https://blog.csdn.net/Creama_/article/details/106209388

YOLOv4实用训练实践
> https://www.cnblogs.com/wujianming-110117/p/12934969.html

超详细讲解-要经常看
> https://www.cnblogs.com/lh2n18/p/12986898.html

# 1. YoloV4 官方darknet
## 1.1 获取
- 框架：git clone https://github.com/AlexeyAB/darknet.git
- 权重：https://drive.google.com/open?id=1cewMfusmPjYWbrnuJRuKhPMwRe_b9PaT

## 1.2 编译
### 1.2.1 修改 Makefile
```shell
# 根据本机的cuda版本安装路径，建立统一命名的符号链接
sudo ln -s /usr/local/cuda /usr/local/cuda-10.1

# 把原始Makefile复制一份，以便按照自己的要求进行修改
cp Makefile myMakefile.mk
vi myMakefile.mk
```

1. 修改 cuda 路径
所有 /usr/local/cuda-10.0/...  
改为 /usr/local/cuda/...  

2. 修改各相关变量
  - CUDA、CUDNN、OPENCV置为 1
  - 修改 ARCH
    * Jetson Nano : ARCH= -gencode arch=compute_53,code=[sm_53,compute_53]
    * GTX 1660 : ARCH= -gencode arch=compute_61,code=sm_61 -gencode arch=compute_61,code=compute_61

**[Makefile编写参考](http://c.biancheng.net/makefile/)**

### 1.2.2 编译
```shell
make -j4 -f myMakefile.mk
```

- 可能出现的错误

如果Makefile里面的[/usr/local/cuda]这个路径不正确，意味着编译程序时需要的环境变量LDFLAGS和CFLAGS都指向了错误的路径，从而导致编译报错如下：   
```
/usr/bin/ld: cannot find -lcudart
/usr/bin/ld: cannot find -lcurand
collect2: error: ld returned 1 exit status
```

这是因为：
```
LD_LIBRARY_PATH is used to modify the behaviour of the ldconfig and related tools when looking for the libraries, at execution time.

The ld linker tool doesn't use this variable. If you want to use a library located in a non-standard directory, you have to use the -L parameter of the command, like this : -L/usr/local/cuda/lib64
```

## 1.3 试试效果
- 下载权重文件yolov4.weights
```shell
# 将 cfg/yolov4.cfg "[net]" 组下的 batch 和 subdivisions 都改成1。默认的64和8是做训练时的配置值。
./darknet detect cfg/yolov4.cfg ../yolov4.weights data/dog.jpg
```
检测结果默认保存在当前目录下：predictions.png


## 1.4 标注和训练
### 1.4.1 使用labelImg标注
#### 1.4.1.1 安装和启动
[Download from github](https://github.com/tzutalin/labelImg)

支持Win/Linux/macOS平台，按照github上的说明即可安装。对于Win平台，直接下载release里面的zip文件，解压到任意目录即可使用。

- Windows上，启动前修改 ``data/predefined_classes.txt`` 文件

- Linux上可以使用下面的启动脚本(该脚本可放到$HOME/bin下面方便启动)

第一个参数：工程目录。包含了标注图片等数据。后续，训练用的cfg/data/names等文件、生成训练权重文件，都放到这里  
第二个参数：图片目录。建议使用train和valid，分别存放训练集和评估集  
默认，标注好的txt文件也会存到第二个参数指定的目录中。  

```shell
#!/bin/bash
set -e
. /usr/local/bin/fd_utils.sh

#BINDIR="$(cd "$(dirname "$0")" && pwd)"
# 工程根目录默认使用启动脚本位置的路径
PRJ_ROOT="${1:?"Usage: $(basename $0) . train [SAVED_PATH]"}"
[ "$PRJ_ROOT" == "." ] && PRJ_ROOT="$(pwd)"
echo "$PRJ_ROOT" | grep " " >/dev/null 2>&1 && die "Can not used dir<$PRJ_ROOT> because of space!"

# 训练使用的图片目录
# 建议在工程目录下创建两个目录：train和valid，分别对应data文件中的train和valid
IMAGE_PATH=${2:?"Missing image folder name!"}
[[ "$IMAGE_PATH" =~ ^/ ]] || IMAGE_PATH=$PRJ_ROOT/$IMAGE_PATH
[ -d "$IMAGE_PATH" ] || die "IMAGE_PATH<$IMAGE_PATH> is not regular dir!"

# 标注结果txt文件默认放到图片目录下，方便后面训练
SAVED_PATH=${3:-"${IMAGE_PATH}"}
[ -d "$SAVED_PATH" ] || die "SAVED_PATH<$SAVED_PATH> is not regular dir!"

PRE_DEFINED_CLASS_FILE="${PRJ_ROOT}/pre_defined_class_file.txt"
[ -f "$PRE_DEFINED_CLASS_FILE" ] || die "PRE_DEFINED_CLASS_FILE is not regular file"

# 使用脚本所在目录的名字作为工程名
PRJNAME="$(basename "$PRJ_ROOT")"
LOGFILE=/tmp/labelImg-$PRJNAME.log

echo 
echo IMAGE_PATH ........... : $IMAGE_PATH
echo SAVED_PATH ........... : $SAVED_PATH
echo PRE_DEFINED_CLASS_FILE : $PRE_DEFINED_CLASS_FILE
echo PRJNAME .............. : $PRJNAME
echo LOGFILE .............. : $LOGFILE
echo

echo "" >> $LOGFILE
echo "===== Start time : $(date) =====" >> $LOGFILE
python3 /opt/labelImg/gitrepo/labelImg.py $IMAGE_PATH $PRE_DEFINED_CLASS_FILE $SAVED_PATH >> $LOGFILE 2>&1 &

sleep 1
tail -f $LOGFILE
```

#### 1.4.1.2 使用
每个标注项目，建立如下目录结构：
```txt
[Root Dir]                         # 项目根目录
|--train/                          # 存放标注的语料图片（包括标注结果txt文件） - 训练集
|--valid/                          # 存放标注的语料图片（包括标注结果txt文件） - 验证集（训练时的标签文件）
|--pre_defined_class_file.txt      # YOLO使用的标注分类名
```

启动软件后做以下设置：  
- 选YOLO的存储格式
- 选择被标注图片所在目录。即：上面的train或valid目录
- 选择标注结果的存储目标。使用图片所在目录，方便后续做训练。
- 设置成自动保存：View菜单下选中自动保存
- 开始干活
  * w: 在图片上画框
  * d: 下一张图片（a: 上一张图片）
  * Ctrl+S 保存（如果没有设置成自动保存，那么，没处理一张要存一次）

标注结束后，使用下面脚本给没有目标的图片生成空的标注文件（txt文件）
```shell
#!/bin/bash
set -e
. /usr/local/bin/fd_utils.sh

IMG_DIR=${1:?"Missing img dir!"}
[ ! -d "$IMG_DIR" ] && die "<$IMG_DIR> is not regular dir!"
# 所有jpg, jpeg, png结尾的文件
empty_txtfile_nums=0
img_file_arr=($(ls ${IMG_DIR}/*.j* ${IMG_DIR}/*.p* 2>/dev/null || echo))
for img_file in "${img_file_arr[@]}"; do
    [ ! -f "$img_file" ] && continue
    file_sname=${img_file%.*}
    if [ ! -f "${file_sname}.txt" ]; then
        touch "${file_sname}.txt" && empty_txtfile_nums=`expr $empty_txtfile_nums + 1` || echo "touch ${file_sname}.txt failed!"
    fi
done
echo "Create empty txt file num : $empty_txtfile_nums"
```

#### 1.4.1.3 碰到的错误

- 碰到的错误："ZeroDivisionError: float division by zero"

使用过程中注意看启动软件的cmd窗口，有的图片会报ZeroDivisionError: float division by zero 错误，这时，标注结果的txt文件没有任何内容。  
解决办法：  
> https://github.com/tzutalin/labelImg/issues/386  
> https://github.com/tzutalin/labelImg/issues/309  

参考上面帖子，可使用下面代码对图片保存一次来解决问题：
```python
import os
import cv2

filename = ""
img_file = cv2.imread(filename, cv2.IMREAD_UNCHANGED)
fixed_filename = f"{os.path.splitext(os.path.basename(filename))[0]}.jpg"
cv2.imwrite(fixed_filename, img_file)
```

同样的图片，在Ubuntu上不会出现上述问题。

#### 1.4.1 - 找到两个目录下的同名文件
因为在标注的时候，可能不同的人一起工作，大家找到的语料图片的名字可能一样，造成合并时的问题。
- [python代码](find_eqfilename_2dir)


### 1.4.2 训练-使用官方darnet训练

#### (1) 配置训练环境
- 官网下载 yolov4.conv.137 文件
- 以 cfg/yolov4-custom.cfg 为模板修改成自己的配置文件（建议prj.cfg）。修改的参数参见官网。
  ```ini
  max_batches=classes*2000                  # 最小6000（极限不能小于4000）
  steps=max_batches*0.8, max_batches*0.9   
  classes=分类数                            # 修改3个[yolo]层中的classes为自己数据的分类数，如 classes=3
  filters=(classes+5)*3                     # 修改每一个[yolo]层之前的[convolutional]层中的filters。只需要修改[yolo]层之前的最后一个[convolutional]层，即一共只修改3个（整个文件中共有110个）
                                            # 当使用 [Gaussian_yolo]层时：
                                            #   修改每一个 [Gaussian_yolo] 层之前 [convolutional] 层中的 filter=(classes + 9)*3，共有3个[Gaussian_yolo] 层。如三分类： filter=36
  ```
- 定义 names 文件(建议prj.names)。每行是一个被检测目标的名字（与标注时使用的pre_defined_class_file.txt文件内容一样即可）
- 定义 data 文件(建议prj.data)。例如：
  ```
  classes= 2
  train = 工程全路径/train.txt              # 训练集。内容是每行一个jpg文件的全路径名
  valid = 工程全路径/valid.txt              # 标签集。内容是每行一个jpg文件的全路径名
  names = 工程全路径/prj.names
  backup = 工程全路径/weights               # 生成模型weights文件的目录，必须是绝对路径
  ```
- 生成train.txt和valid.txt
  * 每行一个标注文件的全路径（包括负样本图片：有0字节同名txt文件的图片）。使用[仓库](https://gitee.com/hyren/hrdarknet)中 ``hr_train_tools.py`` 自动生成。


#### (2) 训练

```shell
# 如果终端启动，要加上参数：-dont_show
./darknet detector train <data文件位置> <自己定义的custom.cfg文件位置> <yolov4.conv.137文件>

# 例如：在Comp-1660机器上执行训练（非常耗时，nohup到后台去）
cd ~/ln-yolo/yolov4/darknet
PRO_ROOT=/home/fd/ln-yolo/yolov4/projects-ABdarknet/yijia
nohup ./darknet detector train $PRO_ROOT/yijia.data $PRO_ROOT/yijia.cfg /home/fd/ln-yolo/yolov4/yolov4.conv.137 -dont_show > /tmp/darknet-train.log 2>&1 &
```

**训练心得**

- 当训练过程中被中断，可以将最后一次的模型作为预训练模型继续训练。如果一次训练时间太长，可以用中间自动保存的模型继续训练，中间自动保存模型，默认文件夹不改变的情况下在backup里面，训练命令：
./darknet detector train cfg/voc.data cfg/yolo-voc.cfg yolo-voc_final.weights  

直接基于final继续训练可能不行：cfg配置文件中max_batchs设置的为45000，中断之后将中断的模型作为预训练模型的前提迭代次数没有达到45000，如果之前已经训练完成了45000次，再次训练会直接输出final模型呢。如果想当完全训练完成后，会生成yolo-voc_final.weights模型，如果在现有的final模型之上继续训练，可以修改cfg配置文件。

#### （3） 验证自己的训练出来的模型
在训练的过程中，backup目录下生成weights文件，可以拿来验证效果
```shell
./darknet detector test <data文件> <自己定义的custom.cfg文件> backup/xxx_last.weights jpg文件
```

### 1.4.3 预测


## 1.3 程序解读
- [Darknet源码读不懂](https://www.jianshu.com/p/dfcde9ce7927)

### 1) data/labels目录的作用
该目录下有上百个小png文件，打开可知，是26个英文字母不同大小的图片，用于在预测结果上显示分类名字，所以也就意味着不支持中文。


## 1.9 使用 gdb 调试代码

如果程序出现“段错误   核心已转储”，可以用 gdb 定位代码错误
```txt
1. 编译程序时加上 '-g' 参数（加到Makefile里面最开始的COMMON里面即可）
COMMON= -g -Iinclude/ -I3rdparty/stb/include

2. 用gdb启动程序
gdb ./hrdarknet.bin

直接运行就来看看到底发生了什么：
(gdb) run

如果需要传递命令行参数，那么在run后面添加即可：
(gdb) run -datafile prj.data -cfgfile prj.cfg -weightsfile yolov4.conv.137 -dont_show

run后，会显示错误信息，例如：
Program received signal SIGSEGV, Segmentation fault.

(gdb) backtrace
#0  0x4007fc13 in _IO_getline_info () from /lib/libc.so.6
#1  0x4007fb6c in _IO_getline () from /lib/libc.so.6
#2  0x4007ef51 in fgets () from /lib/libc.so.6
#3  0x80484b2 in main (argc=1, argv=0xbffffaf4) at segfault.c:10
#4  0x40037f5c in __libc_start_main () from /lib/libc.so.6

这里我们只关心我们自己的代码，因此我们就切换到3号堆栈帧（stack frame3）来看看程序在哪里崩溃的：
(gdb) frame 3
#3  0x80484b2 in main (argc=1, argv=0xbffffaf4) at segfault.c:10
10        fgets(buf, 1024, stdin)

这句代码里，估计就是 buf 出了问题，打印看看他：
(gdb) print buf
$1 = 0x0

buf的值是0x0，也就是NULL指针。

(gdb) kill
杀掉上面的运行进程，设置断点单步跟踪看看

(gdb) break segfault.c:8

再次运行：
(gdb) run
```

[参考](https://blog.csdn.net/wlgy123/article/details/51150213)

对于darknet的训练程序，如果.data文件里面的指定的train文件里面的训练图片不存在，就会发生段错误！！！


# 2 YoloV4 Pytorch 版
WongKinYiu的两个实现版本（基于 ultralytics/yolov3和yolov5）
> https://github.com/WongKinYiu/PyTorch_YOLOv4
> https://github.com/WongKinYiu/PyTorch_YOLOv4/tree/u5_preview

- https://blog.csdn.net/c20081052/article/details/105995753

### 1.2.1 Pytorch - Tianxiaomo版
yolov4 pytorch 版: https://github.com/Tianxiaomo/pytorch-YOLOv4
#### 1. 下载 yolov4.Weights

  - baidu(https://pan.baidu.com/s/1dAGEW8cm-dqK14TbhhVetA Extraction code:dm5b)
  - google(https://drive.google.com/open?id=1cewMfusmPjYWbrnuJRuKhPMwRe_b9PaT)

该权重文件yolov4.weights 是在coco数据集上训练的，目标类有80种，当前工程支持推理，不包括训练

#### 2. 复现效果
```shell
cd pytorch-YOLOv4
source 虚拟环境
python -m pip install -r requirements.txt
python demo.py -cfgfile cfg/yolov4.cfg -weightfile ../yolov4.weights -imgfile data/dog.jpg
```
当前目录下生成了预测结果文件：predictions.jpg

#### 源码分析
- demo.py
```python
def detect(cfgfile, weightfile, imgfile):
    m = Darknet(cfgfile)  # 创建Darknet模型对象

    m.print_network()    # 打印网络结构
    m.load_weights(weightfile)  # 加载权重

    num_classes = 80
    if num_classes == 20:
        namesfile = 'data/voc.names'
    elif num_classes == 80:
        namesfile = 'data/coco.names'
    else:
        namesfile = 'data/names'

    use_cuda = 0  # 是否使用cuda，工程使用的是cpu执行
    if use_cuda:
        m.cuda()   # 如果使用cuda则将模型对象拷贝至显存，默认GUP ID为0；

    img = Image.open(imgfile).convert('RGB') # PIL打开图像
    sized = img.resize((m.width, m.height))

    for i in range(2):
        start = time.time()
        boxes = do_detect(m, sized, 0.5, 0.4, use_cuda)  # 做检测，返回的boxes是做完nms后的检测框；
        finish = time.time()
        if i == 1:
        print(f'{imgfile}: Predicted in {(finish - start):4f} seconds.')

    class_names = load_class_names(namesfile)   # 加载类别名
    print(f"class_names : {class_names}")
    plot_boxes(img, boxes, 'predictions.jpg', class_names)  # 画框，并输出检测结果图像文件；
```

在创建Darknet()对象过程中，会根据传入的cfg文件做初始化工作，主要是cfg文件的解析，提取cfg中的每个block；网络结构的构建；

创建网络模型是调用了darknet2pytorch.py中的create_network()函数，它会根据解析cfg得到的blocks构建网络，先创建个ModuleList模型列表，为每个block创建个Sequential()，将每个block中的卷积操作，BN操作，激活操作都放到这个Sequential()中；可以理解为每个block对应一个Sequential()；



# 5. YoloV5
## 复现
### 准备环境
环境要求： Python>=3.7 and PyTorch>=1.5.
- 下载框架和权重
  * 框架：git clone https://github.com/ultralytics/yolov5.git
  * 权重：仓库主页上有s/m/l等预训练模型下载（谷歌云盘）
### 开始检测
```shell
 python detect.py --source test/000000000019.jpg  --weights yolov5m.pt
 ```

## 训练自己的模型
> https://github.com/ultralytics/yolov5/wiki/Train-Custom-Data
> https://blog.csdn.net/laovife/article/details/106802725
> https://blog.csdn.net/qq_41562735/article/details/103509034


其他参考（yolo3）：
> https://blog.csdn.net/yuanlulu/article/details/85254828



---

[首 页](https://patrickj-fd.github.io/index)
