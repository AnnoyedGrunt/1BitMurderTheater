tool
extends Panel
class_name InventoryBox

onready var image: TextureRect = $TextureRect

func _ready():
	connect("resized", self, "_on_resize")
	
func _on_resize():
	margin_left = -rect_size.y/2
	margin_right = rect_size.y/2
	rect_pivot_offset = rect_size * 0.5
