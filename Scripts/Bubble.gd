extends Node2D

onready var animator = $Animator
	
func _ready():
	visible = false
	set_process(false)

func disappear():
	if animator.is_playing():
		animator.playback_speed *= -1
	else:
		animator.playback_speed = 1
		animator.play_backwards("popup_appear")

func appear():
	visible = true
	if animator.is_playing():
		animator.playback_speed *= -1
	else:
		animator.playback_speed = 1
		animator.play("popup_appear")
