[首 页](https://patrickj-fd.github.io/index)

---

[Bash 脚本教程](https://wangdoc.com/bash/intro.html)

# 变量
### 数值计算
```shell
echo $((2 + 3))     # $(( 表达式 )) 
```

### 变量空值处理
根据变量是否为空或者未设置，进行赋值
```shell
${DIR:-"/tmp"}  # DIR为空或未设置，则输出默认值(/tmp)，不修改原变量值
${DIR:="/tmp"}  # DIR为空或未设置，则输出默认值(/tmp)，且修改原变量值

${DIR:+"/tmp"}  # DIR设置了值，则输出默认值(/tmp)，不修改原变量值
```

### 变量值：删除、替换、抽取
| 语法                 | 说明                                             |
| ---------------------- | -------------------------------------------------- |
| '#'                    | 删除                                                |
| ${变量名#匹配规则} | 从变量【开头】进行匹配，将符合【最短】的数据删除 |
| ${变量名##匹配规则} | 从变量【开头】进行匹配，将符合【最长】的数据删除 |
| '%'                    | 删除                                                |
| ${变量名%匹配规则} | 从变量【尾部】进行匹配，将符合【最短】的数据删除 |
| ${变量名%%匹配规则} | 从变量【尾部】进行匹配，将符合【最长】的数据删除 |
| '/'                    | 替换                                                |
| ${变量名/查找串/新串} | 变量值中，【第一个】符合“查找串”的字符被“新串”替换 |
| ${变量名//查找串/新串} | 变量值中，【所有】符合“查找串”的字符被“新串”替换 |
| ':'                    | 抽取                                                |
| ${变量名:位置} | 从【位置】开始，得到后面的值 |
| ${变量名:位置:长度} | 从【位置】开始，得到后面【长度】 |
| ${变量名:-位置:长度} | 从【倒数位置】开始，得到后面的值 |

```shell
VAL="hello, world and shell"
echo ${VAL#* }             # 第一个空格前字符被删除，得到 'world and shell'
echo ${VAL##* }            # 第后的空格前字符被删除，得到 'shell'

echo ${DIR%*/}             # 去掉结尾的'/'
echo ${PATH/bin/BIN}       # 第一个bin被替换成了BIN

echo ${VAL:7}              # 得到 'world and shell'
```

### 变量长度
| 语法     | 说明               |
| ---------- | -------------------- |
| ${#变量名} | 得到该变量的值的长度 |

```shell
VAL="hello, world and shell"
echo ${#VAL}               # 得到 22

VAL=("hello" "world and shell")
echo ${#VAL[@]}            # 得到 2。因为VAL现在是一个数组，所以其长度为 2

```

### 变量值在多种条件下的判断
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
for循环能以【空格】、【换行】、【tab】键作为分隔符
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
