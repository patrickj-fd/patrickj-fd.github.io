[首 页](https://patrickj-fd.github.io/index)

---
# 用法必读
> https://www.codercto.com/a/75771.html

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

# Jupyter lab themes
给浏览器安装 Stylus 插件，直接定制CSS，不需要去费劲寻找themes
```
a {color: #2456A4 !important;}
strong {color:#6392BF;}
em {color: #A9312A; font-style: normal !important;}
table {font-size: 90% !important;}

#jp-main-dock-panel {background-color: #f9f9f9;}
.jp-RenderedHTMLCommon {font-family: "Yuanti SC"; font-size: 100%;}
.jp-Notebook {background-color: #fbfafa;}
.CodeMirror, .jp-RenderedHTMLCommon pre {font-size: 90%;}
.jp-RenderedHTMLCommon pre {
    padding: 10px 25px;
    background-color: #fafafa;
    border-left: 4px solid #dadada;
    border-radius: 10px;
}

.jp-RenderedHTMLCommon pre code {
    background-color: #fafafa;
}

.jp-RenderedHTMLCommon h1 code,
.jp-RenderedHTMLCommon h2 code,
.jp-RenderedHTMLCommon h3 code,
.jp-RenderedHTMLCommon h4 code,
.jp-RenderedHTMLCommon p code,
.jp-RenderedHTMLCommon li code,
.jp-RenderedHTMLCommon blockquote p code,
.jp-RenderedHTMLCommon blockquote li code,
.jp-RenderedHTMLCommon td code {
    background-color: #f6f6f6;
    font-size: 90%;
    color:#2e2e2e;
    padding: 4px 4px;
    margin: 0 8px;
    box-shadow: 0px 1px 2px 0px rgba(0,0,0,0.2);
    border-radius: 4px;
}
```
以上是对JupyterLab Light 这个 Theme进行的定制修改。  
特别定制了 strong 和 em 两个元素的显示，让它们以不同的颜色展示；又因为中文并不适合斜体展示，所以，把 em 的 font-style 设定为 normal

也可以编辑Jupypter Lab主题，需要更改variables.css。位于：  
jupyterlab/packages/[THEME NAME]/style/

---

[首 页](https://patrickj-fd.github.io/index)
