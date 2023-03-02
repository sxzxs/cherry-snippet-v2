;plug_cal.ah2
#include <log>
#include <zmq>
#include <NTLCalc>
#include ./utility/Config.ah2

CoordMode('ToolTip', 'Screen')

obj_cfg := Config(A_ScriptDir "/config/plug_cal.json")
main_obj_cfg := Config(A_ScriptDir "/config/settings.json")
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

ctx := A_Args[1]
socket := zmq_socket(ctx, ZMQ_SUB)
rtn := zmq_connect(socket, "inproc://main")
rtn := zmq_setsockopt(socket, ZMQ_SUBSCRIBE, buf := StrBuf(''), buf.Size - 1)

OnExit(exit)
SetTimer(exe_command , 50)
return

exit(*)
{
    zmq_close(socket)
    zmq_ctx_shutdown(ctx)
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
            logger.err(e.Message)
            return
        }
        g_tt_hwnd := ToolTip(SubPat[1] '`n = ' rtn, x, y, TT_CAL_RESULT)
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