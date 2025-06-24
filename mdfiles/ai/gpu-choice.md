[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

参考：
> https://mp.weixin.qq.com/s/O0ggKWp7TFPzlpOGgOnwpA

- **训练需要 FP32 和 FP16 的性能**
- **推断需要 INT8 的性能**

# 用于训练的卡

| 型号       | 显存 | CUDA核 | Tensor核 | FP32 | FP16 | INT8 | 价格 |
| --- | --- | --- | --- | ---  | --- | --- | --- |
| GTX 1080Ti | 11 | 3584 | NA  | 11.3 | NA   | NA    | 5千
| RTX 2080   | 8  | 2944 | 368 | 10   | 40.3 | 161.1 | 5千
| RTX 2080Ti | 11 | 4532 | 544 | 13.4 | 53.8 | 215.2 | 8千
| Titan RTX  | 24 | 4608 | 576 | 16.3 | 130  | 260   | 1.5万
| Tesla V100 | 32 | 5120 | 640 | 15.7 | 125  | NA    | 8万
| RTX 3080   | 10 | 8704 |     |      |      |       | 5千？
| RTX 3090   | 24 | 10496 |     |      |      |       | 1万？

# 用于推理的卡

| 型号       | 显存 | CUDA核 | Tensor核 | FP32 | FP16 | INT8 | 价格 |
| --- | --- | --- | --- | ---  | --- | --- | --- | --- |
| Tesla P4   | 8  | 2560 | NA  | 5.5  | NA   | 22   | 1.5万
| Tesla P40  | 24 | 3584 | NA  | 12   | NA   | 47   | 4.4万
| Tesla P100 | 16 | 3584 | NA  | 10.6 | 21.2 | NA   | 5万
| Tesla V100 | 32 | 5120 | 640 | 15.7 | 125  | NA   | 8万
| Tesla T4   | 16 | 2560 | 640 | 8.1  | 65   | 130  | 2万

这些卡全部都是不带风扇的，但它们也需要散热，需要借助服务器强大的风扇被动散热，所以只能在专门设计的服务器上运行，具体请参考英伟达官网的说明。
