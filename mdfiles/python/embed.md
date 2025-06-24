
[下载python(嵌入版)](https://www.python.org/ftp/python/3.9.13/python-3.9.13-embed-amd64.zip)
任意目录解压后即可。

## 安装pip
嵌入版不包含pip，需要手工安装。
- [下载pip安装脚本](get-pip.py) 官方地址：https://bootstrap.pypa.io/get-pip.py
- 同级目录下创建 pip.ini 文件，内容：
```txt
[global]
index-url=http://mirrors.aliyun.com/pypi/simple/
[install]
trusted-host=mirrors.aliyun.com
```
- 安装
  - 打开解压目录下的python39._pth文件，去掉“import site”前面的 # 号
  - 执行安装：`python-3.9.13-embed-amd64\python get-pip.py`




