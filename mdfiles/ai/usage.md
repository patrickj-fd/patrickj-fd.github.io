[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

```python
import tensorflow as tf
import keras
config = tf.ConfigProto()

# 允许显存增长。如果设置为 True，分配器不会预先分配一定量 GPU 显存，而是先分配一小块，必要时增加显存分配
config.gpu_options.allow_growth = True

import keras.backend.tensorflow_backend as KTF
KTF.set_session(tf.Session(config=config))
# 或者，在使用keras/tf时，用：with tf.Session(config=config) as session: 封装上即可
# 对tf 1.14 的方法
# physical_devices = tf.config.experimental.list_physical_devices('GPU')
# assert len(physical_devices) > 0, "Not enough GPU hardware devices available"
# tf.config.experimental.set_memory_growth(physical_devices[0], True)
```

---

[首 页](https://patrickj-fd.github.io/index)
