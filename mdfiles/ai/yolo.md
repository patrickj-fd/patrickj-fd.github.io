[首 页](https://patrickj-fd.github.io/index)

---

# Yolo V4
## 官方原始模型
### 环境准备
- 下载框架和权重
  * 框架：git clone https://github.com/AlexeyAB/darknet.git
  * 权重：https://drive.google.com/open?id=1cewMfusmPjYWbrnuJRuKhPMwRe_b9PaT
- Jetson Nano，切换为MAXIN模式（10w）
- 修改daknet框架的配置
  * vi Makefile ：
    * CUDA、CUDNN、OPENCV置为 1
    * 20行开始的 ARCH 全部注释掉，改成：ARCH= -gencode arch=compute_53,code=[sm_53,compute_53]
  * vi cfg/yolov4.cfg ：将 "[net]" 组下的 batch 和 subdivisions 都改成1。默认的64和8是做训练时的配置值。
- 编译 : make
- 将权重文件yolov4.weights拷贝至darknet目录下
- 将测试的图片放入data目录下

### 开始检测
```shell
./darknet detect cfg/yolov4.cfg yolov4.weights data/dog.jpg
```

检测结果默认保存在当前目录下：predictions.png

Freeze Keras model and convert into TensorRT model
> https://www.dlology.com/blog/how-to-run-keras-model-on-jetson-nano/

YOLOv4实用训练实践
> https://www.cnblogs.com/wujianming-110117/p/12934969.html

# Yolo V4 Pytorch 版实现

- https://blog.csdn.net/c20081052/article/details/105995753
- https://blog.csdn.net/JIEJINQUANIL/article/details/106458002?utm_medium=distribute.pc_relevant_t0.none-task-blog-BlogCommendFromMachineLearnPai2-1.nonecase&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-BlogCommendFromMachineLearnPai2-1.nonecase
- https://blog.csdn.net/weixin_38353277/article/details/105841023?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.nonecase&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.nonecase

## 安装
yolov4 pytorch 版: https://github.com/Tianxiaomo/pytorch-YOLOv4
### 1. 现在 yolov4.Weights

  - baidu(https://pan.baidu.com/s/1dAGEW8cm-dqK14TbhhVetA Extraction code:dm5b)
  - google(https://drive.google.com/open?id=1cewMfusmPjYWbrnuJRuKhPMwRe_b9PaT)

该权重文件yolov4.weights 是在coco数据集上训练的，目标类有80种，当前工程支持推理，不包括训练

### 2. 复现效果
```shell
cd pytorch-YOLOv4
source 虚拟环境
python -m pip install -r requirements.txt
python demo.py -cfgfile cfg/yolov4.cfg -weightfile ../yolov4.weights -imgfile data/dog.jpg
```
当前目录下生成了预测结果文件：predictions.jpg

## 源码分析
### 1. demo.py
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



# Yolo V5
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
