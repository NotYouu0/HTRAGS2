extends StaticBody


export  var open: bool = true

func interact():
	$OpenSFX.play()
	if not open:
		$AnimationPlayer.play("open")
		open = true
	else:
		$AnimationPlayer.play_backwards("open")
		open = false
