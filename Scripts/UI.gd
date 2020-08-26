extends CanvasLayer
class_name UI

var hasFocus = false setget setFocus
var remainingSeconds = 120
var currentRoomName = "" setget setRoomName

var murderer
var weapon: Item

onready var game = get_node("/root/Main")
onready var messageBox = $MessageBox
onready var inventory: Inventory = $Inventory
onready var endScreen = $EndScreen

signal uiFocusChanged(hasFocus)
signal uiTimeChanged(remainingSeconds)
signal uiRoomChanged(roomName)
signal uiInventoryOpened()
signal uiInventoryAdded()

func _ready():
	inventory.visible = false
	endScreen.visible = false
	emit_signal("uiTimeChanged", remainingSeconds)

func displayMessage(name: String, message: String, image: Texture):
	if hasFocus:
		return
	
	setFocus(true)
	messageBox.displayMessage(name, message, image)
	yield(messageBox, "nextRequested")
	messageBox.dismiss()
	yield(messageBox, "dismissed")
	setFocus(false)
	
func subtractSeconds(amount: float):
	remainingSeconds = max(0, remainingSeconds - amount)
	emit_signal("uiTimeChanged", remainingSeconds)
	$HUD/FirstRow/TimeBox/Hbox/TimeLabel/MalusLabel/AnimationPlayer.play("malus_show")

func setFocus(value):
	hasFocus = value
	emit_signal("uiFocusChanged", value)
	
func setRoomName(value):
	currentRoomName = value
	emit_signal("uiRoomChanged", value)
	
func _on_Timer_timeout():
	remainingSeconds -= 1
	emit_signal("uiTimeChanged", remainingSeconds)
	if remainingSeconds == 0:
		showEndScreen(false, murderer, weapon)
	else:
		$audioTock.play()
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if hasFocus == inventory.visible:
			setFocus(!hasFocus)
			if inventory.visible:
				inventory.disappear()
			else:
				inventory.appear()
			emit_signal("uiInventoryOpened")
			get_tree().set_input_as_handled()
		
func addItem(item: Item):
	if !inventory.items.has(item):
		inventory.items.append(item)
		emit_signal("uiInventoryAdded")
		$audioItemGet.play()
		
func addSuspect(suspect):
	if !inventory.suspects.has(suspect):
		inventory.suspects.append(suspect)
		emit_signal("uiInventoryAdded")
		$audioItemGet.play()

func _on_Inventory_accusationMade(accusedSuspect, accusedWeapon):
	var success = accusedSuspect == murderer and accusedWeapon == weapon
	showEndScreen(success, murderer, weapon)
	print("ohiohi")
	
func showEndScreen(success, murderer, weapon):
	setFocus(true)
	if messageBox.visible:
		messageBox.dismiss()
	elif inventory.visible:
		print("ohnoes")
		inventory.disappear()
		
	endScreen.display(success, murderer, weapon)
	
