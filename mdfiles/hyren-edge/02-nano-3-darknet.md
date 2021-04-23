[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 设置 Makefile
- 修正cuda目录
所有诸如 [ /usr/local/cuda-10.0 ] 这样的目录，都修改为：[ /usr/local/cuda ]。  
因为 LDFLAGS 需要指定正确的目录，否则会报如下错误：
```
/usr/bin/ld: cannot find -lcudart
/usr/bin/ld: cannot find -lcurand
collect2: error: ld returned 1 exit status
```
这是因为：
```
LD_LIBRARY_PATH is used to modify the behaviour of the ldconfig and related tools when looking for the libraries, at execution time.

The ld linker tool doesn't use this variable. If you want to use a library located in a non-standard directory, you have to use the -L parameter of the command, like this : -L/usr/local/cuda/lib64
```

- ARCH
```
ARCH= -gencode arch=compute_53,code=[sm_53,compute_53]
```

# 设置 cfg
```
batch=1
subdivisions=1 
```


# 碰到的问题
## Error: no CUDA-capable device is detected
这最可能是因为执行程序的用户没有权限使用GPU，所以，首先加上 sudo 试试。
