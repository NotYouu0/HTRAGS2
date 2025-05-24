extends Area

onready var ford_mustang = $FordMustang

func _on_HitByCar_body_entered(body):
	if body.name == "Player":
		
		$FordMustang.visible = true
		$CollisionShape.disabled = false
		$Tween.interpolate_property($FordMustang, "global_translation", Vector3( - 350, 0.5, 5), Vector3(550, 0.5, 5), 1.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()

		
		
		
		
		

func _on_FordMustang_body_entered(body):
	if body.name == "Player":
		set_physics_process(false)
		EndingManager.end_game("How did you even survive as a child?")
