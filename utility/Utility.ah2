;杂项函数
;by Tebayaki
;读取进程标准输出
ReadProcessStdOut(cmd, stdin := "", encoding := "cp0", is_wait := true) {
    sa := Buffer(24)
    NumPut("uint", sa.Size, sa)
    NumPut("ptr", 0, "uint", 1, sa, 8)

    if !DllCall("CreatePipe", "ptr*", &hReadPipeOut := 0, "ptr*", &hWritePipeOut := 0, "ptr", sa, "uint", 0)
        throw OSError()
    DllCall("SetHandleInformation", "ptr", hReadPipeOut, "uint", 1, "uint", 0)

    si := Buffer(104, 0)
    NumPut("uint", si.Size, si)
    NumPut("uint", 0x101, si, 60)
    NumPut("ptr", hWritePipeOut, si, 88)

    if stdin !== "" {
        if !DllCall("CreatePipe", "ptr*", &hReadPipeIn := 0, "ptr*", &hWritePipeIn := 0, "ptr", sa, "uint", 0)
            throw OSError()
        DllCall("SetHandleInformation", "ptr", hWritePipeIn, "uint", 1, "uint", 0)
        NumPut("ptr", hReadPipeIn, si, 80)
    }

    if !DllCall("CreateProcessW", "ptr", 0, "str", cmd, "ptr", 0, "ptr", 0, "int", true, "uint", 0, "ptr", 0, "ptr", 0, "ptr", si, "ptr", pi := Buffer(24)) {
        DllCall("CloseHandle", "ptr", hWritePipeOut)
        DllCall("CloseHandle", "ptr", hReadPipeOut)
        throw OSError()
    }
    DllCall("CloseHandle", "ptr", NumGet(pi, "ptr"))
    DllCall("CloseHandle", "ptr", NumGet(pi, 8, "ptr"))
    DllCall("CloseHandle", "ptr", hWritePipeOut)


    if stdin !== "" {
        DllCall("CloseHandle", "ptr", hReadPipeIn)
        if !DllCall("WriteFile", "ptr", hWritePipeIn, "astr", stdin, "uint", StrPut(stdin, encoding) - 1, "uint*", &lpNumberOfBytesWritten := 0, "ptr", 0){
            DllCall("CloseHandle", "ptr", hWritePipeIn)
            throw OSError()
        }
        DllCall("CloseHandle", "ptr", hWritePipeIn)
    }

	if(!is_wait)
		return

    stdout := ""
    while DllCall("ReadFile", "ptr", hReadPipeOut, "ptr", buf := Buffer(4096), "uint", buf.Size, "uint*", &lpNumberOfBytesRead := 0, "ptr", 0) && lpNumberOfBytesRead
        stdout .= StrGet(buf, lpNumberOfBytesRead, encoding)
    DllCall("CloseHandle", "ptr", hReadPipeOut)

    return stdout
}
;使用案例,脚本改名都没用,照样只能运行一个.
/*
if(Single("456")) 
{
	MsgBox('提示,程序已启动!`n请勿重复运行')
	ExitApp
}
*/
;返回1为重复,返回0为第一个运行
class Single_instance
{
	static create(flag)
	{
		this.handle := DllCall("CreateMutex", "Ptr",0, "int",0, "str", "Ahk_Single_" flag)
		return A_LastError == 0xB7 ? true : false
	}
	static close()
	{
		DllCall("CloseHandle", 'ptr', this.handle)
	}
}
;清理重复进程
instance_once()
{
    CurPID := DllCall("GetCurrentProcessId")
    List := WinGetList(A_ScriptFullPath ' ahk_class AutoHotkey')
	for k,v in List
    { 
		PID := WinGetPID('ahk_id ' v)
        If (PID != CurPID)
			ProcessWaitClose(PID)
    }
}
RunAsAdmin()
{
	full_command_line := DllCall("GetCommandLine", "str")
	if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
	{
		try
		{
			if A_IsCompiled
				Run '*RunAs "' A_ScriptFullPath '" /restart'
			else
				Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
		}
		catch as e
		{
			MsgBox('尝试已管理器重启失败,退出!! ' e.Message)
			ExitApp
		}
	}

}

ExecScript(Script, Params := "", AhkPath := "") 
{
    Name := Pipe := Call := Shell := Exec := ''
    Name := "AHK_CQT_" . A_TickCount
    Pipe := []
    Loop(2) 
	{
        Pipe.Push(DllCall("CreateNamedPipe"
        , "Str", "\\.\pipe\" . Name
        , "UInt", 2, "UInt", 0
        , "UInt", 255, "UInt", 0
        , "UInt", 0, "UPtr", 0
        , "UPtr", 0, "UPtr"))
    }

    If (!FileExist(AhkPath)) 
        AhkPath := A_AhkPath

    Call := AhkPath ' /CP65001 \\.\pipe\' Name
    shell := ComObject("WScript.Shell")
    Exec := Shell.Exec(Call . " " . Params)
    DllCall("ConnectNamedPipe", "UPtr", Pipe[1], "UPtr", 0)
    DllCall("CloseHandle", "UPtr", Pipe[1])
    DllCall("ConnectNamedPipe", "UPtr", Pipe[2], "UPtr", 0)
    FileOpen(Pipe[2], "h", "UTF-8").Write(Script)
    DllCall("CloseHandle", "UPtr", Pipe[2])
    Return Exec
}