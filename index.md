
# 分类

- [ai](https://patrickj-fd.github.io/mdfiles/ai/index)
- [android](https://patrickj-fd.github.io/mdfiles/android/index)
- [docker](https://patrickj-fd.github.io/mdfiles/docker/index)
- [git](https://patrickj-fd.github.io/mdfiles/git/index)
- [java](https://patrickj-fd.github.io/mdfiles/java/index)
- [net](https://patrickj-fd.github.io/mdfiles/net/index)
- [os](https://patrickj-fd.github.io/mdfiles/os/index)
- [python](https://patrickj-fd.github.io/mdfiles/python/index)

# 源
> https://github.com/patrickj-fd/patrickj-fd.github.io

# 参考
[GitHub Markdown 概要](https://guides.github.com/features/mastering-markdown/)

[GitHub Markdown 详细](https://help.github.com/en/github/writing-on-github/basic-writing-and-formatting-syntax)

# config
```ini
[core]
    repositoryformatversion = 0
    filemode = true
    bare = false
    logallrefupdates = true
    ignorecase = true
    precomposeunicode = true
[remote "origin"]
    # same as: git remote add origin git@github:patrickj-fd/patrickj-fd.github.io.git
    url = git@github:patrickj-fd/patrickj-fd.github.io.git
    fetch = +refs/heads/*:refs/remotes/origin/*
[branch "main"]
    # Modify local default branch from master to main
    # same as: git branch --set-upstream-to=origin/main main
    remote = origin
    merge = refs/heads/main
```

- 本仓库是静态资源，可做如下优化
```ini
[core]
  # 禁用文件模式变更检测（静态文件无需执行权限）
  filemode = false
  # 关闭自动垃圾回收
  gc.auto = 0
```