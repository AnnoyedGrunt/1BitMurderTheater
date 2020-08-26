extends Node2D

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	if !startGame():
		get_tree().reload_current_scene()

func startGame():
	var sceneTree = get_tree()
	var items: Array = sceneTree.get_nodes_in_group("weapons")
	var suspects: Array = sceneTree.get_nodes_in_group("suspects")
	var rooms: Array = sceneTree.get_nodes_in_group("rooms")
	
	if suspects.size() <= 2:
		error("Need more suspects.")
		return false
	
	var victim: Person = popRandomFromArray(suspects)
	var murderer: Person = popRandomFromArray(suspects)
	victim.role = Person.Role.victim
	murderer.role = Person.Role.murderer
	
	for suspect in suspects:
		var room: Room = randomFromArray(rooms) as Room
		reparent(suspect, room.suspects)
	
	#Spawning weapons in the game
	for weapon in sceneTree.get_nodes_in_group("weapons"):
		spawnItem(weapon)
	
	#MUUURDER STEP >:D
	var emptyRooms: Dictionary = {}
	for room in rooms:
		var _room = room as Room
		if _room.suspects.get_child_count() == 0:
			emptyRooms[_room] = true
			
	if emptyRooms.size() == 0:
		error("There is not a single empty room!")
		return false
	else:
		print("# of empty rooms: ", emptyRooms.size())
	
	var emptyAreas: Array = []	
	while emptyRooms.size() > 0:
		var area: Array = []
		var room = emptyRooms.keys()[0]
		buildArea(emptyRooms, area, room)
		emptyAreas.append(area)
		
	print("# of empty areas: ", emptyAreas.size())
	
	var eligibleAreas = []
	for area in emptyAreas:
		var hasWeapon = false
		var hasHidingSpot = false
		for _room in area:
			var room = _room as Room
			for interactable in room.interactables.get_children():
				if interactable.is_in_group("hidingSpots"):
					hasHidingSpot = true
				if interactable.getContainedItem() != null:
					hasWeapon = true
				if hasHidingSpot and hasWeapon:
					break
			if hasHidingSpot and hasWeapon:
				break
		if hasHidingSpot and hasWeapon:
			eligibleAreas.append(area)
	
	if eligibleAreas.size() == 0:
		error("No eligible areas for murder!")
		return
	else:
		print("# of eligible areas: ", eligibleAreas.size())
	
	var murderArea: Array = randomFromArray(eligibleAreas)
	var murderRoom: Room = randomFromArray(murderArea)
	
	var allWeapons: Array = []
	var allHidingSpots: Array = []
	for _room in murderArea:
		var room = _room as Room
		for _interactable in room.interactables.get_children():
			var interactable = _interactable as Interactable
			if interactable.getContainedItem() != null:
				allWeapons.append(interactable.getContainedItem())
			if interactable.is_in_group("hidingSpots"):
				allHidingSpots.append(interactable)
				
	var murderWeapon: Item = randomFromArray(allWeapons)
	murderWeapon.isMurderWeapon = true
	var hidingSpot: Interactable = randomFromArray(allHidingSpots)
	
	print(murderWeapon.itemName)
	print(hidingSpot.name)
	reparent(murderWeapon, hidingSpot.itemContainer)
	
	#Generating statements for suspects
	for suspect in suspects:
		var othersInRoom = PoolStringArray()
		for otherSuspect in suspect.get_parent().get_children():
			print(suspect.get_parent().get_children())
			if suspect != otherSuspect:
				othersInRoom.append(otherSuspect.personName)
				
		var firstLine = getRandomPhrase()
		var secondLine
		
		if othersInRoom.size() > 0:
			secondLine = "I was in the %s with %s." % [suspect.get_parent().get_parent().roomName, othersInRoom.join(" and ")]
		else:
			secondLine = "I was alone in the %s." % suspect.get_parent().get_parent().roomName
		suspect.statement = str(firstLine, "\n", secondLine)
		
	#Generating statement for killer
	var fakeRoom
	var fakeCompany = suspects.duplicate()
	var numberOfCompany = rng.randi_range(0, 2)
	
	while fakeRoom == murderRoom or fakeRoom == null:
		fakeRoom = randomFromArray(rooms)
	
	while fakeCompany.size() > numberOfCompany:
		popRandomFromArray(fakeCompany)
		
	var fakeCompanyNames = PoolStringArray()
	for suspect in fakeCompany:
		fakeCompanyNames.append(suspect.personName)
		
	var firstLine = getRandomPhrase()
	var secondLine
	
	if fakeCompany.size() > 0:
		secondLine = "I was in the %s with %s." % [fakeRoom.roomName, fakeCompanyNames.join(" and ")]
	else:
		secondLine = "I was alone in the %s." % fakeRoom.roomName
	murderer.statement = str(firstLine, "\n", secondLine)
	
	#Moving suspects & killer to the hall
	var spawns = sceneTree.get_nodes_in_group("suspectSpawns")
	for suspect in suspects:
		reparent(suspect, popRandomFromArray(spawns))
	reparent(murderer, popRandomFromArray(spawns))
	
	#Moving victim to room + setting them up
	victim.makeVictim(murderWeapon)
	reparent(victim, murderRoom.victimSpot)
	
	#This is terrible but, passing info to UI
	$UI.weapon = murderWeapon
	$UI.murderer = murderer

	return true
		
