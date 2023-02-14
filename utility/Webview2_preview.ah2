;#include "../lib/WebView2.ahk"
;o := Webview2_preview()
;o.Navigate("G:\我的AHK程序\我的工程\cherry-snippet\data.ctb_HTML\@ahk--脚本库--mcode机器码_godbolt_454.html")

Class Webview2_preview
{
	__New(gui_option := '-Caption +ToolWindow -DPIScale -Border AlwaysOntop') 
	{
		this.main := main := Gui(gui_option)
		main.MarginY := 0
		main.MarginX := 0
		main.BackColor := '00ff00'
		main.OnEvent('Close', (*) => (wvc := wv := 0))
		main.OnEvent('Size', (argv*) => this.gui_size(argv*))

		main.show("w500 h200 x-3000 y-3000")
		this.wvc := wvc := WebView2.create(main.Hwnd)
		this.wv := wv := wvc.CoreWebView2

		wv.add_NavigationCompleted(WebView2.Handler((argv*) => this.NavigationCompletedEventHandler(argv*)))
		main.hide()
		this.is_show := false
	}
	show(p*) => (this.main.show(p*), this.is_show := true)
	hide() => (this.main.Hide(), this.is_show := false)
	Navigate(url := '', x := 100, y := 100, w := 800, h := 500)
	{
		this.url := url
		this.wv.Navigate(url)
		this.main.Title := url
		this.show(Format('w{} h{} x{} y{} NoActivate', w, h, x, y))
	}
	NavigationCompletedEventHandler(*) 
	{}
	gui_size(GuiObj, MinMax, Width, Height)
	{
		if (MinMax != -1) 
		{
			try 
			{
				this.wvc.Fill()
			}
		}
	}
}