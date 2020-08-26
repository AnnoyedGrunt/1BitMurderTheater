extends KinematicBody2D

export var portrait: Texture
export var speed: float = 250
var time: float = 0
var walking_bob = 16
var walking_bob_speed = 10
var walking_lean = 0.2

onready var ui = get_node("/root/Main/UI")
onready var particles = $Particles
onready var sprite = $Sprite

var currentInteractable: Interactable = null

func _process(delta):
	if ui.hasFocus:
		return

	var velocity: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity.y = -1
	if Input.is_action_pressed("ui_down"):
		velocity.y = 1
	if Input.is_action_pressed("ui_left"):
		velocity.x = -1
	if Input.is_action_pressed("ui_right"):
		velocity.x = 1
	
	move_and_slide(velocity.normalized() * speed)
	
	if (velocity.length() > 0):
		time += delta * walking_bob_speed
		time = 0 if time >= 360 else time
		
		sprite.position.y = walking_bob * -abs(sin(time))
		particles.emitting = true
	else:
		time = 0
		sprite.position.y = lerp(sprite.position.y, 0, 0.3)
		particles.emitting = false
		
	sprite.rotation = lerp(sprite.rotation, sign(velocity.x) * walking_lean, 0.3)

func _unhandled_input(event):
	if ui.hasFocus:
		return
		
	if event.is_action_pressed("game_interact"):
		if currentInteractable != null:
			get_tree().set_input_as_handled()
			currentInteractable.onDetectiveInteract(self)

func _on_Interactor_area_entered(area):
	if area is Interactable:
		var interactable = area as Interactable
		interactable.onDetectiveEnter(self)
		
		if interactable.usable:
			setCurrentInteractable(interactable)
	elif area is Room:
		var room = area as Room
		ui.currentRoomName = room.roomName

func _on_Interactor_area_exited(area):
	if area is Interactable:
		var interactable: Interactable = area as Interactable
		interactable.onDetectiveExit(self)
		
		if interactable.usable and currentInteractable == interactable:
			setCurrentInteractable(null)
			
	if area is Room:
		var room: Room = area as Room
		emit_signal("roomEntered", room.roomName)
			
func setCurrentInteractable(interactable: Interactable):
	if interactable == currentInteractable:
		return
	
	if currentInteractable != null:
		currentInteractable.onFocusLose()
		
	if interactable != null:
		interactable.onFocusGain()
	
	currentInteractable = interactable
	
func addItem(item: Item):
	pass
	
func addSuspect(suspect: Node2D):
	pass
	
	
