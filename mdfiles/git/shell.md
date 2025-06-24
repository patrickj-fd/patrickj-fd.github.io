
# 拉取和推送
## PowerShell
### 拉取
```shell
Param(
    [string]$v,  # -v version number or 'm'[means master]
    [switch]$w,  # -w not value
    [switch]$help
)
Write-Host "version=$v, overwrite=$w"
if($help -or !$v){  #  $v -eq '', [string]::IsNullOrEmpty($v)
    Write-Host """
    Usage:
    -v <branch version. eg. 1.4>
    -w [pull and overwrite local]
"""
    exit 0
}

if($w){
    git fetch --all
    git reset --hard origin/${v}
}

if($v -eq 'm'){
    git pull
} else {
    git pull origin ${v}:${v}
}
```

### 推送
```shell
Param(
    [string]$f,  # push files or '.'[means all file]
    [string]$m,  # commit message
    [string]$v,  # -v version number or 'm'[means master]
    [switch]$help
)
# Write-Host "files=$f, message=$m, version=$v"
# exit 0
if($help -or !$f -or !$m -or !$v){
    Write-Host """
    Usage:
    -f <push files or '.'[means all file]>
    -m <commit message>
    -v <branch version. eg. 1.4>
"""
    exit 0
}

git add "${f}"
git commit -m "${m}"
if($v -eq 'm'){
    git push
} else {
    git push origin ${v}:${v}
}

Write-Host ""
Write-Host "======================================="
git status
```

## Linux
### 推送
```shell
set -e

PushFiles=${1}
if [ "x$PushFiles" == "x" ]; then
    git status
    echo
    echo "======================================="
    echo "需要指定要提交的文件。 '.'：提交全部"; 
    echo
    exit 1
fi

CommitMsg=${2:?"Missing commit message!"}

VersionInfo=${3:?"Missing version <m/version info>! (eg: 'm' means current branch, Or 1.3)"}
# echo VersionInfo="${VersionInfo}"; exit 1

git add "${PushFiles}"
git commit -m "${CommitMsg}"
if [ "x$VersionInfo" == "xm" ]; then
    git push
else
    git push origin ${VersionInfo}:${VersionInfo}
fi

echo
echo "======================================="
echo "提交完成，本地仓库现在的状况："
echo
git status
```