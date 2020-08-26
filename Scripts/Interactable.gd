extends Area2D
class_name Interactable

onready var ui: UI = get_node("/root/Main/UI")
onready var bubble = $Bubble
onready var itemContainer = $ItemContainer

export var usable: bool = true
export (Resource) var message: Resource = Message.new()
export (String) var containerLine: String = "It contains"
var active: bool = false

func onDetectiveEnter(detective):
	pass
	
func onDetectiveExit(detective):
	pass
	
func onFocusGain():
	bubble.appear()
	
func onFocusLose():
	bubble.disappear()
	
func onDetectiveInteract(detective):
	var item: Item = getContainedItem()

	var displayName: String
	var text: String
	var image: Texture
	
	if item:
		displayName = item.itemName
		text = "%s\n\n%s:\n%s" % [message.text, containerLine, item.description]
		image = item.image
		ui.addItem(item)
	else:
		displayName = message.displayName
		text = message.text
		image = message.image
		
	ui.displayMessage(displayName, text, image)
	ui.subtractSeconds(2)
		
func getContainedItem():
	if itemContainer.get_child_count() > 0:
		return itemContainer.get_child(0)
	return null