func buildArea(sourceSet: Dictionary, destinationArea: Array, room: Room):
	if sourceSet.has(room):
		sourceSet.erase(room)
		destinationArea.append(room)
		for roomPath in room.linkedRooms:
			var linkedRoom: Room = room.get_node(roomPath) as Room
			buildArea(sourceSet, destinationArea, linkedRoom)
			
func getRandomPhrase():
	var phrases = [
			"I swear it wasn't me!",
			"Please, believe me, it wasn't me.",
			"You think you are smart, don't you? Then you know it wasn't me.",
			"I couldn't hurt a fly! It wasn't me!",
			"If you're such a great detective, you'll realize it wasn't me.",
			"I may have disliked the victim, but... don't look at me like that!",
			"Who could have done something like this? Not me, for sure...",
			"This was meant to be a party... happy times... *sigh*",
			"I curse the day I decided to come to this horrible mansion.",
			"This isn't the first murder that took place here. Ghosts haunt this place.",
			"My good man, I know you'll do the right thing and find the murderer. Who is not me.",
			"Interrogate everybody in the room and it'll be clear who it was...",
			"Believe it or not this is not the first time I am involved in a murder.",
			"This always happens at parties in old, expensive mansions.",
			"YOU?! Why not the englishman, or the frenchman, or that cute little old lady...",
			"C-c-come o-on... I s-swear it w-w-w-w-wasn't me!",
			"The victim deserved to die. I'm sad I wasn't the one to do it.",
			"I'm a suspect? Do you know who I am? I ORDER YOU TO STOP BEING SUSPICIOUS OF ME.",
			"After all this blows over, wanna go to the pub and cheer for a case well solved?",
			"Sir, I'm a big fan! I heard all about your tussle with the Brown Menace.",
			"Maybe it was a suicide? No?",
			"The heavens shall smite down the killer... *crickets* maybe not, then.",
			"Last time I go to a party full of stuffy aristocrats.",
			"While I have a gun on me, a gun is not one of the options in this game. I must be innocent.",
			"My life feels like a board game. We're pieces in this puzzle.",
			"Accuse me and my lawyers will bring hell upon you!",
			"I know you know who I am. It wasn't me. I haven't had long pork in a long while...",
			"The love of my life... dead... how will I go on?",
			"You wouldn't trust me if I said I'm innocent, so: I'm the killer.",
			"I swear on every god of every religion that I'm innocent! BUDDHA! HELP!",
			"When you think about it, who is really innocent? Maybe babies.",
			"Let's say I'm innocent, let's say I'm innocent. It follows you won't accuse me."
		]
	return randomFromArray(phrases)

func error(message: String):
	push_error(message)
	print(message)

func spawnItem(item: Item):
	var sceneTree: SceneTree = get_tree()
	if !sceneTree.has_group(item.spawnGroupName):
		return false
	
	var spots: Array = sceneTree.get_nodes_in_group(item.spawnGroupName)
	var spot: Node2D = randomFromArray(spots) as Interactable
	reparent(item, spot.itemContainer)
	
func randomFromArray(array: Array):
	var length: int = array.size()
	var index: int  = rng.randi_range(0, length - 1)
	return array[index]
	
func popRandomFromArray(array: Array):
	var index: int = rng.randi_range(0, array.size() - 1)
	var element = array[index]
	array.remove(index)
	return element
	
func reparent(node: Node, toParent: Node):
	node.get_parent().remove_child(node)
	toParent.add_child(node)
