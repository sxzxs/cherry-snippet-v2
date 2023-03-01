;plug_cal.ah2
#include <log>
#include <zmq>
#include <TextRender>
#include <NTLCalc>
#include ./utility/Config.ah2

CoordMode('ToolTip', 'Screen')

obj_cfg := Config(A_ScriptDir "/config/data2html.json")
main_obj_cfg := Config(A_ScriptDir "/config/settings.json")
cfg := obj_cfg.config
main_cfg := main_obj_cfg.config
g_tr := TextRender()
g_tt_hwnd := 0

TT_CAL_RESULT := 1

;设置log模式
logger.is_log_open := cfg['is_log_open']
logger.is_out_file := cfg['is_out_file']
logger.is_use_editor := cfg['is_use_editor']
logger.info('plug cal...')
logger.info(A_Args)

ctx := A_Args[1]
socket := zmq_socket(ctx, ZMQ_SUB)
rtn := zmq_connect(socket, "inproc://main")
rtn := zmq_setsockopt(socket, ZMQ_SUBSCRIBE, buf := StrBuf(''), buf.Size - 1)

SetTimer(exe_command , 100)
OnExit(exit)
return

exit(*)
{
    zmq_close(socket)
    zmq_ctx_shutdown(ctx)
}
exe_command(*)
{
    global g_tt_hwnd
    rtn := zmq_recv_string(socket, &recv_str := '')
    logger.info("recv str :", recv_str)
    if(recv_str == '')
    {
        try
        {
            WinHide(g_tt_hwnd)
        }
        return
    }
    x := main_cfg['win_x']
    y := main_cfg['win_y'] + main_cfg['win_search_box_height']
    if(RegExMatch(recv_str, 'i)\/cal\s*(.*)', &SubPat))
    {
        rtn := 0
        try
        {
            rtn := NTLCalc(SubPat[1])
        }
        catch as e
        {
            return
        }
        g_tt_hwnd := ToolTip(SubPat[1] '`n = ' rtn, x, y, TT_CAL_RESULT)
    }
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