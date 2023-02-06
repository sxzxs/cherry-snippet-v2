;===============================================================================
; cherry-snippet 代码片段管理工具 
; Tested on AHK v2.0.2 Unicode 64-bit, Windows /10
; github https://github.com/sxzxs/cherry-snippet-v2 
;===============================================================================
; Script compiler directives
;@Ahk2Exe-SetCompanyName cherry-snippet				; 企业信息
;@Ahk2Exe-SetCopyright Copyright (c) cherry-snippet			; 版权信息
;@Ahk2Exe-SetLegalTrademarks 文本管理工具				; 更改合法商标信息.
;@Ahk2Exe-SetDescription 文本管理工具			; 文件说明
;@Ahk2Exe-SetFileVersion 0.2.0				; 文件版本
;@Ahk2Exe-SetInternalName 文本管理工具			; 文件内部名
;@Ahk2Exe-SetLanguage 0x0804				; 区域语言
;@Ahk2Exe-SetName 文本管理工具				; 名称
;@Ahk2Exe-SetProductName 文本管理工具			; 产品名称
;@Ahk2Exe-SetOrigFilename cherry-snippet.exe				; 原始文件名称
;@Ahk2Exe-SetProductVersion 0.2.0			; 产品版本号
;@Ahk2Exe-SetVersion 0.2.0				; 版本号
;@Ahk2Exe-SetMainIcon %A_ScriptDir%\icons\main.ico

#include <log>
#include <py>
#include <Class_SQLiteDB>
#include <TextRender>
#include <Child_process>
#Include <ComVar>
#include <WebView2>
#include <Direct2D>
#include <wincapture>
#include <Gdip_All>
#include <zmq>
#include ./utility/Tree_node_data.ah2
#include ./utility/Listview.ah2
#include ./utility/Config.ah2
#include ./utility/Main_gui.ah2
#include ./utility/Global_data.ah2
#include ./utility/Utility.ah2
#include ./utility/Webview2_preview.ah2
#include ./utility/ActiveX.ah2
#include ./utility/Zmq_send2cherry.ah2
#include ./utility/Input_hook.ah2

