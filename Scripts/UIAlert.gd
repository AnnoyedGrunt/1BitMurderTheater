extends PanelContainer

var shouldAppear = false

func _ready():
	visible = false


func _on_UI_uiInventoryOpened():
	visible = false
	
func _on_UI_uiInventoryAdded():
	shouldAppear = true
	
func _on_UI_uiFocusChanged(hasFocus):
	if shouldAppear and !hasFocus:
		visible = true
		shouldAppear = false
