Class Input_hook
{
	current_hook_string := ''
	list_index := 1
	is_hook_mode := false
	__New() 
	{
		this.SacHook := SacHook := InputHook("E", "{Esc}")
		SacHook.OnChar := ObjBindMethod(this, 'SacChar')
		SacHook.OnKeyDown := ObjBindMethod(this, 'SacKeyDown')
		SacHook.OnEnd := ObjBindMethod(this, 'SacEnd')
		SacHook.KeyOpt("{Backspace}", "N")

		this.tt := tt := text_tab(, '+AlwaysOnTop -DPIScale -Caption -Border +LastFound ToolWindow -Resize -HScroll +E0x08000000 -SysMenu')
		tt.pTextFormat := tt.g.pdwrite.CreateTextFormat('Microsoft YaHei UI', 0, 400, 0, 5, 20, 'en-us')
		tt.pTextFormat.SetTextAlignment(0)
		tt.pTextFormat.SetParagraphAlignment(0)
		this.tab_value := tab_value := []
		this.real_show_list := []
		this.update()
	}
	is_current_hook_mode(argv*)
	{
		return this.is_hook_mode
	}
	on_tab(flag := '+', *)
	{
		if(flag == '+')
		{
			this.list_index++
			if(this.list_index > this.tab_value.Length)
				this.list_index := 1
		}
		else
		{
			this.list_index--
			if(this.list_index < 1)
				this.list_index := this.tab_value.Length
		}
		this.hook_mode_quck_search()
	}
	start(argv*)
	{
		this.clear_value()
		this.SacHook.Start()
		this.is_hook_mode := true
		this.tt.show()
		this.update()
	}
	clear_value()
	{
		this.current_hook_string := ''
		this.list_index := 1
		this.real_show_list := []
		this.tab_value := []
	}
	stop()
	{
		this.clear_value()
		this.SacHook.Stop()
		this.is_hook_mode := false
		this.update()
		this.tt.hide()
		g_hook_rendor.RenderOnScreen('')
		g_webview.hide()
	}
	SacChar(ih, char)
	{
		logger.info(char)
		if(GetKeyVK(char) == 13)
		{
			logger.info("send")
			send_command()
			this.stop()
			return
		}
		if(char != A_tab)
			this.current_hook_string .= char
		logger.info(this.current_hook_string)
		if(GetKeyVK(char) != 9) ;tab
		{
			this.list_index := 1
			this.hook_mode_quck_search()
		}
	}
	hook_mode_quck_search()
	{
		this.tab_value := []
		for k,v in Tree_node_data.node_data
		{
			if(this.current_hook_string == '')
				break
			if(local_match(StrSplit(this.current_hook_string, ' '), v))
				this.tab_value.Push(v)
		}
		midle_show_number := cfg['win_hook_total_show_number'] / 2
		start_index := 1
		if(this.list_index > midle_show_number)
			start_index := ceil(this.list_index - midle_show_number)

		this.real_show_list := []
		loop(cfg['win_hook_total_show_number'])
		{
			if(start_index + A_index - 1 > this.tab_value.Length)
				break
			this.real_show_list.Push(this.tab_value[start_index + A_index - 1])
		}

		this.update(,, this.list_index - start_index + 1)
		if(this.tab_value.Length == 0)
		{
			g_hook_rendor.RenderOnScreen('')
			g_webview.hide()
			return
		}
		;preview_command := Tree_node_data.id_path[Tree_node_data.path2id[this.tab_value[this.list_index]]]['text']
		preview_command := Tree_node_data.get_text_from_id(Tree_node_data.path2id[this.tab_value[this.list_index]])
		html_file_path := cfg['html_path'] "\data.ctb_HTML\" Tree_node_data.id_path[Tree_node_data.path2id[this.tab_value[this.list_index]]]["path_file"] ".html"

		Global_data.current_select_text := preview_command
		Global_data.current_select_node_id := Tree_node_data.path2id[this.tab_value[this.list_index]]

		if(cfg['is_use_html_preview'] && FileExist(html_file_path))
			g_webview.Navigate(html_file_path, this.tt.right, this.tt.top)
		else
			g_hook_rendor.RenderOnScreen(SubStr(preview_command, 1, 1000), 
								"x:" this.tt.right " y:" this.tt.top " color:" cfg['tooltip_back_color'], 
								"s:" cfg['tooltip_font_size'] " j:left " "c:" cfg['tooltip_text_color'])

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
	update(show_string := this.current_hook_string, show_list := this.real_show_list, high_light_index := this.list_index)
	{
		if(!(hwnd := GetCaretPosEx(&x, &y, &w, &h)))
		{
			MouseGetPos(&x, &y)
		}
		if(show_string == '')
			show_string := '⌨' 
		try
		{
			this.tt.update(show_string, x, y, show_list, high_light_index)
		}
	}
	SacKeyDown(ih, vk, sc)
	{
		if (vk == 8) ; 退格键
			this.current_hook_string := SubStr(this.current_hook_string, 1 , -1)
		logger.info(this.current_hook_string)
		this.SacChar(ih, "")
	}
	SacEnd(argv*)
	{
		this.stop()
		logger.info(this.current_hook_string)
	}
}
class text_tab
{
	tab_list := []
	input_text := ''
	input_text_color := { R: 0.788, G: 0.894, B: 0.494, A: 1 }
	splite_line_color := {R: 0.400, G: 0.239, B: 0.710, A: 1 }
	list_text_color := { R: 0.933, G: 0.925, B: 0.886, A: 1 }
	list_high_light_text_color := { R: 0.027, G: 0.047, B: 0.051, A: 1 }
	list_high_light_back_color := { R: 0.788, G: 0.894, B: 0.494, A: 1 }
	back_color := { R: 0.267, G: 0.267, B: 0.267, A: 0.8 }
	font_size := 37
	img := ''
	left := right := top := Bottom := 0
	__New(dragon_pic_path := A_ScriptDir '\icons\索隆.png', argv*) 
	{
		this.g := g := DirectGUI(argv*)
		this.pTextFormat := pTextFormat := g.pdwrite.CreateTextFormat('Microsoft YaHei UI', 0, 400, 0, 5, this.font_size, 'en-us')
		pTextFormat.SetTextAlignment(0)
		pTextFormat.SetParagraphAlignment(0)
		this.pBrush_back := g.render.CreateSolidColorBrush(direct2d_struct('D2D1_COLOR_F', , this.back_color))
		this.pBrush_input_text_color := g.render.CreateSolidColorBrush(direct2d_struct('D2D1_COLOR_F', , this.input_text_color))
		this.pBrush_splite_line_color := g.render.CreateSolidColorBrush(direct2d_struct('D2D1_COLOR_F', , this.splite_line_color))
		this.pBrush_list_text_color := g.render.CreateSolidColorBrush(direct2d_struct('D2D1_COLOR_F', , this.list_text_color))
		this.pBrush_high_light_back_color := g.render.CreateSolidColorBrush(direct2d_struct('D2D1_COLOR_F', , this.list_high_light_back_color))
		this.pBrush_high_light_list_text_color := g.render.CreateSolidColorBrush(direct2d_struct('D2D1_COLOR_F', , this.list_high_light_text_color))

		;this.dx := dx := wincapture.DXGI(ao)
		wincapture.init()
		ccc := unset
		if(FileExist(dragon_pic_path))
		{
			this.ccc := ccc := BitmapBuffer.loadPicture(dragon_pic_path)
			props := direct2d_struct('D2D1_BITMAP_PROPERTIES', , { pixelFormat: { format: 87, alphaMode: 1 }, dpiX: 144, dpiY: 144 })
			this.img := g.render.CreateBitmap(size := direct2d_struct('D2D1_SIZE_U', , { width: ccc.width, height: ccc.height}),
														ccc.ptr, ccc.pitch, props)
		}
		this.g.Show()
		this.g.hide()
	}
	hide() => this.g.hide()
	show(argv*) => this.g.Show(argv*)
	update(s, x, y, tab_list := [], high_light_index := 1)
	{
		g := this.g
		g.render.BeginDraw()
		g.render.Clear()

		
		monitorinfo := {}
		If (MonInfo := MDMF_GetInfo(MDMF_FromPoint(&x, &y)))
		{
			monitorinfo.left := MonInfo.left ,monitorinfo.top := MonInfo.top
			monitorinfo.right := MonInfo.right, monitorinfo.Bottom := MonInfo.Bottom
			monitorinfo.width := monitorinfo.right - monitorinfo.left, monitorinfo.height := monitorinfo.Bottom - monitorinfo.top
		}
		else
		{
			monitorinfo.left := 0, monitorinfo.top := 0
			monitorinfo.right := A_ScreenWidth, monitorinfo.Bottom := A_ScreenHeight
			monitorinfo.width := A_ScreenWidth, monitorinfo.height := A_ScreenHeight
		}
		t := g.pdwrite.CreateTextLayout(s, this.pTextFormat, monitorinfo.width, monitorinfo.height)
		;inputtext 的大小，width 和 height
		m := t.GetMetrics()

		;测量list
		;每行间隔 5
		list_one := [], tab_list_max_width := m["width"], tab_list_max_height := m['height']
		list_total_height := 0
		for k, v in tab_list
		{
			list_one.Push({})
			list_one[A_Index].text_layout := g.pdwrite.CreateTextLayout(v, this.pTextFormat, A_ScreenWidth, A_ScreenHeight)
			list_one[A_Index].text_layout_m := list_one[A_Index].text_layout.GetMetrics()
			tab_list_max_height := list_one[A_Index].text_layout_m['height'] > tab_list_max_height ? list_one[A_Index].text_layout_m['height'] : tab_list_max_height 
			tab_list_max_width := list_one[A_Index].text_layout_m['width'] > tab_list_max_width ? list_one[A_Index].text_layout_m['width'] : tab_list_max_width 
			list_total_height += list_one[A_Index].text_layout_m['height']
		}

		;背景边框的大小
		rectangle_range := { left: 0, top: 0, right: 500, Bottom: 600 }
		rectangle_range.left := x - 10
		rectangle_range.top :=  y - 10
		rectangle_range.right := x + tab_list_max_width + 10
		rectangle_range.Bottom := y + m["height"] + list_total_height + 5 * tab_list.Length + 20

		;计算宽度和高度
		;计算右边和底部超出的offset， monitro.right - rectangle.right 
		;if offset < 0, x = x + offset, 
		;if x < monitor.x , x := monitro.x

		rectangle_range.width := rectangle_range.right - rectangle_range.left
		rectangle_range.height := rectangle_range.Bottom - rectangle_range.top
		offset := {}
		offset.x := monitorinfo.right - rectangle_range.right
		offset.y := monitorinfo.Bottom - rectangle_range.Bottom
		if(offset.x < 0)
		{
			rectangle_range.left += offset.x
			if(rectangle_range.left < monitorinfo.left)
				rectangle_range.left := monitorinfo.left
			rectangle_range.right := rectangle_range.left + rectangle_range.width
		}
		if(offset.y < 0)
		{
			rectangle_range.top += offset.y
			if(rectangle_range.top < monitorinfo.top)
				rectangle_range.top := monitorinfo.top
			rectangle_range.Bottom := rectangle_range.top + rectangle_range.height
		}
		x := rectangle_range.left + 10, y := rectangle_range.top + 10
		this.left := rectangle_range.left, this.right := rectangle_range.right
		this.top := rectangle_range.top, this.Bottom := rectangle_range.Bottom

		if(this.img != '')
		{
			dragon_size := {}
			dragon_size.scale_w_h := this.ccc.width / this.ccc.height
			dragon_rectangle_range := rectangle_range.Clone()

			dragon_size.height := rectangle_range.Bottom - rectangle_range.top
			dragon_size.width := dragon_size.height * dragon_size.scale_w_h 
			if(dragon_size.width > rectangle_range.right - rectangle_range.left)
			{
				dragon_size.width := rectangle_range.right - rectangle_range.left
				dragon_size.height := dragon_size.width / dragon_size.scale_w_h
			}
			dragon_rectangle_range.Bottom := dragon_rectangle_range.top + dragon_size.height
			dragon_rectangle_range.right := dragon_rectangle_range.left + dragon_size.width
			g.render.DrawBitmap(this.img, direct2d_struct('D2D1_RECT_F', , dragon_rectangle_range))
		}
		g.render.FillRoundedRectangle(direct2d_struct('D2D1_ROUNDED_RECT', , {rect : rectangle_range, radiusX : 10, radiusY : 10}), this.pBrush_back)
		g.render.DrawTextLayout(direct2d_struct('D2D1_POINT_2F', ,{ x : x, y : y}), t, this.pBrush_input_text_color)
		g.render.DrawLine(direct2d_struct('D2D1_POINT_2F', ,{ x : x, y : y + m['height'] + 10}), 
							direct2d_struct('D2D1_POINT_2F', ,{ x : this.right - 10, y : y + m['height'] + 10}),
							this.pBrush_splite_line_color, 5, 0)



		;draw list
		x := x, y := y + m['height'] + 10 + 10
		for k,v in list_one
		{
			if(k == high_light_index)
			{
				;画框
				high_light_list_rectangle_range := { left: 0, top: 0, right: 0, Bottom: 0 }
				high_light_list_rectangle_range.left := x
				high_light_list_rectangle_range.top :=  y
				high_light_list_rectangle_range.right := x + tab_list_max_width
				high_light_list_rectangle_range.Bottom := y + v.text_layout_m["height"]
				g.render.FillRoundedRectangle(direct2d_struct('D2D1_ROUNDED_RECT', , 
																{rect : high_light_list_rectangle_range, radiusX : 5, radiusY : 5}), 
																this.pBrush_high_light_back_color)
				g.render.DrawTextLayout(direct2d_struct('D2D1_POINT_2F', ,{ x : x, y : y}), v.text_layout, this.pBrush_high_light_list_text_color)
			}
			else
				g.render.DrawTextLayout(direct2d_struct('D2D1_POINT_2F', ,{ x : x, y : y}), v.text_layout, this.pBrush_list_text_color)
			x := x, y := y + v.text_layout_m['height'] + 5
		}

		g.render.EndDraw()
		g.update()
	}
}

class DirectGUI extends Gui {
	pd2d1 := ID2D1Factory(), pdwrite := IDWriteFactory()
	/** @type {ID2D1DCRenderTarget} */
	render := 0

	__New(Options := '', Title := A_ScriptName, maxwidth := A_ScreenWidth, maxheight := A_ScreenHeight) {
		super.__New('+E0x80000 ' Options, Title || A_ScriptName)
		this.render := this.pd2d1.CreateDCRenderTarget(direct2d_struct('D2D1_RENDER_TARGET_PROPERTIES', , { format: 87, alphamode: 1 }))
		this.render.BindDC(this.hdc := DllCall('CreateCompatibleDC', 'ptr', 0, 'ptr'),
			direct2d_struct('D2D1_RECT_U', , { right: maxwidth, bottom: maxheight }))
		NumPut('uint', 40, 'uint', maxwidth, 'uint', maxheight, 'ushort', 1, 'ushort', 32, 'uint', 0, BITMAPINFO := Buffer(40))
		this.hbm := DllCall('CreateDIBSection', 'ptr', this.hdc, 'ptr', BITMAPINFO, 'uint', 0, 'ptr*', &ppvBits := 0, 'ptr', 0, 'uint', 0, 'ptr')
		this.odm := DllCall('SelectObject', 'ptr', this.hdc, 'ptr', this.hbm, 'ptr')
	}
	__Delete() {
		this.render := this.pd2d1 := this.pdwrite := 0
		DllCall('SelectObject', 'ptr', this.hdc, 'ptr', this.odm, 'ptr')
		DllCall('DeleteObject', 'ptr', this.hbm)
		DllCall('DeleteDC', 'ptr', this.hdc)
	}
	show(x?, y?, w := A_ScreenWidth, h := A_ScreenHeight, alpha := 255, options := 'NA') {
		super.Show('w' w ' h' h ' ' options ' NoActivate')
		this.update(this.x := x ?? (A_ScreenWidth - w) >> 1, this.y := y ?? (A_ScreenHeight - h) >> 1,
			this.w := w, this.h := h, this.alpha := alpha)
	}
	update(x?, y?, w?, h?, alpha?) => DllCall('UpdateLayeredWindow', 'ptr', this.Hwnd, 'ptr', 0, 'int64*', (x ?? this.x) | (y ?? this.y) << 32, 'int64*', (w ?? this.w) | (h ?? this.h) << 32, 'ptr', this.hdc, 'int64*', 0, 'uint', 0, 'uint*', (alpha ?? this.alpha) << 16 | 1 << 24, 'uint', 2)
}

/*
f1::{
    CoordMode("ToolTip", "Screen")
    if hwnd := GetCaretPosEx(&x, &y, &w, &h)
        ToolTip(WinGetClass(hwnd), x, y + h)
    else
        ToolTip()
}
*/
GetCaretPosEx(&x?, &y?, &w?, &h?) {
    x := h := w := h := 0
    static iUIAutomation := 0, hOleacc := 0, IID_IAccessible, guiThreadInfo, _ := init()
    if !iUIAutomation || ComCall(8, iUIAutomation, "ptr*", eleFocus := ComValue(13, 0), "int") || !eleFocus.Ptr
        goto useAccLocation
    if !ComCall(16, eleFocus, "int", 10002, "ptr*", valuePattern := ComValue(13, 0), "int") && valuePattern.Ptr
        if !ComCall(5, valuePattern, "int*", &isReadOnly := 0) && isReadOnly
            return 0
    useAccLocation:
    ; use IAccessible::accLocation
    hwndFocus := DllCall("GetGUIThreadInfo", "uint", DllCall("GetWindowThreadProcessId", "ptr", WinExist("A"), "ptr", 0, "uint"), "ptr", guiThreadInfo) && NumGet(guiThreadInfo, A_PtrSize == 8 ? 16 : 12, "ptr") || WinExist()
    if hOleacc && !DllCall("Oleacc\AccessibleObjectFromWindow", "ptr", hwndFocus, "uint", 0xFFFFFFF8, "ptr", IID_IAccessible, "ptr*", accCaret := ComValue(13, 0), "int") && accCaret.Ptr {
        NumPut("ushort", 3, varChild := Buffer(24, 0))
        if !ComCall(22, accCaret, "int*", &x := 0, "int*", &y := 0, "int*", &w := 0, "int*", &h := 0, "ptr", varChild, "int")
            return hwndFocus
    }
    if iUIAutomation && eleFocus {
        ; use IUIAutomationTextPattern2::GetCaretRange
        if ComCall(16, eleFocus, "int", 10024, "ptr*", textPattern2 := ComValue(13, 0), "int") || !textPattern2.Ptr
            goto useGetSelection
        if ComCall(10, textPattern2, "int*", &isActive := 0, "ptr*", caretTextRange := ComValue(13, 0), "int") || !caretTextRange.Ptr || !isActive
            goto useGetSelection
        if !ComCall(10, caretTextRange, "ptr*", &rects := 0, "int") && rects && (rects := ComValue(0x2005, rects, 1)).MaxIndex() >= 3 {
            x := rects[0], y := rects[1], w := rects[2], h := rects[3]
            return hwndFocus
        }
        useGetSelection:
        ; use IUIAutomationTextPattern::GetSelection
        if textPattern2.Ptr
            textPattern := textPattern2
        else if ComCall(16, eleFocus, "int", 10014, "ptr*", textPattern := ComValue(13, 0), "int") || !textPattern.Ptr
            goto useGUITHREADINFO
        if ComCall(5, textPattern, "ptr*", selectionRangeArray := ComValue(13, 0), "int") || !selectionRangeArray.Ptr
            goto useGUITHREADINFO
        if ComCall(3, selectionRangeArray, "int*", &length := 0, "int") || length <= 0
            goto useGUITHREADINFO
        if ComCall(4, selectionRangeArray, "int", 0, "ptr*", selectionRange := ComValue(13, 0), "int") || !selectionRange.Ptr
            goto useGUITHREADINFO
        if ComCall(10, selectionRange, "ptr*", &rects := 0, "int") || !rects
            goto useGUITHREADINFO
        rects := ComValue(0x2005, rects, 1)
        if rects.MaxIndex() < 3 {
            if ComCall(6, selectionRange, "int", 0, "int") || ComCall(10, selectionRange, "ptr*", &rects := 0, "int") || !rects
                goto useGUITHREADINFO
            rects := ComValue(0x2005, rects, 1)
            if rects.MaxIndex() < 3
                goto useGUITHREADINFO
        }
        x := rects[0], y := rects[1], w := rects[2], h := rects[3]
        return hwndFocus
    }
    useGUITHREADINFO:
    if hwndCaret := NumGet(guiThreadInfo, A_PtrSize == 8 ? 48 : 28, "ptr") {
        if DllCall("GetWindowRect", "ptr", hwndCaret, "ptr", clientRect := Buffer(16)) {
            w := NumGet(guiThreadInfo, 64, "int") - NumGet(guiThreadInfo, 56, "int")
            h := NumGet(guiThreadInfo, 68, "int") - NumGet(guiThreadInfo, 60, "int")
            DllCall("ClientToScreen", "ptr", hwndCaret, "ptr", guiThreadInfo.Ptr + 56)
            x := NumGet(guiThreadInfo, 56, "int")
            y := NumGet(guiThreadInfo, 60, "int")
            return hwndCaret
        }
    }
    return 0
    static init() {
        try
            iUIAutomation := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
        hOleacc := DllCall("LoadLibraryW", "str", "Oleacc.dll", "ptr")
        NumPut("int64", 0x11CF3C3D618736E0, "int64", 0x719B3800AA000C81, IID_IAccessible := Buffer(16))
        guiThreadInfo := Buffer(A_PtrSize == 8 ? 72 : 48), NumPut("uint", guiThreadInfo.Size, guiThreadInfo)
    }
}