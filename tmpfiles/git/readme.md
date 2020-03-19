
- git push时需要输入用户名密码的问题
```
vi ~/.gitconfig
# 添加如下代码
[credential]
helper = store --file .git-credentials
```

