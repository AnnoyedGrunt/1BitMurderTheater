tool
extends NinePatchRect

var visibleCharacters: float = 0
var totalCharacters: float = 0
var displaying: bool = false
export var messageSpeed: float = 50

onready var player = $AnimationPlayer
onready var messageLabel = $HBox/Message
onready var infobox = $HBox/InfoBox
onready var portraitImage = $HBox/InfoBox/Portrait/Image
onready var nameLabel = $HBox/InfoBox/Label

signal finishedDisplaying
signal nextRequested
signal dismissed

func _ready():
	setActive(false)
	
func displayMessage(name: String, message: String, image: Texture):
	setActive(true)
	
	messageLabel.text = message
	visibleCharacters = 0
	totalCharacters = message.length()
	displaying = true
	
	if image:
		infobox.visible = true
		nameLabel.text = name
		portraitImage.texture = image
	else:
		infobox.visible = false
		
	player.play("message_appear")
	yield(player, "animation_finished")

func setActive(active: bool):
	visible = active
	set_process(active)
	
func dismiss():
	player.play_backwards("message_appear")
	yield(player, "animation_finished")
	emit_signal("dismissed")

func _process(delta):
	if !displaying:
		return
		
	visibleCharacters += messageSpeed * delta
	messageLabel.visible_characters = visibleCharacters
	if visibleCharacters >= totalCharacters:
		displaying = false
		emit_signal("finishedDisplaying")
		
func _unhandled_input(event):
	if event.is_action_pressed("game_interact", false):
		get_tree().set_input_as_handled()
		if displaying:
			visibleCharacters = totalCharacters
		else:
			emit_signal("nextRequested")

func _on_MessageBox_resized():
	rect_pivot_offset = rect_size * 0.5
