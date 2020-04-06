[首 页](https://patrickj-fd.github.io/index)

---

```
#!/bin/bash

BINDIR=$(cd $(dirname $0); pwd)

CAR_NAME=$1
if [ "x$CAR_NAME" == "x" ]; then
  echo
  echo "============================================================="
  echo "[ERROR] Missing container name !"
  echo "Current container list :"
  docker container ls --format "table {{.ID}}\t{{.Names}}\t{{.Image}}"
  echo
  exit -1
fi

# match container by name
car_name_str=$(docker container ls --format "{{.Names}}" | grep "$CAR_NAME")
car_name_arr=($car_name_str)
car_name_num=${#car_name_arr[@]}
if [ $car_name_num -lt 1 ]; then
  echo
  echo "can not find container by '$CAR_NAME'"
  echo
  exit 2
elif [ $car_name_num -gt 1 ]; then
  echo
  echo "choice one car name : "
  echo -e "\033[36m${car_name_str}\033[0m"
  echo
  exit 3
fi

CAR_NAME=$car_name_str

echo
echo "Delete container : '$CAR_NAME'"
echo -n "stop ... "
docker container stop $CAR_NAME
echo
echo -n "rm   ... "
docker container rm   $CAR_NAME
echo
echo
```

---

[首 页](https://patrickj-fd.github.io/index)
