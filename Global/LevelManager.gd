extends Node

signal scene_changed()

onready var animation = $AnimationPlayer
onready var background = $Control / Background
onready var loading_label = $Control / Loading

func load_level(path):
	GlobalFlags.loading = true
	print("Loading level: " + path)
	animation.play("transition")
	yield(animation, "animation_finished")
	
	var err = get_tree().change_scene("res://Levels/" + path)
	if err == OK:
		get_tree().change_scene("res://Levels/" + path)
		print("Successfully loaded " + path)
	else:
		print("Failed to load " + path + " Error Code " + str(err))
	animation.play_backwards("transition")
	yield(animation, "animation_finished")
	GlobalFlags.loading = false
	emit_signal("scene_changed")
