extends Timer

func _on_UI_uiFocusChanged(hasFocus):
	paused = hasFocus
