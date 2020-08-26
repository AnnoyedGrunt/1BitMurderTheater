extends Panel
class_name Inventory

var itemIndex setget setItemIndex
var suspectIndex = 0 setget setSuspectIndex
var cursorIndex setget setCursorIndex

onready var itemPrevious: InventoryBox = $Menu/ItemSection/BoxContainer/Previous
onready var itemNext: InventoryBox = $Menu/ItemSection/BoxContainer/Next
onready var itemCurrent: InventoryBox = $Menu/ItemSection/BoxContainer/Current
onready var itemLabel: Label = $Menu/ItemSection/Textbox/Label

onready var suspectPrevious: InventoryBox = $Menu/SuspectSection/BoxContainer/Previous
onready var suspectNext: InventoryBox = $Menu/SuspectSection/BoxContainer/Next
onready var suspectCurrent: InventoryBox = $Menu/SuspectSection/BoxContainer/Current
onready var suspectLabel: Label = $Menu/SuspectSection/Textbox/Label

onready var accusationLabel = $Menu/AccuseSection/AccuseButton/HBoxContainer/AccusationLabel

var selectedItem: Item
var selectedSuspect #Type Person but godot's bugged LOL

var items: Array = []
var suspects: Array = []

signal accusationMade(murderer, weapon)

onready var selectables = [
		$Menu/ItemSection/BoxContainer/Current,
		$Menu/SuspectSection/BoxContainer/Current,
		$Menu/AccuseSection/AccuseButton
	]
onready var cursor = $Cursor

func _ready():
	setCursorIndex(0)
	setItemIndex(0)
	setSuspectIndex(0)
	updateAccusationLabel()

func appear():
	setCursorIndex(cursorIndex)
	setItemIndex(itemIndex)
	setSuspectIndex(suspectIndex)
	visible = true
	
func disappear():
	visible = false

func setItemIndex(value):
	itemIndex = clamp(value, 0, items.size() - 1)
	if items.size() == 0:
		itemCurrent.image.texture = null
		itemNext.visible = false
		itemPrevious.visible = false
	else:
		selectedItem = items[itemIndex]
		updateAccusationLabel()
		itemCurrent.image.texture = selectedItem.image
		itemLabel.text = selectedItem.getDescription()
		
		if itemIndex + 1 < items.size():
			itemNext.visible = true
			itemNext.image.texture = items[itemIndex + 1].image
		else:
			itemNext.visible = false
			
		if itemIndex - 1 >= 0:
			itemPrevious.visible = true
			itemPrevious.image.texture = items[itemIndex - 1].image
		else:
			itemPrevious.visible = false
	
func setSuspectIndex(value):
	suspectIndex = clamp(value, 0, suspects.size() - 1)
	if suspects.size() == 0:
		suspectCurrent.image.texture = null
		suspectNext.visible = false
		suspectPrevious.visible = false
	else:
		selectedSuspect = suspects[suspectIndex]
		updateAccusationLabel()
		suspectCurrent.image.texture = selectedSuspect.portrait
		suspectLabel.text = selectedSuspect.getStatement()
		
		if suspectIndex + 1 < suspects.size():
			suspectNext.visible = true
			suspectNext.image.texture = suspects[suspectIndex + 1].portrait
		else:
			suspectNext.visible = false
			
		if suspectIndex - 1 >= 0:
			suspectPrevious.visible = true
			suspectPrevious.image.texture = suspects[suspectIndex - 1].portrait
		else:
			suspectPrevious.visible = false
	
func setCursorIndex(value):
	var newValue = clamp(value, 0, selectables.size() - 1)
	if cursorIndex != newValue:
		cursorIndex = newValue
		var selectable = selectables[cursorIndex]
		cursor.get_parent().remove_child(cursor)
		selectable.add_child(cursor)
		fixCursor()
		
func updateAccusationLabel():
	var killer: String = selectedSuspect.personName if selectedSuspect != null else "???"
	var weapon: String = selectedItem.itemName if selectedItem != null else "???"
		
	accusationLabel.text = "It was %s with the %s" % [killer, weapon]
	
func _unhandled_input(event):
	if !visible:
		return
	
	var handled = false
	var playChangeAudio = false
	
	if event.is_action_pressed("ui_down"):
		setCursorIndex(cursorIndex+1)
		playChangeAudio = true
		handled = true
	elif event.is_action_pressed("ui_up"):
		setCursorIndex(cursorIndex-1)
		playChangeAudio = true
		handled = true
	elif event.is_action_pressed("ui_left"):
		if cursorIndex == 0:
			setItemIndex(itemIndex - 1)
			handled = true
		elif cursorIndex == 1:
			setSuspectIndex(suspectIndex - 1)
			handled = true
		playChangeAudio = true
	elif event.is_action_pressed("ui_right"):
		if cursorIndex == 0:
			setItemIndex(itemIndex + 1)
			handled = true
		elif cursorIndex == 1:
			setSuspectIndex(suspectIndex + 1)
			handled = true
		playChangeAudio = true
	elif event.is_action_pressed("game_interact"):
		if cursorIndex == 2:
			if selectedItem != null and selectedSuspect != null:
				emit_signal("accusationMade", selectedSuspect, selectedItem)
			else:
				$audioWrongSelection.play()
		handled = true
			
	if playChangeAudio:
		$audioChangeSelection.play()	
			
	if handled:
		get_tree().set_input_as_handled()

func fixCursor():
	var spacing = 12
	cursor.margin_top = -spacing
	cursor.margin_left = -spacing
	cursor.margin_bottom = spacing
	cursor.margin_right = spacing
