tool
extends Area2D
class_name Room

onready var interactables: Node2D = $Interactables
onready var suspects: Node2D = $Suspects
onready var victimSpot: Position2D = $VictimSpot

signal roomEntered(enterer, room)

export (String) var roomName: String = "Room"
export (Array, NodePath) var linkedRooms: Array = []

func _on_Room_body_entered(body):
	emit_signal("roomEntered", body, self)
