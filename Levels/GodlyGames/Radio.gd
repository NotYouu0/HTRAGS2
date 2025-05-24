extends AudioStreamPlayer3D


func _ready():
	
	stream = load($"..".music)
	playing = true
