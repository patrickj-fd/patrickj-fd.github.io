[首 页](https://patrickj-fd.github.io/index)

---

# 参考
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
- 选YOLO的存储格式
- 选择被标注图片所在目录
- 选择标注结果的存储目标（Ctrl+R）

### 1.4.2 训练-使用官方darnet训练

#### (1) 配置训练环境
- 官网下载 yolov4.conv.137 文件
- 以 cfg/yolov4-custom.cfg 为模板修改成自己的配置文件。修改的参数参加官网
- 把标注的文件存到任意位置（成对的jpg和txt）
- 定义 names 文件（eg. yijia.names）
- 定义 data 文件（eg. yijia.data）
```
classes= 2                 分类数
train  = 全路径/train.txt
valid  = 全路径/test.txt
names = 全路径/yijia.names
backup = backup/           生成模型weights文件的目录，必须是这个名字
```
- 定义训练集和测试集（即data文件里面定义的两个文件：train和test）。内容是每行一个jpg文件的全路径名

#### (2) 训练
```shell
# 如果终端启动，要加上参数：-dont_show
./darknet detector train <data文件位置> <自己定义的custom.cfg文件位置> <yolov4.conv.137文件>

# 例如：在Comp-1660机器上执行训练（非常耗时，nohup到后台去）
cd ~/ln-yolo/yolov4/darknet
PRO_ROOT=/home/fd/ln-yolo/yolov4/projects-ABdarknet/yijia
nohup ./darknet detector train $PRO_ROOT/yijia.data $PRO_ROOT/yijia.cfg /home/fd/ln-yolo/yolov4/yolov4.conv.137 -dont_show > /tmp/darknet-train.log 2>&1 &
```

#### （3） 验证自己的训练出来的模型
在训练的过程中，backup目录下生成weights文件，可以拿来验证效果
```shell
./darknet detector test <data文件> <自己定义的custom.cfg文件> backup/xxx_last.weights jpg文件
```

## 1.3 程序解读
- [Darknet源码读不懂](https://www.jianshu.com/p/dfcde9ce7927)

### 1) data/labels目录的作用
该目录下有上百个小png文件，打开可知，是26个英文字母不同大小的图片，用于在预测结果上显示分类名字，所以也就意味着不支持中文。


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
