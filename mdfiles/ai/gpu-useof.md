[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 代码执行的GPU报错
## OOM
```
tensorflow/stream_executor/cuda/cuda_driver.cc:175] Check failed: err == cudaSuccess || err == cudaErrorInvalidValue Unexpected CUDA error: out of memory
```
该错误多数是因为其他进程对GPU的异常使用导致的。比如，在Docker中的某个程序执行异常，虽然该程序已经结束，但是Docker还占用这GPU，这时，通过nvidia-smi看不到有进程使用GPU。  
解决办法：
```
sudo nvidia-smi --gpu-reset
```
The above command may not work if other processes are actively using the GPU.

使用以下方法：
```
sudo fuser -v /dev/nvidia*
```
会看到类似如下结果：
```
/dev/nvidia0:        root       2216 F...m Xorg
                     sid        6114 F...m python3
                     sid        6114 F...m python3
                     sid        6114 F...m python3

# 这个6114进程非常可疑，看看是什么
ps -ef|grep 6114

# 发现是一个docker进程，停止它
docker container stop [container name]
```
至此，解决问题。（如果是系统中的某个程序，直接kill掉就可以了）

---

[首 页](https://patrickj-fd.github.io/index)
