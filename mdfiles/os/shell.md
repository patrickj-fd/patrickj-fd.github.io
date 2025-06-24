[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

[Bash 脚本教程](https://wangdoc.com/bash/intro.html)

# 脚本常用
```shell
# 脚本所在目录
BINDIR="$(cd "$(dirname "$0")" && pwd)"

# 防止变量为空！尤其是执行rm时！ 保证变量存在且非空，则返回它的值，否则打印出“变量名:默认值”。 SC2086 https://github.com/koalaman/shellcheck/wiki/SC2086
rm -rf "${SomePath:?}/"*    # 为了让这行有效果，脚本的第一行要设置成： set -e

# 获取 PID
PID=$(ps -ef|grep "查找串"|grep -v grep|awk '{print $2}'); echo "PID: $PID"

```

# 1. 变量
## 1.1 数值计算
```shell
echo $((2 + 3))     # $(( 表达式 )) 
```

## 1.2 变量空值处理
根据变量是否为空或者未设置，进行处理

```shell
${DIR:="x"}  # 变量存在且非空，则返回它的值，否则将它设置为默认值(x)。它的目的是：给空值变量赋一个默认值。
${DIR:-"x"}  # 变量存在且非空，则返回它的值，否则返回默认值(x)。它的目的是：返回一个默认值。
${DIR:+"x"}  # 变量存在且非空，则返回默认值(x)，否则返回空。
${DIR:?"undefined!"}  # 变量存在且非空，则返回它的值，否则打印出“变量名:默认值”，并中断脚本的执行。它的目的是防止变量未定义。
```

上面四种语法如果用在脚本中，变量名的部分可以用数字1到9，表示脚本的参数。

```shell
filename=${1:?"filename missing."}  # 1表示脚本的第一个参数。如果该参数不存在，就退出脚本并报错。
```

## 1.3 变量值：删除、替换、抽取

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

## 1.4 变量长度

| 语法     | 说明               |
| ---------- | -------------------- |
| ${#变量名} | 得到该变量的值的长度 |

```shell
VAL="hello, world and shell"
echo ${#VAL}               # 得到 22

VAL=("hello" "world and shell")
echo ${#VAL[@]}            # 得到 2。因为VAL现在是一个数组，所以其长度为 2

```

## 1.5 变量值在多种条件下的判断
```shell
ARCH=$(uname -m)
case $ARCH in
    i386|i686) ARCH=x86 ;;
    armv6*) ARCH=armv6 ;;
    *) ARCH=x86_64  # 其他所有情况的处理（不需要;;结束）
esac
```

# 2. 格式化输出
## 2.1 echo
- [-e 参数] 开启转义，即：对\n, \c, \t等字符进行转义输出
- [-n 参数] echo输出的文本末尾会有一个回车符，该参数取消末尾的回车符，使得下一个提示符紧跟在输出内容的后面

## 2.2 printf
- [%d %i] 十进制整数
- [%e] 浮点数
- [-] 左对齐
```shell
printf "[%-10s]\t[%s]\t[%5s]\n" "hello" "xx" "11"
printf "[%-10s]\t[%s]\t[%5s]\n" "222" "uuuuuuuuuu" "999"
```

# 3. 循环
for循环能以【空格】、【换行】、【tab】键作为分隔符
```shell
ValueList=$(ls)
# echo "ValueList : ${ValueList}"
value_arr=($ValueList)
for val in "${value_arr[@]}"; do    # 一定要加上双引号，否则在某些情况下出现意外
  echo "val=${val}"
done
```

# 4. 目录及文件名相关
```shell
parentdir_fullpath=$(dirname "$PWD")  # 把这个路径变量的最后一级名字作为一个“文件”看待，得到他所在目录全路径名。
curdir_name=$(basename "$PWD")  # 获得这个路径变量的最后后一级名字，也就是当前的目录名
```

---

[首 页](https://patrickj-fd.github.io/index)
