[首 页](https://patrickj-fd.github.io/index)

---

[Bash 脚本教程](https://wangdoc.com/bash/intro.html)

# 变量
- 根据变量是否为空或者未设置，进行赋值
```shell
${DIR:-"/tmp"}  # DIR为空或未设置，则输出默认值(/tmp)，不修改原变量值
${DIR:="/tmp"}  # DIR为空或未设置，则输出默认值(/tmp)，且修改原变量值

${DIR:+"/tmp"}  # DIR设置了值，则输出默认值(/tmp)，不修改原变量值

DIR=${DIR%*/}         # 去掉结尾的'/'
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
for val in "${value_arr[@]}"; do    # 一定要加上双引号，否则在某些情况下出现意外
  echo "val=${val}"
done
```

# 目录及文件名相关
```shell
parentdir_fullpath=$(dirname "$PWD")  # 把这个路径变量的最后一级名字作为一个“文件”看待，得到他所在目录全路径名。
curdir_name=$(basename "$PWD")  # 获得这个路径变量的最后后一级名字，也就是当前的目录名
```
---

[首 页](https://patrickj-fd.github.io/index)
