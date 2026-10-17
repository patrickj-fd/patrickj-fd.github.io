
设置文件比较工具、合并时冲突窗口的工具
=====

# 一、设置：文件比较、合并冲突
```ini
[diff]
    tool = winmerge

[difftool "winmerge"]
    cmd = "D:/soft/WinMerge/WinMergeU.exe" -u -e -r -dl "Left" -dr "Right" "$LOCAL" "$REMOTE"

[difftool]
    prompt = false

[merge]
    tool = winmerge

[mergetool "winmerge"]
    cmd = "D:/soft/WinMerge/WinMergeU.exe" -u -e -dl "Local" -dr "Remote" -dm "Base" "$MERGED"
    trustExitCode = false

[mergetool]
    keepBackup = false  # 合并后不保留 .orig 备份文件
```

## 参数说明

* `-u`	不把 WinMerge 自身加到最近使用列表（防止污染临时文件路径）
* `-e`	按 Esc 即可关闭窗口
* `-r`	递归对比子目录（目录对比必须加）
* `-dl / -dr`	左右窗格标题。值可以任意起名字
* `$LOCAL / $REMOTE`	Git 传入的两侧文件/目录路径。一个字母都不能修改！

## 等价的命令
```bash
git config --global diff.tool winmerge
git config --global difftool.winmerge.cmd '"D:/soft/WinMerge/WinMergeU.exe" -u -e -r -dl "Left" -dr "Right" "$LOCAL" "$REMOTE"'
git config --global difftool.prompt false
```


## MacOS 参考配置
注意：值里面的双引号要转义，参考如下：
```ini
[diff]
	tool = meld
[difftool "meld"]
	cmd = /Applications/Meld.app/Contents/MacOS/Meld \"$LOCAL\" \"$REMOTE\"
[difftool]
	prompt = false
```

# 二、文件比较命令参考

1. 对比两个提交（最常用，等价于"两个目录"）
```bash
# 对比两个分支
git difftool -d main feature/x

# 只看某个子目录的差异
git difftool -d HEAD~1 HEAD -- src/main/java/xxx/yyy/zzz
```

2. 对比单个文件
```bash
git difftool HEAD~1 -- src/main/java/Foo.java
```

3. 比较 工作区（未commit的修改） vs HEAD(最新的一次提交)
```bash
# 全部改动，弹出 WinMerge 目录对比
git difftool -d HEAD

# 或省略 HEAD（效果一样）
git difftool -d

# 只比较某个文件
git difftool HEAD -- src/main/java/.../Foo.java

# 只比较某个目录
git difftool -d HEAD -- src/main/java/com/example/demo/service
```

如果要比较 `工作区`（未commit的修改）与指定版本，只需要把`HEAD`替换成指定的`hashid`即可。

- **方向**：左侧 = HEAD 的版本，右侧 = 工作区当前内容。