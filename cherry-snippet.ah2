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

	;g_ih.start()
	;解析数据库
	Tree_node_data.load_db_data()
	Main_gui.create()
	;通过zmq 和 cherry通讯
	sender := Zmq_send2cherry()

	;注册热键
	Hotkey("~esc", (key) => (Main_gui.Hide(key)))
	Hotkey(cfg['key_open_search_box'], (key) => (Main_gui.edit.value := '',Main_gui.list_view.Delete(), Main_gui.show(key)))
	Hotkey(cfg['hook_open'], ObjBindMethod(g_ih, 'start'))

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
		Hotkey(cfg['key_quick_switch_node'], (*) => (sender.send_command(Global_data.current_select_node_id), Main_gui.hide()))
	HotIf()
	;注册消息
	OnMessage(0x201, WM_LBUTTONDOWN)
	;定时监控cherryTree data文件变化
	SetTimer(monitor_file_change, 1000)
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
			title := WinGetTitle('ahk_id ' v)
			if(InStr(title, " - " db_dir " - CherryTree"))
			{
            	if(instr(title, "*"))
					logger.info('Now is changing...')
				else
				{
 					SetTimer(monitor_file_change, 0)  ; 即此处计时器关闭自己.
					if(cfg['is_use_html_preview'])
					{
						logger.info('exporte to html')
						if(!FileExist(cfg['cherry_tree_path']))
							MsgBox('cherrytree.exe文件不存在,请在设置中配置!! ' cfg['cherry_tree_path'])
						if(!FileExist(cfg['db_path']))
							MsgBox('db.ctb文件不存在,请在设置中配置!!' cfg['db_path'])
						if(!FileExist(cfg['html_path']))
							DirCreate(cfg['html_path'])
						cmd := '"' cfg['cherry_tree_path']  '" "'  cfg['db_path'] '" -x "' cfg['html_path'] '" -w -S'
						Run(cmd)
					}
					logger.info('again parse db...')
					Tree_node_data.load_db_data()
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