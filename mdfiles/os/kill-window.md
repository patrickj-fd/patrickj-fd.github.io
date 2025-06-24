[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

以清理微信多余窗口为例：
```shell
#!/bin/bash

windowsList=$(wmctrl -l -G -p -x)
result="${windowsList}"

while read -r line; do
    id=''
    index=0
    name='null'
    title='null'
    for i in ${line[@]}; do
      if [ $index == 0 ]; then
        id=$i
      elif [ $index == 7 ]; then
        name=$i
      elif [ $index == 9 ]; then
          title=$i;
      fi
      index=$((index + 1))
    done

    #echo "name : [$name] , title : [$title]"
    printf "%-45s  %-45s\n" $name $title

    if [ $name == 'wechat.exe.Wine' ]; then
      if [ $title != '微信' ]; then
        xdotool windowunmap $id
        echo "  -->[CLEAN] : id=$id name=$name title=$title"
      fi
    fi

    if [ $name == 'explorer.exe.Wine' ]; then
      if [ $title == 'Wine' ]; then
        xdotool windowunmap $id
        echo "  -->[CLEAN] : id=$id name=$name title=$title"
      fi
    fi

done <<< "$result"
```

---

[首 页](https://patrickj-fd.github.io/index)
