


https://www.jianshu.com/p/e1f79d942ec9


- 下载 Dashboard。 它是一个cocos creator的版本管理工具
- 双击安装即可。若后续需要编译android和ios的版本，则必须安装Visual Studio 2017
- 安装完成后，先不着急点击创建项目，因为还没下载任何cocos creator的版本。
    点击左侧菜单栏中的Editor，点击Download去下载。下载完成后，再切到Project的界面，就会发现多了很多模板项目。

# 设置
## 设置vscode
- 设置settings.json

在[文件—>首选项—>设置—>用户设置]下，选“文本编辑器/Text Editor”，慢慢向下拉，找到“Edit in settings.json”，按照官网安装手册上，增加search.exclude和files.exclude

- 使用 VS Code 激活脚本编译（按照官网步骤即可）：

解决：使用外部文本编辑器修改项目脚本后，要重新激活 Cocos Creator 窗口才能触发脚本编译

在 Creator 编辑器主菜单里执行[开发者 -> VS Code 工作流 -> 添加编译任]即可。(该操作会在项目的 .vscode 文件夹下添加 tasks.json 任务配置文件)
对于Win环境，如果输出窗口乱码，修改.vscode/task.json文件的"command"中的路径分隔符为win平台的两个正斜线。

之后，每次修改js文件后的编译方式为：Cmd/Ctrl + P，输入"task compile"，点"compile"即完成编译。
也可以增加编译快捷键：Code -> 首选项 -> 键盘快捷方式，添加自己的快捷键: 输入runTask找到对应的行，添加快捷键即可。

