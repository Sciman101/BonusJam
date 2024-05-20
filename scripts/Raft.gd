extends Node2D

# Slow the raft down as it moves
@export var drag : float = 40

var speed : float = 0

# Things standnig on the raft
var passengers = []

func _process(delta):
	position.x += speed * delta
	for thing in passengers:
		thing.position.x += speed * delta
	speed = move_toward(speed, 0, drag * delta)

func remove_passenger(passenger:Node2D):
	passengers.erase(passenger)

func add_passenger(passenger:Node2D):
	passengers.append(passenger)

# Apply an impulse
func paddle(amount:float):
	speed += amount
