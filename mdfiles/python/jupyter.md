[首 页](https://patrickj-fd.github.io/index)

---
# 必读
- 安装： https://callmsn.top/posts/vps折腾记四搭建jupyterlab服务器
- 用法：  https://www.codercto.com/a/75771.html

# 实用功能
## cell显示多个输出
```python
from IPython.core.interactiveshell import InteractiveShell
InteractiveShell.ast_node_interactivity = "all"

import numpy as np
import pandas as pd
df = pd.DataFrame(np.random.randn(3, 5))
df
df.info
print("OK")
```

# 定制主题

```
{
    // monaco , Hack-Regular , WenQuanYi Micro Hei Mono , Source Code Pro
    "codeCellConfig": {
        "fontFamily": "monaco",
        "fontSize": 14,
        "lineWiseCopyCut": true
    }
}
```

# 安装插件
命令行下安装更方便：
```shell
# 已安装插件清单
jupyter labextension list

# 安装
jupyter labextension install @jupyterlab/toc

# 更新
jupyter labextension update --all
```

# 通用配置
命令行执行：ipython profile create
会在 ~/.ipython/profile_default/ 下生成两个配置文件：
- ipython_config.py：打开任意 ipython kernel 时都会运行
- ipython_notebook_config.py：打开 notebook 时会运行

在配置文件中添加：
```
#c = get_config() 这个在jupyterlab中是否需要待验证
c.InteractiveShellApp.exec_lines = [
"import pandas as pd",
"import numpy as np",
"import scipy as sp",
"import torch as tor",
]
```

---

[首 页](https://patrickj-fd.github.io/index)
