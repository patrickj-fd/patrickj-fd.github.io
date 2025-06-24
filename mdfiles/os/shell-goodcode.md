[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

[Bash 脚本教程](https://wangdoc.com/bash/intro.html)

# 命令行参数
判断是否有命令行参数，并打印使用方式

```shell
#!/bin/bash

Usage(){
    echo "Usage: ......"
}

dosomthing(){
    echo -ne "Please input your name: "
    read name
    echo "Your name is %name"
}

main(){
    [ $# -ne 0 ] && {
        Usage
        exit 1
    }

    dosomthing
}

main $*
```

# 获取指定范围内的随机数
```shell
#!/bin/bash  
function rand(){ 
  local -r min=$1 
  local -r max=$(($2-$min+1)) 
  local -r num=$(($RANDOM+1000000000)) #增加一个10位的数再求余 
  echo $(($num%$max+$min)) 
} 

# 测试：获取100~950之间的随机数
echo$(rand 100 950)
```

---

[首 页](https://patrickj-fd.github.io/index)
