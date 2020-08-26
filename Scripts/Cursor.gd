extends NinePatchRect

export var scaleVariation: float = 0.05
export var waveTime: float = 1
export var currentTime: float = 0

func _ready():
	connect("resized", self, "_on_resize")

func _process(delta):
	currentTime += delta
	if currentTime >= waveTime:
		currentTime -= waveTime
	var progress = abs(sin((currentTime / waveTime) * 2 * PI))
	rect_scale = Vector2.ONE + Vector2.ONE * progress * scaleVariation

func _on_resize():
	rect_pivot_offset = rect_size * 0.5
