class Tree_node_data
{
	static node_data := []
	static path2id := Map() ;path 到 node id到映射
	static id_path := Map() ;id 到 [path, father_id ,text, tag, icon, is_show]
	static path2py := Map() ;path map "1 all py" "2 inital py" "3 double py" "all"
	static py_path := A_ScriptDir . "/config/py_map.bin"
	static __New() 
	{}
	static load_db_data()
	{
		Critical 'on'
		this.node_data := []
		this.path2id := Map() ;path 到 node id到映射
		this.id_path := Map() ;id 到 [path, father_id ,text]
		if(!FileExist(this.py_path))
			FileAppend('{}', this.py_path, 'UTF-8')
		else
			this.path2py := JSON.parse(FileRead(this.py_path))
		if (!FileExist(cfg['cherry_tree_path']))
		{
			if (FileExist(A_ScriptDir '\..\cherrytree_customization\mingw64\bin\cherrytree.exe'))
				cfg['cherry_tree_path'] := A_ScriptDir '\..\cherrytree_customization\mingw64\bin\cherrytree.exe'
			else
			{
				Run(A_ScriptDir '/README.html')
				SelectedFile := FileSelect(3, , "选择cherrytree.exe文件, 没有请看帮助文档安装", "执行文件 (cherrytree.exe)")
				if SelectedFile = ""
				{
					MsgBox "The user didn't select anything."
					ExitApp
				}
				cfg['cherry_tree_path'] := SelectedFile
			}
			obj_cfg.saveconfig()
		}

		if (!FileExist(cfg['db_path']))
		{
			if (FileExist(A_ScriptDir '\data.ctb'))
				cfg['db_path'] := A_ScriptDir '\data.ctb'
			else
			{
				SelectedFile := FileSelect(3, , "选择.ctb文件", "ctb文件 (*.ctb)")
				if SelectedFile = ""
				{
					MsgBox "The user didn't select anything."
					ExitApp
				}
				cfg['db_path'] := SelectedFile
			}
			obj_cfg.saveconfig()
		}

		this.DB := DB := SQLiteDB()
		If !DB.OpenDB(cfg['db_path']) 
		{
			MsgBox("Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode, "SQLite Error", 16)
			ExitApp
		}

		SQL := "SELECT * FROM children;"
		If !DB.GetTable(SQL, &Result)
			MsgBox(16, 'SQLite Error', "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode)

		SQL := "SELECT * FROM node;"
		If !DB.GetTable(SQL, &obj_sql_node)
			MsgBox(16, 'SQLite Error', "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode)

		map_father := map()
		for k,v in result.rows
		{
			map_father[v[1]] := v[2] 
		}

		obj_sql_node.map_node := map()
		for k,v in obj_sql_node.rows
		{
			obj_sql_node.map_node[v[1]] := v 
		}

		id_path := map()
		for k,v in map_father
		{
			path_string_file := path_string := obj_sql_node.map_node[k][2]
			tag := obj_sql_node.map_node[k][5]
			id_path[k] := map()
			id_path[k]["father_id"] := []
			id_path[k]["name"] := path_string
			id_path[k]['icon'] := ''
			id_path[k]['is_show'] := true
			is_get_icons := false ;标记是否设置icons,或者最近的父节点设置icons
			is_get_show := false
			if(InStr(tag, 'icon:'))
			{
				is_get_icons := true
				id_path[k]['icon'] := SubStr(tag, InStr(tag, 'icon:') + 5)
			}
			if(InStr(tag, '屏蔽'))
			{
				is_get_show := true
				id_path[k]['is_show'] := false
			}
			loop
			{
				if(map_father.Has(v))
				{
					path_string := obj_sql_node.map_node[v][2] "-" path_string
					path_string_file := obj_sql_node.map_node[v][2] "--" path_string_file
					id_path[k]["father_id"].Push(v)

					if(!is_get_icons)
					{
						f_tag := obj_sql_node.map_node[v][5]
						if(InStr(f_tag, 'icon:'))
						{
							is_get_icons := true
							id_path[k]['icon'] := SubStr(f_tag, InStr(f_tag, 'icon:') + 5)
						}
					}
					if(!is_get_show)
					{
						f_tag := obj_sql_node.map_node[v][5]
						if(InStr(f_tag, '屏蔽'))
						{
							is_get_icons := true
							id_path[k]['is_show'] := false
						}
					}
				}
				else
				{
					id_path[k]["father_id"].Push(0)
					id_path[k]["path"] := path_string 
					;比较占内存,改为从db实时获取
					;id_path[k]['text'] := obj_sql_node.map_node[k][3]
					path_string_file := StrReplace(path_string_file, A_Space, "_")
					path_string_file := StrReplace(path_string_file, "/", "-")
					id_path[k]["path_file"] := path_string_file "_" k
					id_path[k]["tag"] := tag
					break
				}
				v := map_father[v]
			}
		}
		this.id_path := id_path
		for k,v in id_path
		{
			this.node_data.Push(v['path'])
			this.path2id[v['path']] := k

			str_key := v['path']
			if(this.path2py.Has(str_key))
			{
				py_all := this.path2py[str_key]['1']
				py_init := this.path2py[str_key]['2']
			}
			else
			{
				this.path2py[v['path']] := Map()
				py_all := py.allspell_muti_ptr(str_key)
				py_init := py.initials_muti_ptr(str_key)
				this.path2py[str_key]['1'] := py_all
				this.path2py[str_key]['2'] := py_init
			}
			this.path2py[str_key]['all'] := str_key py_all py_init
        	if(cfg['is_use_xiaohe_double_pinyin'] == 1)
			{
				if(this.path2py.has(str_key) && this.path2py[str_key].has('3'))
					py_double := this.path2py[str_key]['3']
				else
				{
					py_double := py.double_spell_muti_ptr(str_key)
					this.path2py[str_key]['3'] := py_double
				}
				this.path2py[str_key]['all'] .= py_double
			}
			if(!cfg.Has('is_use_huma') || cfg['is_use_huma'] == 1)
			{
				if(this.path2py.has(str_key) && this.path2py[str_key].has('4'))
					huma_str := this.path2py[str_key]['4']
				else
				{
					huma_str := g_huma.code(str_key)
					this.path2py[str_key]['4'] := huma_str
				}
				this.path2py[str_key]['all'] .= huma_str
			}
		}
    	cfg['last_parse_time'] := A_now

		str := JSON.stringify(this.path2py, 4)
		FileDelete(this.py_path)
		FileAppend(str, this.py_path, 'UTF-8')

		obj_cfg.saveconfig()
		Critical 'off'
	}
	static get_text_from_id(id)
	{
    	SQL := "SELECT * FROM node WHERE node_id = " id ";"
		If !this.DB.GetTable(SQL, &Result)
		{
			MsgBox(16, 'SQLite Error', "Msg:`t" . this.DB.ErrorMsg . "`nCode:`t" . this.DB.ErrorCode)
			return ''
		}
		return Result.rows[1][3]
	}
	static __Delete() 
	{}
}