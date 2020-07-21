

# 安装
## wheels方式安装
```shell
python3 -m pip install opencv-python==4.1.1.26
```

## 验证
```python
import cv2
print(cv2.__version__)

import numpy as np

img = np.zeros((512, 512), np.uint8)         # 生成一张空的灰度图像
cv2.line(img, (0, 0), (511, 511), 255, 5)    # 绘制一条白色直线

# 图形终端下可运行下面代码
#cv2.namedWindow("gray")
#cv2.imshow("gray",img)#显示图像
# 循环等待，按q键退出
#while True:
#    key=cv2.waitKey(1)
#    if key==ord("q"):
#        break
#cv2.destoryWindow("gray")

cv2.imwrite('messigray.png', img)
```

## 源码编译方式安装
```shell
```

