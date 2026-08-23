
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
### 推送 `gitpush.sh`
```shell
#!/bin/bash

set -e
# 管道中命令失败也退出
set -o pipefail

function die() {
    echo ""; echo "❌ $1"; echo ""
    exit 1
}

# ========== 用法提示 ==========
if [ $# -lt 1 ]; then
    echo "用法:"
    echo "  $0 <\"commit-msg\" | -F=commit-msg-file> [ -D | files... ]"
    echo ""
    echo "参数说明:"
    echo "  第1个参数：必填。commit 消息文本，或 -F=文件（文件第1行作为短描述）"
    echo "  后续参数： -D 为干跑模式；其余为提交文件清单；无则提交所有"
    echo "  '-D'    : 干跑模式（只显示会执行什么，不实际操作）"
    echo ""
    exit 1
fi

# 先检查是否在 git 仓库内
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    die "当前目录不是 git 仓库"
fi

# ========== 1. 参数解析 ==========
CommitMsg="$1"
shift

DryRun=false
FILES=""

for arg in "$@"; do
    if [[ "$arg" = "-D" ]]; then
        DryRun=true
    elif [[ "$arg" = -* ]]; then
        die "未知参数: $arg"
    else
        [[ "$arg" =~ [[:space:]] ]] && die "文件名 '$arg' 中包含空格。请自行 git add 后再运行本脚本（不带文件参数）"
        [[ "$arg" =~ [*?\[\]] ]] && die "文件名 '$arg' 中包含通配符。请自行 git add 后再运行本脚本（不带文件参数）"
        FILES="$FILES $arg"
    fi
done
FILES="${FILES# }"

# ========== 2. 解析提交信息 ==========
CommitMsgFile=""
if [[ "$CommitMsg" =~ ^-F=(.+)$ ]]; then
    CommitMsgFile="${BASH_REMATCH[1]}"
    [[ -f "$CommitMsgFile" ]] || die "commit 消息文件 '$CommitMsgFile' 不存在!"
    # 去掉文件开头所有空行，取第一行
    FIRST_LINE="$(sed '/^[[:space:]]*$/d' "$CommitMsgFile" | head -n 1)"
    [[ -z "$FIRST_LINE" ]] && die "commit 消息文件 '$CommitMsgFile' 内容为空（全是空行）"
    if [[ ${#FIRST_LINE} -gt 25 ]]; then
        echo "   预览: $FIRST_LINE"
        die "commit 消息首行超过 25 个字符（当前 ${#FIRST_LINE} 字符），请精简"
    fi
    COMMIT_MSG_PREVIEW="$(echo "$FIRST_LINE" | sed 's/^/   /')  ...... more in commit msg file"
else
    COMMIT_MSG_PREVIEW="$CommitMsg"
fi

# 空提交消息拦截
[[ -z "$CommitMsg" ]] && die "commit 消息不能为空"

# ========== 3. 获取当前分支 ==========
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
    die "当前是全新仓库（无提交），请先手工执行一次提交：add -> commit -> push"
fi

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

# rebase 中间状态检测
REBASE_MERGE="$(git rev-parse --git-path rebase-merge 2>/dev/null)"
REBASE_APPLY="$(git rev-parse --git-path rebase-apply 2>/dev/null)"
if [[ -d "$REBASE_MERGE" || -d "$REBASE_APPLY" ]]; then
    echo ""
    echo "❌ 当前处于 rebase 中间状态！"
    echo ""
    echo "📋 请先完成或放弃之前的 rebase："
    echo "  完成: git rebase --continue"
    echo "  放弃: git rebase --abort"
    echo ""
    echo "  完成后直接 git push origin $branch:$branch 即可，无需重新运行本脚本。"
    echo ""
    exit 1
fi

# ========== 4. 干跑模式 / 用户确认 ==========
echo ""

if [ "$DryRun" = true ]; then
    echo "🏃 [DRY RUN] 以下是将要执行的命令："
    if [[ -n "$FILES" ]]; then
        echo "   git add $FILES"
    else
        echo "   git add -A"
    fi
    if [[ -n "$CommitMsgFile" ]]; then
        echo "   git commit -F \"$CommitMsgFile\""
    else
        echo "   git commit -m \"$CommitMsg\""
    fi
    echo "   git push origin $branch:$branch"
    echo ""
    echo "🏃 [DRY RUN] 未执行任何实际操作。"
    exit 0
fi

# ========== 5 正式推送前：前置条件检查 ==========
# 5.1 检查暂存区是否有已暂存但未提交的内容 -- 添乱：暂存区里如果有东西，一并提交就行了
# if ! git diff --cached --quiet; then
#     echo "❌ 当前暂存区已有已暂存的内容："
#     git diff --cached --name-status
#     echo ""
#     echo "📋 请先处理这些暂存内容："
#     echo "   1. 如果确认不需要，请取消暂存：git reset HEAD <file>"
#     echo "   2. 如果需要提交，请先提交它们"
#     echo "   3. 或者清空暂存区后重新运行本脚本"
#     exit 1
# fi

# 5.2 检查远程是否有新提交  →  有则退出  →  无则 允许继续（add → commit → push）
echo ""; echo "🔍 检查远程仓库是否有新提交..."
if ! REMOTE_HASH=$(git ls-remote origin "$branch" | awk '{print $1}'); then
    die "git ls-remote 失败（网络问题或远程不存在）"
fi
if [[ -z "$REMOTE_HASH" ]]; then
    echo "   → 远程分支不存在（首次推送），跳过检查。"
else
    LOCAL_HASH=$(git rev-parse "$branch")
    if [[ "$LOCAL_HASH" != "$REMOTE_HASH" ]]; then
        echo ""; echo "❌ 远程仓库与本地不一致： 原因1) 远程有新提交  原因2) 也可能是本地提交后未推送。"; echo ""
        echo "✅ 请根据实际情况处理："
        echo "   git pull --rebase origin $branch   # 若远程有新提交"
        echo "   git push origin $branch            # 若本地领先"
        echo ""; echo "   处理完成后，再重新运行本脚本提交。"; echo ""
        exit 1
    fi
fi

# 5.3 正式推送前：推送情况确认
echo "🌿 分支    : $branch"
echo "📝 提交信息 : $COMMIT_MSG_PREVIEW"
echo "📦 文件    : ${FILES:-所有文件}"
echo ""
read -r -p "🚀 确认提交并推送? (y/n): " user_input
[[ "$user_input" =~ ^[Yy]$ ]] || die "已取消操作。"

# ========== 6. 执行 git add + commit ==========
echo ""

# 1. git add
if [[ -n "$FILES" ]]; then
    git add $FILES || die "git add 失败（可能文件不存在）"
else
    git add -A || die "git add -A 失败"
fi

# 2. git commit
echo "📝 提交中..."
if [[ -n "$CommitMsgFile" ]]; then
    # --cleanup=whitespace: 强制 Git 不要删除 # 行（显式指定 mode，避免受 config 影响）
    if ! commit_output=$(git commit --cleanup=whitespace -F "$CommitMsgFile" 2>&1); then
        echo "$commit_output"
        die "git commit 失败，请检查上方输出"
    fi
else
    if ! commit_output=$(git commit -m "$CommitMsg" 2>&1); then
        echo "$commit_output"
        die "git commit 失败，请检查上方输出"
    fi
fi

# ========== 7. git push ==========
echo ""
echo "☁️  推送到 origin/$branch ..."
# '-u'是首次推送才需要加，这里加上为了省事：没必要再去判断是不是首次了！
git push -u origin "$branch:$branch" || die "推送失败，请人工排查问题！"

echo ""; echo "✅ 提交完成. 以下是提交后，仓库当前的状态："; echo ""
git status
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
