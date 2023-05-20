#SingleInstance Force
#include <log>
#include <ComVar>
#include <WebView2>
#include <zmq>
#include ../../utility/Config.ah2
#include ../../utility/Utility.ah2

DetectHiddenWindows True

instance_once() ;清理重复进程
;检查是否有重复进程运行
if(Single_instance.create('ai-ah2'))
{
    MsgBox('提示,程序已启动!`n请勿重复运行')
    ExitApp
}

g := Gui('+AlwaysOnTop -DPIScale +Caption +Border +LastFound -ToolWindow +Resize -HScroll','AI')
g.Show(Format("x-5000 y-5000 w{} h{}", A_ScreenWidth * 0.6, A_ScreenHeight * 0.6))
wv := WebView2.create(g.Hwnd)


url := get_chatgpt_url('https://raw.githubusercontent.com/sxzxs/data/main/ai')
if(url == '')
{
    url := get_chatgpt_url('https://gitee.com/kazhafeizhale/data/raw/master/data/chatgpt')
}
if(url == '')
{
    url := 'https://github.com/sxzxs/cherry-snippet-v2'
}

wv.CoreWebView2.Navigate(url )

exec_sync := SyncHandler((args) => OutputDebug(StrGet(args[2])))
g.OnEvent('Size', gui_size)

CoordMode('ToolTip', 'Screen')

g_tt_hwnd := 0
g_is_first_show := true

ctx := zmq_ctx_new()
socket := zmq_socket(ctx, ZMQ_SUB)
rtn := zmq_connect(socket, "tcp://localhost:29935")
rtn := zmq_setsockopt(socket, ZMQ_SUBSCRIBE, buf := StrBuf(''), buf.Size - 1)

OnExit(exit)
SetTimer(exe_command , 50)

;注册热键
Hotkey("~esc", (key) => (active_hidden_interface()))
Hotkey("f7", (key) => (show_hide_wind(g.Hwnd)))
return

active_hidden_interface()
{
    if WinActive(g.hwnd)
        g.Hide()
}

exit(*)
{
    zmq_close(socket)
    zmq_ctx_shutdown(ctx)
	Single_instance.close()
}
exe_command(*)
{
    global g_is_first_show
	Critical 'on'
    global g_tt_hwnd
    try
    {
        rtn := zmq_recv_string(socket, &recv_str := '', ZMQ_DONTWAIT)
        if(rtn == -1)
            return
    }
    catch as e
    {
        logger.err(e.Message)
        return
    }
    if(rtn == -1)
        return
    if(recv_str == '@stop' || recv_str == '')
    {
        ToolTip('')
        return
    }
    if(recv_str == '@exit')
    {
        ExitApp
    }
    if(RegExMatch(recv_str, 'i)\/ai\s*(.*)', &SubPat))
    {
        if(g_is_first_show)
        {
            g.Show(Format("x0 y0 w{} h{}", A_ScreenWidth * 0.6, A_ScreenHeight * 0.6))
            g_is_first_show := false
        }
        else
        {
            ;g.Show(Format("w{} h{}", A_ScreenWidth * 0.6, A_ScreenHeight * 0.6))
            g.Show()
        }
        js := 'document.getElementsByClassName("n-input__textarea-el")[0].focus()'
        wv.CoreWebView2.ExecuteScript(js, myHandler(wv,arg:=0))
        ;exec_sync.wait()
    }
	Critical 'off'
}

; 返回包含字符串的缓冲对象.
StrBuf(str, encoding := 'UTF-8')
{
    ; 计算所需的大小并分配缓冲.
    buf := Buffer(StrPut(str, encoding))
    ; 复制或转换字符串.
    StrPut(str, buf, encoding)
    return buf
}

show_hide_wind(hwnd)
{
    global g_is_first_show
    try
    {
        if WinActive(hwnd)
            g.Hide()
        else
        {
            if(g_is_first_show)
            {
                g.Show(Format("x0 y0 w{} h{}", A_ScreenWidth * 0.6, A_ScreenHeight * 0.6))
                g_is_first_show := false
            }
            else
            {
                ;g.Show(Format("w{} h{}", A_ScreenWidth * 0.6, A_ScreenHeight * 0.6))
                g.Show()
            }
            js := 'document.getElementsByClassName("n-input__textarea-el")[0].focus()'
            wv.CoreWebView2.ExecuteScript(js, myHandler(wv,arg:=0))
        }
    }
}

myHandler(wv,arg)
{
    return(0)
}

gui_size(GuiObj, MinMax, Width, Height) 
{
    global wv
	if (MinMax != -1) 
        wv.Fill()
}


get_chatgpt_url(git_url)
{
    try
    {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", git_url, true)
        whr.Send()
        ; 使用 'true'(上面) 和调用下面的函数, 允许脚本保持响应.
        whr.WaitForResponse()
        version := whr.ResponseText
    }
    catch
    {
        version := ''
    }
    return version
}