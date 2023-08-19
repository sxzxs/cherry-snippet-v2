## cherry-snippet v2版本

### 介绍
`cherry-snippet` 是借助 [cherryTree](https://www.giuspen.com/cherrytree/) 笔记软件,制作的免费开源**文本片段管理工具**

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
|系统|开启html预览需要**win10**或者安装 **[webview2 runtime](https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/3c9f7ac6-fb0a-4eb7-b1fd-44c57613a3f5/MicrosoftEdgeWebView2RuntimeInstallerX64.exe)**|
|ahk 版本| [autohotkey v2H](https://github.com/thqby/AutoHotkey_H/releases)|
|cherryTree.exe|[cherryTree定制 蓝奏云](https://wwob.lanzoum.com/iq85Y15stpmb) 密码:cxue
|dx| [dx11 依赖下载](https://zhangyue667.lanzouh.com/DirectXRepairEnhanced)|

### 安装步骤
1. 下载zip，或者git clone后, 执行 cherry-snippet.ah2或者cherrysnippet.exe
2. 第一次执行会提示选择cherryTree.exe和data.ctb的目录(cherrytree_0.99.51.0_win64_portable\mingw64\bin\cherrytree.exe)

### 使用说明
首次编辑时，需要右键托盘图标点击编辑,打开cherryTree.exe后需要设置关闭退出并保存设置，后续节点跳转不需要
[按键列表](https://wyagd001.github.io/v2/docs/KeyList.htm#general)
##### 普通搜索模式
* 打开搜索界面, 默认 shift+enter
* 执行代码片段, 默认 enter
* 当前代码片段输入到目标窗口, 默认 ctrl+enter 
* 用cherrytree编辑当前代码片段, 默认 ctrl+e 
* 复制当前代码片段到系统剪切板, 默认 ctrl+c 

##### hook搜索模式
* 打开hook界面, 默认 shift+空格
* 当前代码片段输入到目标窗口, 默认 enter 

#### 插件
#### /cal 计算器
`例如: /cal 100+100`
#### /cd 词典翻译
`例如: /cd 我能实时翻译`
回车，输入到目标窗口
ctrl+enter,把对于的英文转为变量名称

#### /ai chatgpt插件

#### 自定义listview图标
1. 在cherrytree修改节点的属性,在tag添加 "icon:百度"关键字
2. 用上面方法设置名称后，需要放置对应名字的 Lnk,png,icon等格式的文件到/icons/tree目录

![img](https://img2023.cnblogs.com/blog/2850002/202302/2850002-20230222001733261-592590197.png)

![img](https://img2023.cnblogs.com/blog/2850002/202302/2850002-20230222001212880-2097820494.png)

父节点设置了icon，则子节点也同样继承
**icon:xx 必须写到最后**

#### 屏蔽节点和子节点
在cherrytree修改节点的属性,在tag添加 "屏蔽"关键字,见上图


#### 注意事项
* .ctb文件和导出路径一般不要设置到C盘(未知权限问题)
* cherrytree设置`启用系统托盘`可以加快跳转
![cherrytree启用系统托盘](./picture/cherrytree%E8%AE%BE%E7%BD%AE.png)

### TODO
* 快捷键设置ui完善
* html格式内容存入剪贴板