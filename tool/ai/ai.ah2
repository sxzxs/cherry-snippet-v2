#SingleInstance Force
#include <log>
#include <ComVar>
#include <WebView2>
#include <zmq>
#include ../../utility/Config.ah2
#include ../../utility/Utility.ah2

instance_once() ;清理重复进程
;检查是否有重复进程运行
if(Single_instance.create('ai-ah2'))
{
    MsgBox('提示,程序已启动!`n请勿重复运行')
    ExitApp
}

g := Gui('+AlwaysOnTop -DPIScale +Caption +Border +LastFound -ToolWindow -Resize -HScroll','AI')
g.Show(Format("x-5000 y-5000 w{} h{}", A_ScreenWidth * 0.6, A_ScreenHeight * 0.6))
wv := WebView2.create(g.Hwnd)
wv.CoreWebView2.Navigate("https://chat.theb.ai/")

CoordMode('ToolTip', 'Screen')

obj_cfg := Config(A_ScriptDir "/../../config/plug_cal.json")
main_obj_cfg := Config(A_ScriptDir "/../../config/settings.json")
cfg := obj_cfg.config
main_cfg := main_obj_cfg.config
g_tt_hwnd := 0

TT_CAL_RESULT := 1

if(!cfg['is_open'])
    ExitApp

;设置log模式
logger.is_log_open := cfg['is_log_open']
logger.is_out_file := cfg['is_out_file']
logger.is_use_editor := cfg['is_use_editor']
logger.info('plug cal...')
logger.info(A_Args)

ctx := zmq_ctx_new()
socket := zmq_socket(ctx, ZMQ_SUB)
rtn := zmq_connect(socket, "tcp://localhost:29935")
rtn := zmq_setsockopt(socket, ZMQ_SUBSCRIBE, buf := StrBuf(''), buf.Size - 1)

OnExit(exit)
SetTimer(exe_command , 50)

;注册热键
Hotkey("~esc", (key) => (g.Hide()))
return

exit(*)
{
    zmq_close(socket)
    zmq_ctx_shutdown(ctx)
	Single_instance.close()
}
exe_command(*)
{
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
    x := main_cfg['win_x']
    y := main_cfg['win_y'] + main_cfg['win_search_box_height']
    if(RegExMatch(recv_str, 'i)\/ai\s*(.*)', &SubPat))
    {
        static is_first_show := true
        if(is_first_show)
        {
            g.Show(Format("x0 y0 w{} h{}", A_ScreenWidth * 0.6, A_ScreenHeight * 0.6))
            is_first_show := false
        }
        else
        {
            g.Show(Format("w{} h{}", A_ScreenWidth * 0.6, A_ScreenHeight * 0.6))
        }
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
