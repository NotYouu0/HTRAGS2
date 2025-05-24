extends StaticBody

var tv_off = true

func interact():
	tv_off = not tv_off
	
	$Panel / Screen2.visible = tv_off
