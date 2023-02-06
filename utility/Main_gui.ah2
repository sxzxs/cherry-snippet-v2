class Main_gui
{
	static __New()
	{
		this.cherry_icon_list := ['cherry_black', 'cherry_blue', 'cherry_cyan', 'cherry_green', 'cherry_orange_dark',
									'cherry_orange', 'cherry_purple', 'cherry_red', 'cherry_sherbert', 'cherry_grey.png',
									'cherry_yellow']
	}
	static __Delete() => 1
	static create()
	{
		ui := Gui("+AlwaysOnTop -DPIScale -Caption -Border +LastFound ToolWindow -Resize -HScroll", "cherry v2")
		this.ui := ui
		ui.SetFont(, cfg['win_hook_font'])
		ui.BackColor := cfg['win_list_back_color']

		width := 'w' cfg['win_w']
		this.edit := ui.Add('Edit', width ' x0 y0 h40 vgui_edit -Multi -E0x200 ' , '')
		this.edit.opt('Background' cfg['win_search_box_back_color'])
		this.edit.opt('w' cfg['win_w'])
		this.edit.SetFont("c" cfg['win_search_box_text_color'])
		this.edit.SetFont('S' cfg['win_search_box_font_size'])
		DllCall("User32.dll\SendMessageW", "Ptr", this.edit.Hwnd, "Uint", (0x1500 + 1), "Ptr", True, "WStr", "🔍   欢迎使用 cherry-snippet")

		;LV0x10000 双缓冲, E0x200 控件边框, 0x2000 禁用滚动条
		LV := ui.Add("ListView",width " r5 vgui_list_view -Grid -Hdr -E0x200 -Multi +LV0x10000 -0x2000 +AutoSize ", [""])
		this.list_view := LV

		LV.opt('Background' cfg['win_list_back_color'])
		LV.SetFont("c" cfg['win_list_text_color'] )
		LV.SetFont('S' cfg['win_list_font_size'])

		CLV := LV_Colors(LV)
		;CLV.SelectionColors(cfg['win_list_focus_back_color'], cfg['win_list_focus_text_color'] )
		CLV.SelectionColors(cfg['win_list_focus_back_color'], 0x000000)

		ListViewExtensions_Add(LV)
		;设置背景图片和select高亮有冲突
		;已提交issue, https://www.autohotkey.com/boards/viewtopic.php?f=83&t=93922
		;LV.SetBkImage('G:\我的AHK程序\我的工程\cherry-snippet\cherry-snippet-v2\icons\龙.png', 70)

		image_list := IL_Create(10)
		LV.SetImageList(image_list)

		for k,v in this.cherry_icon_list
			IL_Add(image_list, A_ScriptDir '\icons\' v '.png')

		this.add_tray_icon()
		this.create_event()
	}
	static add_tray_icon()
	{
		this.tray_menue := A_TrayMenu
		this.tray_menue.Delete()
		TraySetIcon(A_ScriptDir '\icons\main.ico')
        this.tray_menue.Add("搜索`t", (*) => this.show())
        this.tray_menue.Add("编辑`t(&E)", (*) => run("*RunAs " cfg['cherry_tree_path'] " " cfg['db_path']))
        this.tray_menue.Add("设置`t(&S)", (*) => run(A_ScriptDir "\tool\set-v2\setv2.exe"))
        this.tray_menue.Add("帮助`t(&H)", (*) => run(A_ScriptDir "\README.html"))
        this.tray_menue.Add()
        this.tray_menue.Add("重启`t(&R)", (*) => Reload())
        this.tray_menue.Add("暂停`t(&P)", (*) => (Suspend(), this.tray_menue.ToggleCheck("暂停`t(&P)")))
        this.tray_menue.Add("退出`t(&X)", (*) => ExitApp())
        this.tray_menue.Default := "1&"

		this.tray_menue.SetIcon('搜索`t', A_ScriptDir '\icons\搜索.ico')
		this.tray_menue.SetIcon('编辑`t(&E)', A_ScriptDir '\icons\编辑.ico')
		this.tray_menue.SetIcon('设置`t(&S)', A_ScriptDir '\icons\设置.ico')
		this.tray_menue.SetIcon('帮助`t(&H)', A_ScriptDir '\icons\帮助.ico')
		this.tray_menue.SetIcon('重启`t(&R)', A_ScriptDir '\icons\重启.ico')
		this.tray_menue.SetIcon('暂停`t(&P)', A_ScriptDir '\icons\暂停.ico')
		this.tray_menue.SetIcon('退出`t(&X)', A_ScriptDir '\icons\退出.ico')
	}
	static create_event()
	{
		LV := this.list_view
		LV.OnEvent("ItemSelect", (argv*) => this.one_select_item_change(argv*))
		this.edit.OnEvent("Change", (argv*) => this.filter(argv*))    ; 文本变动事件
	}
	static filter(argv*)
	{
		edit := this.edit
		result := []
		for k,v in Tree_node_data.node_data
		{
			if(edit.Value == '')
				break
			if(local_match(StrSplit(edit.Value, ' '), v))
				result.Push(v)
		}
        this.list_view.Opt("-Redraw")
		this.list_view.Delete()
		for k,v in result
		{
			icon_index := Mod(A_Index, 10) + 1
			this.list_view.Add("Icon" icon_index, v)
		}
		this.list_view.Modify(1, "Select Focus Vis"), this.one_select_item_change()
		this.list_view.ModifyCol(1, Number(cfg['win_w']) - 25)
        this.list_view.Opt("Redraw")
		this.show()
		local_match(filter_array, value)
		{
			loop(filter_array.Length)
			{
				str := StrUpper(value)
				filter := StrUpper(filter_array[A_Index])
				if(filter == '' || filter == ' ')
					continue
				if(!(InStr(str, filter) || 
					py.is_all_spell_init_match(str ,filter) != -1 ||
					py.is_all_spell_match(str ,filter) != -1))
					return false
			}
			return true
		}
	}
	static one_select_item_change(argv*)
	{
		r := this.list_view.GetNext(, "F")
		if(r == 0)
			return
		path := this.list_view.GetText(r)
		;preview_command := Tree_node_data.id_path[Tree_node_data.path2id[path]]['text']
		preview_command := Tree_node_data.get_text_from_id(Tree_node_data.path2id[path])
		Global_data.current_select_text := preview_command
		Global_data.current_select_node_id := Tree_node_data.path2id[path]
        x := cfg['win_x'] + cfg['win_w'] + 12
        y := cfg['win_y'] + 12
		html_file_path := cfg['html_path'] "\data.ctb_HTML\" Tree_node_data.id_path[Tree_node_data.path2id[path]]["path_file"] ".html"
		logger.info(html_file_path)
		if(cfg['is_use_html_preview'] && FileExist(html_file_path))
			g_webview.Navigate(html_file_path, x - 12, y - 12)
		else
			g_tr.RenderOnScreen(SubStr(preview_command, 1, 1000), 
								"x:" x " y:" y " color:" cfg['tooltip_back_color'], 
								"s:" cfg['tooltip_font_size'] " j:left " "c:" cfg['tooltip_text_color'])
	}
	static get_select_row_number(start_row := -1) => this.list_view.GetNext(start_row)
	static focus_before_row()
	{
		r := this.list_view.GetNext(, "F")
		if (r > 1)
			this.list_view.Modify(r - 1, "Select Focus Vis")
		else
			this.list_view.Modify(this.list_view.GetCount(), "Select Focus Vis")
		this.one_select_item_change()
	}
	static focus_next_row()
	{
		r := this.list_view.GetNext(, "F")
		if (r < this.list_view.GetCount())
			this.list_view.Modify(r + 1, "Select Focus Vis")
		else
			this.list_view.Modify(1, "Select Focus Vis")
		this.one_select_item_change()
	}
	static show(*)
	{
		this.edit.GetPos(&x, &y, &w, &h)
		this.list_view.GetPos(&x1, &y1, &w1, &h1)
		w := w > w1 ? w : w1
		this.edit.Move(,,w)
		this.list_view.Move(,h)
		this.auto_change_listview_height()
		this.edit.GetPos(&x, &y, &w, &h)
		this.list_view.GetPos(&x1, &y1, &w1, &h1)
		this.list_view.Modify(1, "Select Focus Vis")
		this.ui.Show("w" w " h" h + h1 " x" cfg['win_x'] " y" cfg['win_y'])
	}
	static hide(*) => (logger.info("hide"), this.ui.Hide(), g_tr.RenderOnScreen(''), g_tr.clear(), g_tr.FreeMemory(), g_activex.hide(), g_webview.hide())
	static auto_change_listview_height()
	{
		max_number := 15
		number := this.list_view.GetCount()
		if(number == 0)
		{
			this.list_view.Move(,,, 0)
			return
		}
		item_height := this.list_view.GetRowHeight()
		h := number > max_number ? item_height * max_number : item_height * number
		this.list_view.Move(,,, h)
	}
}