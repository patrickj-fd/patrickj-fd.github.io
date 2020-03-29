[首 页](https://patrickj-fd.github.io/index)

---

# 循环
```
ValueList=$(ls)
# echo "ValueList : ${ValueList}"
value_arr=($ValueList)
for val in ${value_arr[@]}; do
  echo "val=${val}"
done
```

---

[首 页](https://patrickj-fd.github.io/index)
