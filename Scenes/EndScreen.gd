extends Panel

onready var resultLabel = $VBox/ResultLabel
onready var murdererImage = $VBox/HBox/MurdererImage
onready var weaponImage = $VBox/HBox/WeaponImage
onready var explanationLabel = $VBox/ExplanationLabel

func display(success, murderer, weapon):
	visible = true
	if success:
		resultLabel.text = "You found the murderer!"
	else:
		resultLabel.text = "The murderer escaped!"
		
	murdererImage.texture = murderer.portrait
	weaponImage.texture = weapon.image
	
	explanationLabel.text = "It was %s with the %s!" % [murderer.personName, weapon.itemName]

func _unhandled_input(event):
	if !visible:
		return
		
	if event.is_action("ui_cancel"):
		get_tree().change_scene("res://Scenes//StartScreen.tscn")
