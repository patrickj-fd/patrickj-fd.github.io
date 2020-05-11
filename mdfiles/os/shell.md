[首 页](https://patrickj-fd.github.io/index)

---

# 变量
- 根据变量是否为空或者未设置，进行赋值
```shell
DIR="${DIR:-"/tmp"}"  # DIR为空或未设置，则赋值为 /tmp
DIR="${DIR:+"/tmp"}"  # DIR设置了值，则赋值为 /tmp
```

- 变量值在多种条件下的判断
```shell
ARCH=$(uname -m)
case $ARCH in
    i386|i686) ARCH=x86 ;;
    armv6*) ARCH=armv6 ;;
    armv7*) ARCH=armv7 ;;
    aarch64*) ARCH=arm64 ;;
esac
```

# 循环
```shell
ValueList=$(ls)
# echo "ValueList : ${ValueList}"
value_arr=($ValueList)
for val in ${value_arr[@]}; do
  echo "val=${val}"
done
```

# 目录及文件名相关
```shell
parentdir=$(dirname "$PWD")  # 获得当前目录的上级目录全路径名
parentdir_name=$(basename "$parentdir")  # 获得当前目录的上级目录的名字
```
---

[首 页](https://patrickj-fd.github.io/index)
