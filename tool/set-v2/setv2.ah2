#include <imgui>
#include <log>
_ImGui_EnableViewports(true)

g_config_path := A_ScriptDir "\..\..\config\settings.json"
g_config := {}
loadconfig(&g_config, g_config_path)

logger.is_log_open := false
logger.info(g_config)
gif_tim := 0
gif_tim_shandian := 0
g_is_shandian := false
main()
main()
{
    static no_menu := false
    global gif_tim
    global g_is_shandian
    global gif_tim_shandian
    hwnd := _ImGui_GUICreate("AHK ImGui", 1, 1, -100, -100, 0, 0x80)
    WinShow(hwnd)
    WinSetAlwaysOnTop( 1,hwnd)
    WinHide(hwnd)

    style := _ImGui_GetStyle()
    set_style(style)

    io := _ImGui_GetIO()
    _ImGui_SetWindowTitleAlign(0.5, 0.5)
    _ImGui_EnableDocking(True)
    static window_flags := 0
    static back_img_id := _ImGui_ImageFromFile(A_ScriptDir "\..\..\Icons\龙.png")
    static help_img_id := _ImGui_ImageFromFile(A_ScriptDir "\..\..\Icons\帮助.png")
    static set_img_id := _ImGui_ImageFromFile(A_ScriptDir "\..\..\Icons\设置.png")
    _Imgui_imgui_stbi__load_gif(A_ScriptDir "\..\..\Icons\gg.gif", &out_srv_array := [], &length := 0, &out_gif_with := 0, &out_gif_height := 0, &out_gif_delay := 0)
    _Imgui_imgui_stbi__load_gif(A_ScriptDir "\..\..\Icons\闪电五连鞭.gif", &out_srv_array_shandian := [], &length_shandian := 0, &out_gif_with_shandian := 0, &out_gif_height_shandian := 0, &out_gif_delay_shandian := 0)
    if(out_gif_delay == 0) 
        out_gif_delay := 200
    if(out_gif_delay_shandian == 0) 
        out_gif_delay_shandian := 200
    gif_tim := Gif_timmer(length, out_gif_delay)
    gif_tim.Start()

    gif_tim_shandian := Gif_timmer(length_shandian, out_gif_delay_shandian)
    OnExit(exit_handle)
    static colum_index := 1
    while(_ImGui_PeekMsg())
    {
        _ImGui_BeginFrame()
        if(!_ImGui_Begin("设置", show_close := true, window_flags | ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoCollapse))
            ExitApp
        ;if(!_ImGui_Begin("设置", show_close := true, window_flags | ImGuiWindowFlags_NoCollapse))

        _ImGui_Columns(2)
        _ImGui_SetColumnOffset(1, 100)
        _ImGui_PushID(0)
        if(_ImGui_ImageButton(set_img_id, 80, 80))
            colum_index := 1
        _ImGui_PopID()
        _ImGui_PushID(1)
        if(_ImGui_ImageButton(help_img_id, 80, 80))
        {
            colum_index := 1
        }
        _ImGui_PopID()
        ;_ImGui_SetCursorPosY(_ImGui_GetWindowSize()[2] - 30)
        _ImGui_SetCursorPosY(500)
        _ImGui_Text("snippet",)
        _ImGui_NextColumn()
        if(colum_index == 1)
        {
            window_draw_list := _ImGui_GetWindowDrawList()
            window_foreground_draw_list := _ImGui_GetForegroundDrawList()

            p := _ImGui_GetWindowPos()
            s := _ImGui_GetWindowSize()
            mx := p[1] + s[1] / 2
            my := p[2] + s[2] / 2
            short := s[1] > s[2] ? s[2] : s[1]
            if(!g_is_shandian)
            {
                _ImDraw_SetDrawList(window_draw_list)
                _ImDraw_AddImage(out_srv_array[gif_tim.count], mx - short / 2, my - short / 2, mx + short / 2, my + short / 2)
            }
            else
            {
                _ImDraw_SetDrawList(window_foreground_draw_list)
                _ImDraw_AddImage(out_srv_array_shandian[gif_tim_shandian.count], mx - short / 2, my - short / 2, mx + short / 2, my + short / 2)
            }

            ;添加代码 =====================================

            static tab_bar_flags := ImGuiTabBarFlags_None

            ;快捷键
            static key_open_search_box := g_config["key_open_search_box"]
            static key_send := g_config["key_send"]
            static key_edit_now := g_config["key_edit_now"]
            static key_edit_new := g_config["key_edit_new"]
            static key_open_editor := g_config["key_open_editor"]
            static hook_open := g_config["hook_open"]
			static key_quick_switch_node := g_config['key_quick_switch_node']
			static is_open_search_box_double_press := g_config['is_open_search_box_double_press']
			static is_hook_open_double_press := g_config['is_hook_open_double_press']
            ;searchbox
            static win_w := g_config["win_w"]
            static win_search_box_back_color := _Imgui_bgr2rgb(Integer(g_config["win_search_box_back_color"]))
            static win_search_box_text_color := _Imgui_bgr2rgb(Integer(g_config["win_search_box_text_color"]))

            static win_search_box_font_size := g_config["win_search_box_font_size"]
            ;list
            static win_list_back_color := _Imgui_bgr2rgb(Integer(g_config["win_list_back_color"]))

            static win_list_text_color := _Imgui_bgr2rgb(Integer(g_config["win_list_text_color"]))

            static win_list_focus_back_color := _Imgui_bgr2rgb(Integer(g_config["win_list_focus_back_color"]))
            static win_list_focus_text_color := _Imgui_bgr2rgb(Integer(g_config["win_list_focus_text_color"]))

            static win_list_font_size := g_config["win_list_font_size"]
            static win_list_height := g_config["win_list_height"]
            ;preview
            static tooltip_back_color := _Imgui_bgr2rgb(Integer(g_config["tooltip_back_color"]))
            static tooltip_text_color := _Imgui_bgr2rgb(Integer(g_config["tooltip_text_color"]))
            static tooltip_font_size := g_config["tooltip_font_size"]
            static tooltip_random := g_config["tooltip_random"]
			static is_use_html_preview := g_config["is_use_html_preview"]
            static html_path := g_config["html_path"]
            ;other
            static auto_english := g_config["auto_english"]
            static tooltip_help := g_config["tooltip_help"]
            static python_path := g_config["python_path"]
            static is_show_logo := g_config["is_show_logo"]
            static is_use_xiaohe_double_pinyin := g_config["is_use_xiaohe_double_pinyin"]
            static is_use_86wubi := g_config["is_use_86wubi"]
            static cherry_tree_path := g_config["cherry_tree_path"]
            static db_path := g_config["db_path"]
            static win_trans := g_config["win_trans"]
            ;hook_window
            static win_hook_font := g_config["win_hook_font"]
            static win_hook_backgroundcolor := _Imgui_bgr2rgb(Integer("0x" g_config["win_hook_backgroundcolor"]))
            static win_hook_textcolor := _Imgui_bgr2rgb(Integer("0x" g_config["win_hook_textcolor"]))
            static win_hook_codecolor := _Imgui_bgr2rgb(Integer("0x" g_config["win_hook_codecolor"]))
            static win_hook_bordercolor := _Imgui_bgr2rgb(Integer("0x" g_config["win_hook_bordercolor"]))
            static win_hook_focusbackcolor := _Imgui_bgr2rgb(Integer("0x" g_config["win_hook_focusbackcolor"]))
            static win_hook_focuscolor := _Imgui_bgr2rgb(Integer("0x" g_config["win_hook_focuscolor"]))
            static win_hook_fontsize := g_config["win_hook_fontsize"] 
            static win_hook_fontbold := g_config["win_hook_fontbold"]  
            static win_hook_total_show_number := g_config["win_hook_total_show_number"]  

            _ImGui_PushStyleColor(ImGuiCol_TabActive, "0xffe5b83d")
            if(_ImGui_BeginTabBar("mytabbar", tab_bar_flags))
            {
                if(_ImGui_BeginTabItem("搜索框设置"))
                {
                    _ImGui_PushItemWidth(400)
                    _ImGui_ColorEdit("搜索框背景颜色##win_search_box_back_color", &win_search_box_back_color, ImGuiColorEditFlags_AlphaBar | ImGuiColorEditFlags_None)

                    _ImGui_PushItemWidth(400)
                    _ImGui_ColorEdit("搜索框字体颜色##win_search_box_text_color", &win_search_box_text_color, ImGuiColorEditFlags_AlphaBar | ImGuiColorEditFlags_None)

                    _ImGui_InputText("搜索框宽度##win_w", &win_w)
                    _ImGui_InputText("搜索框字体大小##win_search_box_font_size", &win_search_box_font_size)
                    _ImGui_EndTabItem()
                }

                if(_ImGui_BeginTabItem("下拉列表设置"))
                {
                    _ImGui_PushItemWidth(400)
                    _ImGui_ColorEdit("列表背景颜色##win_list_back_color", &win_list_back_color, ImGuiColorEditFlags_AlphaBar | ImGuiColorEditFlags_None)

                    _ImGui_PushItemWidth(400)
                    _ImGui_ColorEdit("列表字体颜色##win_list_text_color", &win_list_text_color, ImGuiColorEditFlags_AlphaBar | ImGuiColorEditFlags_None)
                    _ImGui_PushItemWidth(400)
                    _ImGui_ColorEdit("列表焦点背景颜色##win_list_focus_back_color", &win_list_focus_back_color, ImGuiColorEditFlags_AlphaBar | ImGuiColorEditFlags_None)
                    _ImGui_PushItemWidth(400)
                    _ImGui_ColorEdit("列表焦点字体颜色##win_list_focus_text_color", &win_list_focus_text_color, ImGuiColorEditFlags_AlphaBar | ImGuiColorEditFlags_None)
                    _ImGui_InputText("列表字体大小##win_list_font_size", &win_list_font_size)
                    _ImGui_InputText("列表高度##win_list_height", &win_list_height)
                    _ImGui_EndTabItem()
                }
                if(_ImGui_BeginTabItem("预览设置"))
                {
                    _ImGui_PushItemWidth(400)
                    _ImGui_ColorEdit("预览背景颜色##tooltip_back_color", &tooltip_back_color, ImGuiColorEditFlags_AlphaBar | ImGuiColorEditFlags_None)
                    _ImGui_PushItemWidth(400)
                    _ImGui_ColorEdit("预览字体颜色##tooltip_text_color", &tooltip_text_color, ImGuiColorEditFlags_AlphaBar | ImGuiColorEditFlags_None)
                    _ImGui_InputText("预览字体大小##tooltip_font_size", &tooltip_font_size)
                    _ImGui_Text("预览随机颜色:")
                    _ImGui_SameLine()
                    _Imgui_toggle_button("是否预览随机颜色[0/1]##tooltip_random", &tooltip_random)
                    _ImGui_Text("使用HTML预览:")
                    _ImGui_SameLine()
                    _Imgui_toggle_button("使用HTML预览##is_use_html_preview", &is_use_html_preview)
                    _ImGui_InputText("cherryTree导出HTML路径##html_path", &html_path)

                    _ImGui_EndTabItem()
                }
                if(_ImGui_BeginTabItem("快捷键设置"))
                {
                    _ImGui_InputText("打开搜索框##open_search_box", &key_open_search_box)
                    _ImGui_InputText("发送文本##send_text", &key_send)
                    _ImGui_InputText("编辑当前指令##edit_now", &key_edit_now)
                    _ImGui_InputText("增加一条指令##add_a_command", &key_edit_new)
                    _ImGui_InputText("打开命令添加界面##open_command_page", &key_open_editor)
                    _ImGui_InputText("hook模式快捷键##hook_mode_key", &hook_open)
                    _ImGui_InputText("跳转到CherryTree的当前节点##key_quick_switch_node", &key_quick_switch_node)

                    _Imgui_toggle_button("打开搜索框需要双击##is_open_search_box_double_press", &is_open_search_box_double_press)
                    _ImGui_SameLine()
                    _ImGui_Text("打开搜索框是否双击")
                    _Imgui_toggle_button("hook模式需要双击##is_hook_open_double_press", &is_hook_open_double_press)
                    _ImGui_SameLine()
                    _ImGui_Text("打开hook编辑框是否双击")

                    _ImGui_EndTabItem()
                }
                if(_ImGui_BeginTabItem("其他"))
                {
                    _Imgui_toggle_button("是否自动切换为英文[0/1]##auto_english", &auto_english)
                    _ImGui_SameLine()
                    _ImGui_Text("自动切换为英文输入法")

                    _Imgui_toggle_button("是否提示帮助信息[0/1]##tooltip_help", &tooltip_help)
                    _ImGui_SameLine()
                    _ImGui_Text("提示帮助信息")
                    _Imgui_toggle_button("是否显示logo##is_show_logo", &is_show_logo)
                    _ImGui_SameLine()
                    _ImGui_Text("显示LOGO")

                    _Imgui_toggle_button("是否小鹤双拼##is_use_xiaohe_double_pinyin", &is_use_xiaohe_double_pinyin)
                    _ImGui_SameLine()
                    _ImGui_Text("小鹤双拼")

                    _Imgui_toggle_button("是否86五笔##is_use_86wubi", &is_use_86wubi)
                    _ImGui_SameLine()
                    _ImGui_Text("86五笔")
                    _ImGui_InputText("python解释器路径##python_path", &python_path)
                    _ImGui_InputText("cherry tree路径##cherry_tree_path", &cherry_tree_path)
            		_ImGui_PushStyleColor(ImGuiCol_Button, "0xff18A927")
					if(_ImGui_Button("选择cherrytree.exe文件路径##cherrytree文件路径"))
					{
						SelectedFile := FileSelect(3, , "Open a file", "Text Documents (*.exe)")
						if(SelectedFile != "")
						{
							cherry_tree_path := SelectedFile
						}
					}
                    _ImGui_InputText(".ctb数据文件路径##db_path", &db_path)
					if(_ImGui_Button("选择ctb文件路径##ctb文件路径"))
					{
						SelectedFile := FileSelect(3, , "Open a file", "Text Documents (*.ctb)")
						if(SelectedFile != "")
						{
							db_path := SelectedFile
						}
					}
					_ImGui_PopStyleColor()
                    _ImGui_InputText("win_trans##win_trans", &win_trans)

                    _ImGui_EndTabItem()
                }
                if(_ImGui_BeginTabItem("HOOK模式窗口"))
                {
                    _ImGui_InputText("文本字体##win_hook_font", &win_hook_font)
                    _ImGui_PushItemWidth(400)
                    _ImGui_ColorEdit("背景颜色##win_hook_backgroundcolor", &win_hook_backgroundcolor, ImGuiColorEditFlags_AlphaBar | ImGuiColorEditFlags_None)

                    _ImGui_PushItemWidth(400)
                    _ImGui_ColorEdit("文本颜色##win_hook_textcolor", &win_hook_textcolor, ImGuiColorEditFlags_AlphaBar | ImGuiColorEditFlags_None)

                    _ImGui_PushItemWidth(400)
                    _ImGui_ColorEdit("编码颜色##win_hook_codecolor", &win_hook_codecolor, ImGuiColorEditFlags_AlphaBar | ImGuiColorEditFlags_None)

                    _ImGui_PushItemWidth(400)
                    _ImGui_ColorEdit("边框颜色##win_hook_bordercolor", &win_hook_bordercolor, ImGuiColorEditFlags_AlphaBar | ImGuiColorEditFlags_None)

                    _ImGui_PushItemWidth(400)
                    _ImGui_ColorEdit("焦点背景##win_hook_focusbackcolor", &win_hook_focusbackcolor, ImGuiColorEditFlags_AlphaBar | ImGuiColorEditFlags_None)

                    _ImGui_PushItemWidth(400)
                    _ImGui_ColorEdit("焦点文本##win_hook_focuscolor", &win_hook_focuscolor, ImGuiColorEditFlags_AlphaBar | ImGuiColorEditFlags_None)

                    _ImGui_InputText("字体大小##win_hook_fontsize", &win_hook_fontsize)
                    _ImGui_InputText("粗体[0/1]##win_hook_fontbold", &win_hook_fontbold)
                    _ImGui_InputText("候选数目##win_hook_total_show_number", &win_hook_total_show_number)
                    _ImGui_EndTabItem()
                }

            }
            _ImGui_PushStyleColor(ImGuiCol_Button, "0xffdd18d7")
            if(_ImGui_Button("保存到配置文件##ok"))
            {
                g_config["key_open_search_box"] := key_open_search_box
                g_config["key_edit_now"] := key_edit_now
                g_config["key_edit_new"] := key_edit_new
                g_config["key_open_editor"] := key_open_editor
                g_config["hook_open"] := hook_open
                g_config["key_quick_switch_node"] := key_quick_switch_node
                g_config["win_w"] := win_w
                g_config["win_search_box_back_color"] := Format("0x{:06X}", _Imgui_bgr2rgb(win_search_box_back_color & 0xffffff))
                g_config["is_open_search_box_double_press"] := is_open_search_box_double_press
                g_config["is_hook_open_double_press"] := is_hook_open_double_press

                g_config["win_search_box_text_color"] := Format("0x{:06X}", _Imgui_bgr2rgb(win_search_box_text_color & 0xffffff))
                g_config["win_search_box_font_size"] := win_search_box_font_size
                g_config["win_list_back_color"] := Format("0x{:06X}", _Imgui_bgr2rgb(win_list_back_color & 0xffffff))
                g_config["win_list_text_color"] := Format("0x{:06X}", _Imgui_bgr2rgb(win_list_text_color & 0xffffff))
                g_config["win_list_focus_back_color"] := Format("0x{:06X}", _Imgui_bgr2rgb(win_list_focus_back_color & 0xffffff))
                g_config["win_list_focus_text_color"] := Format("0x{:06X}", _Imgui_bgr2rgb(win_list_focus_text_color & 0xffffff))
                g_config["win_list_font_size"] := win_list_font_size
                g_config["win_list_height"] := win_list_height

                g_config["tooltip_back_color"] := Format("0x{:06X}", _Imgui_bgr2rgb(tooltip_back_color & 0xffffff))
                g_config["tooltip_text_color"] := Format("0x{:06X}", _Imgui_bgr2rgb(tooltip_text_color & 0xffffff))
                g_config["tooltip_font_size"] := tooltip_font_size
                g_config["tooltip_random"] := tooltip_random
                g_config["is_use_html_preview"] := is_use_html_preview
                g_config["html_path"] := html_path

                g_config["auto_english"] := auto_english
                g_config["tooltip_help"] := tooltip_help

                g_config["python_path"] := python_path
                g_config["is_show_logo"] := is_show_logo
                g_config["is_use_xiaohe_double_pinyin"] := is_use_xiaohe_double_pinyin
                g_config["is_use_86wubi"] := is_use_86wubi
                g_config["cherry_tree_path"] := cherry_tree_path
                g_config["db_path"] := db_path

                g_config["win_trans"] := win_trans

                ;hook window
                g_config["win_hook_font"] := win_hook_font
                g_config["win_hook_backgroundcolor"] := Format("{:06X}", _Imgui_bgr2rgb(win_hook_backgroundcolor & 0xffffff))
                g_config["win_hook_textcolor"] := Format("{:06X}", _Imgui_bgr2rgb(win_hook_textcolor & 0xffffff))
                g_config["win_hook_codecolor"] := Format("{:06X}", _Imgui_bgr2rgb(win_hook_codecolor & 0xffffff))
                g_config["win_hook_bordercolor"] := Format("{:06X}", _Imgui_bgr2rgb(win_hook_bordercolor & 0xffffff))
                g_config["win_hook_focusbackcolor"] := Format("{:06X}", _Imgui_bgr2rgb(win_hook_focusbackcolor & 0xffffff))
                g_config["win_hook_focuscolor"] := Format("{:06X}", _Imgui_bgr2rgb(win_hook_focuscolor & 0xffffff))
                g_config["win_hook_fontsize"] := win_hook_fontsize
                g_config["win_hook_fontbold"] := win_hook_fontbold
                g_config["win_hook_total_show_number"] := win_hook_total_show_number


                saveconfig(g_config, g_config_path)
                g_is_shandian := false
                SetTimer(()=> g_is_shandian := false, -2000)
                gif_tim_shandian.Start()
                tooltip("请重新启动auto-command", 0, 0)
            }
            _ImGui_SameLine()
            static color_get := 0
            static b_pick_color := false

            if(b_pick_color)
            {
                _imgui_PushItemWidth(400)
                _ImGui_ColorPicker("color_pick", &color_get)
                _ImGui_PopItemWidth()
            }
            _ImGui_PopStyleColor(2)
        }
        ;====================================
        _ImGui_End()
        _ImGui_EndFrame()
        Sleep(10)
    }
    ExitApp()
    return
}


