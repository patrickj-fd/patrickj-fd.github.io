[首 页](https://patrickj-fd.github.io/index)

---

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

---

[首 页](https://patrickj-fd.github.io/index)
