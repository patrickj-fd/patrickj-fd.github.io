[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 控制风扇转速
```shell
# 这是风扇火力全开
sudo sh -c 'echo 255 > /sys/devices/pwm-fan/target_pwm'

# 风扇关闭
sudo sh -c 'echo 20 > /sys/devices/pwm-fan/target_pwm'
# 执行关闭风扇指令后风扇并不会立即关闭，而是缓慢慢慢的关闭。
# 观察风扇的转速，会发现是从100%缓慢降到0的。
jtop
```

### 根据CPU温度控制转速
```python
import time
downThres = 48
upThres = 58
baseThres = 40
ratio = 5
sleepTime = 30
 
while True:
    fo = open("/sys/class/thermal/thermal_zone0/temp","r")
    thermal = int(fo.read(10))
    fo.close()
 
    thermal = thermal / 1000
 
    if thermal < downThres:
        thermal = 0
    elif thermal >= downThres and thermal < upThres:
        thermal = baseThres + (thermal - downThres) * ratio
    else:
        thermal = thermal
 
 
    thermal = str(thermal)
 #   print thermal
 
    fw=open("/sys/devices/pwm-fan/target_pwm","w")
    fw.write(thermal)
    fw.close()
 
    time.sleep(sleepTime)
```

---

[首 页](https://patrickj-fd.github.io/index)
