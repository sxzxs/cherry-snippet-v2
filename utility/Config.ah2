class Config
{
	path := unset
	config := {}
	__New(path) 
	{
		if(path)
		{
			if(path != '')
				this.path := path
			else
			{
				MsgBox('Please input config path')
				return
			}
		}
		this.loadconfig(path)
	}
	;加载配置函数
	loadconfig(json_path)
	{
		outputvar := FileRead(json_path)
		this.config := JSON.parse(outputvar)
	}
	;保存配置函数
	saveconfig(json_path := this.path)
	{
		str := JSON.stringify(this.config, 4)
		FileDelete(json_path)
		FileAppend(str, json_path, 'UTF-8')
	}
}