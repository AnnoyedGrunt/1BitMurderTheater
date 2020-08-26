extends PanelContainer

onready var player: AnimationPlayer = $Hbox/Hourglass/AnimationPlayer
onready var timeLabel: Label = $Hbox/TimeLabel

func _on_UI_uiFocusChanged(hasFocus):
	if hasFocus:
		player.stop(false)
	else:
		player.play(player.assigned_animation)

func _on_UI_uiTimeChanged(remainingSeconds: int):
	var minutes: int = remainingSeconds / 60
	var seconds: int = remainingSeconds % 60
	timeLabel.text = "%02d:%02d" % [minutes, seconds]
