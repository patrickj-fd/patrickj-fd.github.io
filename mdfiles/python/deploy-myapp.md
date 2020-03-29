[首 页](https://patrickj-fd.github.io/index)

---

1. 建立程序目录my_package存放自己py文件，并且在同级目录创建__init__.py
2. 在my_package同级目录下面建立setup.py文件
```
#! -*- coding: utf-8 -*-

# from distutils.core import  setup
from setuptools import setup, find_packages

setup(
    name='压缩包的名字',
    version='0.1.0',
    description='用途描述',
    license='MIT Licence',
    url='https://kexue.fm',
    author='mi',
    author_email='miweicong@',
    install_requires=['keras>=2.3.0'],
    pymodules=['my_package.module1'],  多个py文件都依次写在这里
    packages=find_packages()
)
```
3. 构建模块：python3 setup.py build。完成后会多出来一个build目录
4. 生成发布压缩包：python3 setup.py sdist。完成后会生成一个gz压缩文件
5. 解压该文件，执行：python3 setup.py install，即完成安装到自己的Python目录下面。

---

[首 页](https://patrickj-fd.github.io/index)
