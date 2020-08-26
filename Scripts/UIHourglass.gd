tool
extends TextureRect
	
func _on_Hourglass_resized():
	if rect_min_size.x != rect_size.y:
		rect_min_size.x = rect_size.y
		
	rect_pivot_offset = rect_size * 0.5
