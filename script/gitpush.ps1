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
if(!$f){
    $f = "."
}
if(!$m){
    $m = "update"
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
