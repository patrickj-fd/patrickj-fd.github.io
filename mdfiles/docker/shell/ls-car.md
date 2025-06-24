[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

```shell
#!/bin/bash

ARG_a=""
ARG_z="F"
ARG_p="F"
while getopts 'azp' arg_opt; do
  case ${arg_opt} in
    a)
      ARG_a=" -a"
      ;;
    z)
      ARG_z="True"
      ;;
    p)
      ARG_p="True"
      ;;
    ?)
      echo
      echo "Usage: `basename $0` [Options] [container name]"
      echo "Options :"
      echo "  -a ：显示所有容器，否则只显示运行状态的容器"
      echo "  -z : Size"
      echo "  -p : Ports"
      echo 
      exit 1
    ;;
    esac
done

# 获得剩余的命令行参数：也就是指定的容器名字（模糊匹配）
shift $((OPTIND-1))
FilterContainerName="$@"

echo "====================================================================="
if [ "$ARG_z" == "True" -a "$ARG_p" == "True" ]; then
  docker container ls ${ARG_a} -f name="$FilterContainerName" --format 'table {{.ID}}   {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Size}}\t{{.Ports}}'
elif [ "$ARG_z" == "True" ]; then
  docker container ls ${ARG_a} -f name="$FilterContainerName" --format 'table {{.ID}}   {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Size}}'
elif [ "$ARG_p" == "True" ]; then
  docker container ls ${ARG_a} -f name="$FilterContainerName" --format 'table {{.ID}}   {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
else
  docker container ls ${ARG_a} -f name="$FilterContainerName" --format 'table {{.ID}}   {{.Names}}\t{{.Image}}\t{{.Status}}'
fi
echo
```

---

[首 页](https://patrickj-fd.github.io/index)