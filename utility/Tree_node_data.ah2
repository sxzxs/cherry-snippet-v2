class Tree_node_data
{
	static node_data := []
	static path2id := Map() ;path 到 node id到映射
	static id_path := Map() ;id 到 [path, father_id ,text]
	static __New() 
	{}
	static load_db_data()
	{
		this.node_data := []
		this.path2id := Map() ;path 到 node id到映射
		this.id_path := Map() ;id 到 [path, father_id ,text]
		if (!FileExist(cfg['cherry_tree_path']))
		{
			if (FileExist(A_ScriptDir '\..\cherrytree_customization\mingw64\bin\cherrytree.exe'))
				cfg['cherry_tree_path'] := A_ScriptDir '\..\cherrytree_customization\mingw64\bin\cherrytree.exe'
			else
			{
				run('https://www.giuspen.com/cherrytree/')
				run('https://pan.baidu.com/s/1_tzJ8SFvCQJXvVo5YxUEMg?pwd=1w2b')
				SelectedFile := FileSelect(3, , "选择cherrytree.exe文件", "执行文件 (cherrytree.exe)")
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
			if (FileExist(A_ScriptDir '/data.ctb'))
				cfg['db_path'] := A_ScriptDir '/data.ctb'
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
			id_path[k] := map()
			id_path[k]["father_id"] := []
			path_string_file := path_string := obj_sql_node.map_node[k][2]
			loop
			{
				if(map_father.Has(v))
				{
					path_string := obj_sql_node.map_node[v][2] "-" path_string
					path_string_file := obj_sql_node.map_node[v][2] "--" path_string_file
					id_path[k]["father_id"].Push(v)
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
		}
    	cfg['last_parse_time'] := A_now
		obj_cfg.saveconfig()
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