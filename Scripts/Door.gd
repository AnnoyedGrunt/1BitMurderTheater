extends Interactable

func _ready():
	usable = false
	
func onDetectiveEnter(detective):
	visible = false
	
func onDetectiveExit(detective):
	visible = true
