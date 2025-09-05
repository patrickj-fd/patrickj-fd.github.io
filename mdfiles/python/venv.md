
```shell
# 在当前目录下会创建一个“环境名”目录
python3 -m venv 环境名

# 激活虚拟环境
source <环境名称>/bin/activate

# 退出
deactivate
```

# 定制激活脚本
## powershell
在文件最后，改为下面的代码。
其中，`if (!$env:VIRTUAL_ENV_DISABLE_PROMPT) {` 里面修改的是最后一行代码： 改了PROMPT和显示路径。
```PowerShell
# get first char for PROMPT
$global:FD_VENV_PROMPT = (($env:VIRTUAL_ENV_PROMPT -split '[_-]') | ForEach-Object { $_.Substring(0,1) }) -join ''
# Write-Host "FD_VENV_PROMPT`t`t: $global:FD_VENV_PROMPT" -ForegroundColor Green
# get current script file path
$FD_SCRIPT_PATH = $MyInvocation.MyCommand.Path
# Write-Host "SCRIPT_PATH`t`t: $FD_SCRIPT_PATH" -ForegroundColor Green
# $global:FD_project_dirname = Split-Path (Split-Path (Resolve-Path "$THIS_PATH/..") -Parent) -Leaf
$global:FD_project_dirname = (Get-Item $FD_SCRIPT_PATH).Directory.Parent.Parent.Name
# Write-Host "FD_project_dirname`t: $global:FD_project_dirname" -ForegroundColor Green

if (!$env:VIRTUAL_ENV_DISABLE_PROMPT) {
    function global:_old_virtual_prompt {
        ""
    }
    $function:_old_virtual_prompt = $function:prompt

    function global:prompt {
        # Add the custom prefix to the existing prompt
        $previous_prompt_value = & $function:_old_virtual_prompt

        ("(" + $global:FD_VENV_PROMPT + ") " + $global:FD_project_dirname + "> ")
    }
}
```