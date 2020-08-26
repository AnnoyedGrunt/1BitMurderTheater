extends PanelContainer

onready var label = $Label


func _on_UI_uiRoomChanged(roomName):
	label.text = roomName
