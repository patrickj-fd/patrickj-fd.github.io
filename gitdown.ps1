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
