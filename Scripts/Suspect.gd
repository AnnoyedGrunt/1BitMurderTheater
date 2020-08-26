extends Interactable
class_name Person

enum Role {
	suspect,
	victim,
	murderer
}

export var personName: String = "Person"
export var portrait: Texture
export var image: Texture setget setImage, getImage

onready var sprite = $Sprite

var role: int = Role.suspect
var witnesses: Array = []
var murderWeapon: Array
var statement: String = "This is a person speaking"

func makeVictim(murderWeapon: Item):
	role = Role.victim
	match(murderWeapon.type):
		Item.weaponType.blunt:
			statement = "You check the body. Under the blood, you find proof of multiple, crushing strikes."
		Item.weaponType.cut:
			statement = "You check the body. Under the blood, you find proof of multiple, devastating cuts."
		Item.weaponType.invisible:
			statement = "You check the body. The victim almost looks like asleep, providing no clues as to how death occurred."
	
	$Sprite.rotate(1.5)
	$Sprite.modulate = Color(0.5, 0.5, 0.5)
		

func onDetectiveInteract(detective):
	ui.displayMessage(personName, getStatement(), portrait)
	ui.subtractSeconds(2)
	if role != Role.victim:
		ui.addSuspect(self)
	
func getStatement():
	return statement

func _ready():
	setImage(image)

func setImage(value: Texture):
	if sprite != null:
		sprite.texture = value
	else:
		image = value
	
func getImage():
	if sprite != null:
		return sprite.texture
	else:
		return image
