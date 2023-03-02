;plug_cal.ah2
#include <log>
#include <zmq>
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
    if(RegExMatch(recv_str, 'i)\/cd \s*(.*)', &SubPat))
    {
        rtn := 0
        try
        {
            rtn := youdaocd(SubPat[1])
        }
        catch as e
        {
            logger.err(e.Message)
            return
        }
        g_tt_hwnd := ToolTip(rtn, x, y, TT_CAL_RESULT)
        A_Clipboard := rtn
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

youdaocd(text)
{
    Url := 'http://fanyi.youdao.com/translate?smartresult=dict&smartresult=rule&smartresult=ugc&sessionFrom=null'
    postdata := 'type=AUTO&i=' text '&doctype=json&xmlVersion=1.4&keyfrom=fanyi.web&ue=UTF-8&typoResult=true&flag=false'
    rtn := WinHttp(Url ,"POST", postdata)
    str := byteToStr(rtn, 'UTF-8')
    logger.info(str)
    js := JSON.parse(str)
    logger.info(js['translateResult'][1][1]['tgt'])
    return js['translateResult'][1][1]['tgt']
}
;发送接收数据
WinHttp(Httpurl, Httpmode := "GET", Httppostdata := "")
{
    Httpmode := StrUpper(Httpmode) 
    XMLHTTP := ComObject("Microsoft.XMLHTTP")
    XMLHTTP.open(Httpmode, Httpurl, false)
    XMLHTTP.setRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 5.1; rv:11.0) Gecko/20100101 Firefox/11.0")
    if Httpmode == 'POST'
    {
        XMLHTTP.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
        XMLHTTP.send(Httppostdata)
    }else
        XMLHTTP.send()
    return XMLHTTP.ResponseBody
}
;将原始数据流以指定的编码的形式读出
byteToStr(body, charset)
{
    Stream := ComObject("Adodb.Stream")
    Stream.Type := 1
    Stream.Mode := 3
    Stream.Open()
    Stream.Write(body)
    Stream.Position := 0
    Stream.Type := 2
    Stream.Charset := charset
    str := Stream.ReadText()
    Stream.Close()
    return str
}