set_style(style)
{
    style.TabBorderSize := 1.0
    style.FrameBorderSize := 1.0

    style.WindowRounding := 6
    style.ChildRounding := 6
    style.FrameRounding := 6
    style.PopupRounding := 6
    style.ScrollbarRounding := 6
    style.ScrollbarRounding := 6
    style.GrabRounding := 6
    style.LogSliderDeadzone := 6
    style.TabRounding := 6

	style.Colors[ImGuiCol_TitleBg] := [14, 4, 1, 255]
	style.Colors[ImGuiCol_TitleBgActive] := [17, 5, 1, 255]
	style.Colors[ImGuiCol_TitleBgCollapsed] := [0, 0, 130, 0]


    style.Colors[ImGuiCol_Tab] := [0, 0, 0, 255]
    style.Colors[ImGuiCol_TabHovered] := [40, 213, 204, 255]
    style.Colors[ImGuiCol_TabActive] := [19, 123, 49, 255]


	style.Colors[ImGuiCol_Button] := [31, 30, 31, 255]
	style.Colors[ImGuiCol_ButtonActive] := [41, 40, 41, 255]
	style.Colors[ImGuiCol_ButtonHovered] := [41, 40, 41, 255]

	style.Colors[ImGuiCol_Separator] := [70, 70, 70, 255]
	style.Colors[ImGuiCol_SeparatorActive] := [76, 76, 76, 255]
	style.Colors[ImGuiCol_SeparatorHovered] := [76, 76, 76, 255]

	style.Colors[ImGuiCol_FrameBg] := [37, 36, 37, 255]
	style.Colors[ImGuiCol_FrameBgActive] := [37, 36, 37, 255]
	style.Colors[ImGuiCol_FrameBgHovered] := [37, 36, 37, 255]

	style.Colors[ImGuiCol_Header] := [0, 0, 0, 0]
	style.Colors[ImGuiCol_HeaderActive] := [0, 0, 0, 0]
	style.Colors[ImGuiCol_HeaderHovered] := [46, 46, 46, 255]
}

;加载配置函数
loadconfig(&config, json_path)
{
    outputvar := FileRead(json_path)
    config := JSON.parse(outputvar)
}
;保存配置函数
saveconfig(config, json_path)
{
    str := JSON.stringify(config)
    FileDelete(json_path)
    FileAppend(str, json_path, 'UTF-8')
}


exit_handle(ExitReason, ExitCode)
{
    gif_tim.Stop()
    gif_tim_shandian.stop()
}
; 一个记录秒数的示例类...
class Gif_timmer 
{
    __New(length, interval) 
    {
        this.interval := interval
        this.count := 1
        this.length := length
        ; Tick() 有一个隐式参数 "this", 其引用一个对象
        ; 所以, 我们需要创建一个封装了 "this " 和调用方法的函数:
        this.timer := ObjBindMethod(this, "Tick")
    }
    Start() 
    {
        SetTimer this.timer, this.interval
    }
    Stop() 
    {
        ; 要关闭计时器, 我们必须传递和之前一样的对象:
        SetTimer this.timer, 0
    }
    ; 本例中, 计时器调用了以下方法:
    Tick() 
    {
        this.count++
        if(this.count == this.length)
            this.count := 1
    }
}