[首 页](https://patrickj-fd.github.io/index)

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


---

[首 页](https://patrickj-fd.github.io/index)
