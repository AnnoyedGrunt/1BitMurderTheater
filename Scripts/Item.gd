extends Node2D
class_name Item

enum weaponType {
	blunt,
	cut,
	invisible	
}

export (String) var itemName: String = "Item"
export (String) var spawnGroupName: String = ""
export (Texture) var image: Texture = null
export (String, MULTILINE) var description: String = "Description"
export (weaponType) var type: int = weaponType.blunt

var isMurderWeapon: bool = false
var roomFound: Room = null

func getDescription():
	return description