#SingleInstance force
#WinActivateForce
#ErrorStdOut
#Warn All, Off
main()
main()
{
	if(!A_IsAdmin)
	{
		MsgBox("请已管理员模式重启!!")
		ExitApp
	}

	DetectHiddenWindows true
	;清理重复进程
	instance_once()
	;检查是否有重复进程运行
	if(is_single_instance('cherry-snippet'))
	{
		MsgBox('提示,程序已启动!`n请勿重复运行')
		ExitApp
	}

	global obj_cfg := Config(A_ScriptDir "/config/settings.json")
	global cfg := obj_cfg.config
	global g_tr := TextRender()
	global g_hook_rendor := TextRender()
	global g_webview := Webview2_preview()
	global g_activex := ActiveX_preview()
	global g_ih := Input_hook()

	;设置log模式
	logger.is_log_open := cfg['is_log_open']
	logger.is_out_file := cfg['is_out_file']
	logger.is_use_editor := cfg['is_use_editor']

	;初始化
	;创建目录
	if(!FileExist(cfg['html_path'] '\data.ctb_HTML\res\'))
		DirCreate(cfg['html_path'] '\data.ctb_HTML\res\')
	;解析数据库
	Tree_node_data.load_db_data()
	Main_gui.create()
	;通过zmq 和 cherry通讯
	sender := Zmq_send2cherry()

	;注册热键
	Hotkey("~esc", (key) => (Main_gui.Hide(key)))
	Hotkey(cfg['key_open_search_box'], (key) => (copy_css2res(), Main_gui.edit.value := '',Main_gui.list_view.Delete(), Main_gui.show(key)))
	Hotkey(cfg['hook_open'], (key) => (copy_css2res(), g_ih.start()))

	HotIf(ObjBindMethod(g_ih, 'is_current_hook_mode'))
        Hotkey("tab", ObjBindMethod(g_ih, "on_tab", '+'))
        Hotkey("+tab", ObjBindMethod(g_ih, "on_tab", '-'))
	HotIf()
	HotIfWinActive("ahk_id " Main_gui.ui.Hwnd)
        Hotkey("enter", execute_command)
        Hotkey(cfg['key_send'], send_command)
		Hotkey("up", (*) => Main_gui.focus_before_row())
		Hotkey("down", (*) => Main_gui.focus_next_row())
		Hotkey("tab", (*) => Main_gui.focus_next_row())
		Hotkey("+tab", (*) => Main_gui.focus_before_row())
		Hotkey(cfg['key_quick_switch_node'], (*) => (Main_gui.hide(), sender.send_command(Global_data.current_select_node_id)))
	HotIf()
	;注册消息
	OnMessage(0x201, WM_LBUTTONDOWN)
	;定时监控cherryTree data文件变化
	SetTimer(monitor_file_change, 1000)
}

copy_css2res()
{
	try
	{
		if(FileExist(A_ScriptDir '\styles4.css') && !FileExist(cfg['html_path'] '\data.ctb_HTML\res\styles4.css'))
		FileCopy A_ScriptDir '\styles4.css', cfg['html_path'] '\data.ctb_HTML\res\', 1
	}
}

monitor_file_change()
{
	change_time := FileGetTime(cfg['db_path'], 'M')
	SplitPath(cfg['db_path'],, &db_dir)
	if(change_time > cfg['last_parse_time'])
	{
		List := WinGetList('ahk_exe cherrytree.exe',, 'Program Manager')
		for k,v in List
		{
			title := ''
			try 
			{
				title := WinGetTitle('ahk_id ' v)
			}
			if(InStr(title, " - " db_dir " - CherryTree"))
			{
            	if(instr(title, "*"))
					logger.info('Now is changing...')
				else
				{
					Tree_node_data.load_db_data()
 					SetTimer(monitor_file_change, 0)  ; 即此处计时器关闭自己.
					if(cfg['is_use_html_preview'])
					{
						logger.info('exporte to html')
						if(!FileExist(cfg['cherry_tree_path']))
							MsgBox('cherrytree.exe文件不存在,请在设置中配置!! ' cfg['cherry_tree_path'])
						if(!FileExist(cfg['db_path']))
							MsgBox('db.ctb文件不存在,请在设置中配置!!' cfg['db_path'])
						if(!FileExist(cfg['html_path'] '\data.ctb_HTML\res\'))
							DirCreate(cfg['html_path'] '\data.ctb_HTML\res\')
						cmd := '"' cfg['cherry_tree_path']  '" "'  cfg['db_path'] '" -x "' cfg['html_path'] '" -w -S'
						try
						{
							RunWait(cmd)
							FileCopy A_ScriptDir '\styles4.css', cfg['html_path'] '\data.ctb_HTML\res\', 1
						}
					}
					logger.info('again parse db...')
 					SetTimer(monitor_file_change, 250)  ; 重新开启定时器
				}
			}
		}
	}
}

send_command(*)
{
	Main_gui.hide()
    old_str := A_Clipboard 
    A_Clipboard := "" ; 清空剪贴板
    A_Clipboard := Global_data.current_select_text
    if(!ClipWait(2))
	{
		A_Clipboard := old_str
		return
	}
    SendInput('{RShift Down}{Insert}{RShift Up}')
}
execute_command(*)
{
	Main_gui.hide()
	if(Global_data.current_select_text == '')
		return
    if(SubStr(Global_data.current_select_text, 1, 3) == ";v2")
		child_process(A_ScriptDir '\interpreter\ahk-v2\AutoHotkey.exe', ['*'], true, { input: Global_data.current_select_text })
    else if(SubStr(Global_data.current_select_text, 1, 5) == "::bat")
		ReadProcessStdOut(Global_data.current_select_text)
	else
		child_process(A_ScriptDir '\interpreter\ahk-v1\AutoHotkey.exe', ['*'], true, { input: Global_data.current_select_text })
}

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) 
{
    global obj_cfg, cfg
	if(WinActive("ahk_id " g_activex.ui.hwnd))
		return
	PostMessage(0xA1, 2)
	KeyWait('LButton', 'U')
	Main_gui.ui.GetPos(&x, &y, &w, &h)
    if(x != "" && y != "" && w != "")
    {
        cfg['win_x'] := X
        cfg['win_y'] := Y
		obj_cfg.saveconfig()
    }
}