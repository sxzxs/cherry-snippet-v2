;o := ActiveX_preview()
;o.navigate('G:\我的AHK程序\我的工程\cherry-snippet\data.ctb_HTML\@ahk--脚本库--mcode机器码_godbolt_454.html')
Class ActiveX_preview
{
	__New(gui_option := '-Caption +ToolWindow -DPIScale -Border AlwaysOntop') 
	{
		this.ui := ui := Gui(gui_option)
		this.activex := ui.Add("ActiveX", "w500 h640 x0 y0", "Shell.Explorer")  ; 最后一个参数是 ActiveX 组件的名称.
		wb := this.wb := this.activex.Value
	}
	navigate(url, x := 0, y := 0)
	{
		this.wb.Navigate(url)
		this.ui.Title := url
		this.activex.GetPos(, , &w, &h)
		this.ui.show(Format('w{} h{} x{} y{} NoActivate', w - 25, h, x, y))
	}
	hide() => this.ui.Hide()
}