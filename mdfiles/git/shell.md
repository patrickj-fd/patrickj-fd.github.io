
# 拉取和推送
## Windows PowerShell
### 拉取
```PowerShell
Param(
    [string]$b,  # -b <branch name> or 'm'[means master]
    [switch]$f,  # -f overwrite
    [switch]$help
)
Write-Host "pullBranch=$b, overwrite=$f"

$currentBranch = git branch --show-current
$pullBranch = $currentBranch
if($b){
    $pullBranch = $b
}

function confirm {
    param(
        [string]$msg
    )
    Write-Host ""
    Write-Warning "Current   branch: '$currentBranch'"
    Write-Warning "Pull from branch: '$pullBranch'"
    Write-Host ""
    if(!$msg) { $msg="确认以上信息是否正确！[y] 继续 ...... " }
    Write-Host $msg -NoNewline
    $userInput = Read-Host
    if($userInput -ne 'y') {exit 0}
}

if($help){  #  $v -eq '', [string]::IsNullOrEmpty($v)
    Write-Host @"
Usage:
    -b <branch name. eg. 1.4>
    -f [pull and overwrite local]
"@
    exit 0
}

confirm

if($w){
    git fetch --all
    git reset --hard origin/${pullBranch}
}

git pull origin ${pullBranch}:${pullBranch}
```

### 推送
```PowerShell
Param(
    [string]$f,  # push files or '.'[means all file]
    [string]$m,  # commit message
    [string]$v,  # -v version number or 'm'[means master]
    [switch]$help
)

$currentBranch = git branch --show-current
$pushBranch = $currentBranch
if($v){
    $pushBranch = $v
}

function confirm {
    param(
        [string]$msg
    )
    Write-Host ""
    Write-Warning "Current branch: '$currentBranch'"
    Write-Warning "Push to branch: '$pushBranch'"
    Write-Host ""
    Write-Host "files=$f, message=$m"
    Write-Host ""
    if(!$msg) { $msg="确认以上信息是否正确！[y] 继续 ...... " }
    Write-Host $msg -NoNewline
    $userInput = Read-Host
    if($userInput -ne 'y') {exit 0}
}

if($help -or !$f -or !$m){
    Write-Host @"
Usage:
    -f <push files or '.'[means all file]>
    -m <commit message>
    -v [branch version. eg. 1.4]
"@
    exit 0
}

confirm
# Write-Host "files=$f, message=$m, version=$v"
# exit 0

git add "${f}"
git commit -m "${m}"
git push origin ${pushBranch}:${pushBranch}

Write-Host ""
Write-Host "======================================="
git status
```

## Linux
### 推送
```shell
#!/bin/bash
set -e

PushFiles=${1:?"Missing push files!"}
CommitMsg=${2:?"Missing commit message!"}

branch=$(git rev-parse --abbrev-ref HEAD)

echo
echo "now branch        : $branch"
echo
echo "commit message    : $CommitMsg"
echo
# git branch --show-current
# echo
# exit 1

read -p "请确认 (y/n): " user_input

if [[ "$user_input" =~ ^[yY]$ ]]; then
    # echo "提交 ......"
    git add "${PushFiles}"
    git commit -m "${CommitMsg}"
    git push origin $branch:$branch
fi
```

### 拉取
```shell
#!/bin/bash
set -e

branch=$(git rev-parse --abbrev-ref HEAD)

echo
echo "now branch        : $branch"
echo

read -p "请确认 (y/n): " user_input
if [[ "$user_input" =~ ^[yY]$ ]]; then
    echo "start pull ......"
    # dev/hangqing-zhutui
    git pull origin $branch:$branch
fi
```
