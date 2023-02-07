#include <log>
#include ./utility/Config.ah2
#ErrorStdOut
#Warn All, Off
obj_cfg := Config(A_ScriptDir "/config/data2html.json")
main_obj_cfg := Config(A_ScriptDir "/config/settings.json")
cfg := obj_cfg.config
main_cfg := main_obj_cfg.config

;设置log模式
logger.is_log_open := cfg['is_log_open']
logger.is_out_file := cfg['is_out_file']
logger.is_use_editor := cfg['is_use_editor']
logger.info('thread start...')

while(1)
{
	if(main_cfg['is_use_html_preview'])
		monitor_html_change()
	Sleep(1000)
}

monitor_html_change()
{
	change_time := FileGetTime(main_cfg['db_path'], 'M')
	SplitPath(main_cfg['db_path'],, &db_dir)
	if(change_time > cfg['last_html_export_time'])
	{
		List := WinGetList('ahk_exe cherrytree.exe',, 'Program Manager')
		for k,v in List
		{
			title := ''
			try 
			{
				title := WinGetTitle('ahk_id ' v)
			}
			if(InStr(title, " - " db_dir " - CherryTree"))
			{
            	if(instr(title, "*"))
					logger.info('Now is changing...')
				else
				{
					logger.info('exporte to html...')
					if(!FileExist(main_cfg['cherry_tree_path']))
						MsgBox('cherrytree.exe文件不存在,请在设置中配置!! ' main_cfg['cherry_tree_path']), ExitApp
					if(!FileExist(main_cfg['db_path']))
						MsgBox('db.ctb文件不存在,请在设置中配置!!' main_cfg['db_path']), ExitApp
					if(!FileExist(main_cfg['html_path'] '\data.ctb_HTML\res\'))
					{
						try
						{
							DirCreate(main_cfg['html_path'] '\data.ctb_HTML\res\')
						}
						catch as e
						{
							MsgBox('html export path error:' main_cfg['html_path']), ExitApp
						}
					}
					cfg['last_html_export_time'] := A_Now
					cmd := '"' main_cfg['cherry_tree_path']  '" "'  main_cfg['db_path'] '" -x "' main_cfg['html_path'] '" -w -S'
					try
					{
						RunWait(cmd)
						FileCopy A_ScriptDir '\styles4.css', main_cfg['html_path'] '\data.ctb_HTML\res\', 1
					}
					obj_cfg.saveconfig()
					logger.info('export html end')
				}
			}
		}
	}
}