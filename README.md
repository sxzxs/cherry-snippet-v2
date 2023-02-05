## cherry-snippet v2版本

### 介绍
`cherry-snippet` 是借助 [cherryTree](https://www.giuspen.com/cherrytree/) 笔记软件,制作的免费开源**文本片段管理工具**

**注**: 目前还处于beta版本, 稳定版本[cherry-snippet v1](https://github.com/sxzxs/cherry-snippet)

*v1->v2 改进: 用webview2预览、 d2d绘制hook界面、list列表增加图标*

* 代码片段**记录**和**快搜**和**预览**
* 代码片段**上屏输入**到目标窗口
![展示](./picture/sample.gif)
* 快速**添加编辑**
![编辑](./picture/edit.gif)
* 代码片段执行, 目前执行python、ahk、bat等,例如打开百度
![打开百度](./picture/open_baidu.gif)
* 搜索支持**拼音全拼、简拼、小鹤双拼、86五笔等**
* hook模式类似输入法,实时检测光标位置
![hook](./picture/HOOK.gif)

### 依赖环境
|环境|版本|
|-|-|
|系统|win10 或者安装 webview2 runtime|
|ahk 版本| [autohotkey v2H](https://github.com/thqby/AutoHotkey_H/releases)|
|cherry|[cherryTee定制版](https://pan.baidu.com/s/1romeZMHpUX9SPxnD5ZWtlw?pwd=2hpl) 提取密码:2hpl
|dx| [dx11](https://zhangyue667.lanzouh.com/DirectXRepairEnhanced)|

### 安装步骤
1. 下载zip，或者git clone后, 执行 cherry-snippet.ah2或者cherrysnippet.exe
2. 第一次执行会提示选择cherryTree.exe和data.ctb的目录(cherrytree_0.99.51.0_win64_portable\mingw64\bin\cherrytree.exe)

### 使用说明
##### 普通搜索模式
* 打开搜索界面, 默认 shift+enter
* enter 执行代码片段
* ctrl+enter 目标窗口输入
* ctrl+c 跳转cherrytree相应节点

##### hook搜索模式
* 打开hook界面, 默认 shift+空格
* enter 目标窗口输入

#### 注意事项
* .ctb文件和导出路径一般不要设置到C盘(未知权限问题)
* cherrytree设置`启用系统托盘`可以加快跳转
![cherrytree启用系统托盘](./picture/cherrytree%E8%AE%BE%E7%BD%AE.png)

### TODO
* hook模式添加
* 快捷键设置ui完善