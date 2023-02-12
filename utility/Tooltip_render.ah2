class Tooltip_render
{
	__New(tex_style := unset, back_style := unset) 
	{
		this.text_style := {s : '3vmin'}
		this.back_style := {time : 1000, t : 1250, c : '#F9E486', y : '75vh', r : "10%%"}
		if(IsSet(tex_style))
			this.text_style := tex_style
		if(IsSet(back_style))
			this.text_style := back_style
		this.rd := TextRender()
	}
	__Delete() 
	{
	}
	render(text, x := unset, y := unset, hold_time := unset)
	{
		if(IsSet(hold_time))
			this.back_style.time := hold_time
		if(IsSet(x))
			this.back_style.x := x
		if(IsSet(y))
			this.back_style.y := y
		this.rd.render(text, this.back_style, this.text_style)
	}
}