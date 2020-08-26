extends Panel

func _input(event):
	if event.is_action_pressed("game_interact"):
		get_tree().change_scene("res://Scenes/Main.tscn")
