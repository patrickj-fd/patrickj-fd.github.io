[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

- 每个包目录下创建__init__.py
- 顶级目录下面建立setup.py文件
   
```
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
制作安装包：
1. 构建模块：python3 setup.py build。完成后会多出来一个build目录
2. 生成发布压缩包：python3 setup.py sdist。完成后生成dist目录，并且创建出一个gz压缩文件
3. 解压该文件，执行：python3 setup.py install，即完成安装到自己的Python目录下面。

关于find_packages的用法：
- 它默认在和setup.py同一目录下搜索各个含有 __init__.py 的包
- 排除某些包：find_packages(exclude=["test", "test.*"]
- 制定从哪个目录开始：find_packages('src') 注意还要加上package_dir和package_data

---

[首 页](https://patrickj-fd.github.io/index)
