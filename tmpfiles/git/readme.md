
- git push时需要输入用户名密码的问题
```
vi ~/.gitconfig
# 添加如下代码
[credential]
helper = store --file .git-credentials
```

- git add . -A -all -u 的区别
  * git add .  ：他会监控工作区的状态树，使用它会把工作时的所有变化提交到暂存区，包括文件内容修改(modified)以及新文件(new)，但不包括被删除的文件。
  * git add -u ：他仅监控已经被add的文件（即tracked file），他会将被修改的文件提交到暂存区。add -u 不会提交新文件（untracked file）。（git add --update的缩写）
  * git add -A ：提交所有变化。是上面两个功能的合集（git add --all的缩写）
