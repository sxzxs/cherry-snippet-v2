class py
{
    static DLL_USE_MAP := map("cpp2ahk.dll" , 
							map("chinese_convert_pinyin_allspell_muti", 0, 
								"chinese_convert_pinyin_initials_muti", 0, 
								"chinese_convert_double_pinyin_muti", 0,
								"chinese_convert_pinyin_allspell_muti_ptr" , 0,
								"chinese_convert_pinyin_initials_muti_ptr" , 0,
								"chinese_convert_double_pinyin_muti_ptr" , 0,
								"cpp2ahk_is_all_py_match", 0,
								"cpp2ahk_is_all_py_init_match", 0,
								"cpp2ahk_is_double_py_match", 0,
								"cpp2ahk_free_ptr",0))
    static __New() => this.load_all_dll_path()
	static out_str_size := 2048000
    static load_all_dll_path()
    {
        SplitPath(A_LineFile,,&dir)
        path := ""
        lib_path := dir
        if(A_IsCompiled)
        {
            path := (A_PtrSize == 4) ? A_ScriptDir . "\lib\dll_32\" : A_ScriptDir . "\lib\dll_64\"
            lib_path := A_ScriptDir . "\lib"
        }
        else
        {
            path := (A_PtrSize == 4) ? dir . "\dll_32\" : dir . "\dll_64\"
        }
        dllcall("SetDllDirectory", "Str", path)
        for k,v in this.DLL_USE_MAP
        {
            for k1, v1 in v 
            {
                this.DLL_USE_MAP[k][k1] := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", k, "Ptr"), "AStr", k1, "Ptr")
            }
        }
        dllcall("SetDllDirectory", "Str", A_ScriptDir)
    }
	static free_ptr(ptr)
	{
        DllCall(this.DLL_USE_MAP["cpp2ahk.dll"]["cpp2ahk_free_ptr"], "ptr", ptr)
	}
	static double_spell_muti_ptr(in_str)
	{
        ptr := DllCall(this.DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_double_pinyin_muti_ptr"], "Str", in_str, "Cdecl Ptr")
		if(ptr != 0)
		{
        	rtn := StrGet(ptr,,"UTF-8")
			this.free_ptr(ptr)
		}
		else
			rtn := ""
        return rtn
	}
	static initials_muti_ptr(in_str)
	{
	    ptr := DllCall(this.DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_pinyin_initials_muti_ptr"], "Str", in_str, "Cdecl Ptr")
		if(ptr != 0)
		{
        	rtn := StrGet(ptr,,"UTF-8")
			this.free_ptr(ptr)
		}
		else
			rtn := ""
        return rtn
	}
	static allspell_muti_ptr(in_str)
	{
	    ptr := DllCall(this.DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_pinyin_allspell_muti_ptr"], "Str", in_str, "Cdecl Ptr")
		if(ptr != 0)
		{
        	rtn := StrGet(ptr,,"UTF-8")
			this.free_ptr(ptr)
		}
		else
			rtn := ""
        return rtn
	}
	static is_double_spell_match(all_str, filter)
	{
        rtn := DllCall(this.DLL_USE_MAP["cpp2ahk.dll"]["cpp2ahk_is_double_py_match"], "Str", all_str, "Str", filter, "Cdecl Int")
		return rtn
	}
	static is_all_spell_init_match(all_str, filter)
	{
        rtn := DllCall(this.DLL_USE_MAP["cpp2ahk.dll"]["cpp2ahk_is_all_py_init_match"], "Str", all_str, "Str", filter, "Cdecl Int")
		return rtn
	}
	static is_all_spell_match(all_str, filter)
	{
        rtn := DllCall(this.DLL_USE_MAP["cpp2ahk.dll"]["cpp2ahk_is_all_py_match"], "Str", all_str, "Str", filter, "Cdecl Int")
		return rtn
	}
    static double_spell_muti(in_str, out_str_size := this.out_str_size)
    {
	    out_str := Buffer(out_str_size, 0)
        DllCall(this.DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_double_pinyin_muti"], "Str", in_str, "ptr", out_str, "Cdecl Int")
        return StrGet(out_str, out_str_size, "UTF-8")
    }
    static allspell_muti(in_str, out_str_size := this.out_str_size)
    {
	    out_str := Buffer(out_str_size, 0)
        DllCall(this.DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_pinyin_allspell_muti"], "Str", in_str, "ptr", out_str, "Cdecl Int")
        return StrGet(out_str, out_str_size, "UTF-8")
    }
    static initials_muti(in_str, out_str_size := this.out_str_size)
    {
	    out_str := Buffer(out_str_size, 0)
        DllCall(this.DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_pinyin_initials_muti"], "Str", in_str, "ptr", out_str, "Cdecl Int")
        return StrGet(out_str, out_str_size, "UTF-8")
    }
    static strbuf(str, encoding)
    {
        buf := buffer(strput(str, encoding))
        strput(str, buf, encoding)
        return buf
    }
}