extends Node2D

const TILE_SIZE := 96

# Slow the raft down as it moves
@export var drag : float = 40

# Sparse array of tiles
var tiles = {}
# Things standnig on the raft
var passengers = []
var speed : float = 0

func _ready():
	# Setup any existing children as tiles
	for child in get_children():
		var pos = Vector2i(child.position.x / TILE_SIZE, child.position.y / TILE_SIZE)
		set_tile(pos, child)
		child.position = pos * TILE_SIZE

func _process(delta):
	# Move
	position.x += speed * delta
	for thing in passengers:
		thing.position.x += speed * delta
	speed = move_toward(speed, 0, drag * delta)

func set_tile(pos:Vector2i, tile : Node2D, override=false, do_tween=false):
	var old_tile = tiles.get(pos)
	if old_tile:
		if override:
			old_tile.queue_free()
	tiles[pos] = tile
	# Handle parenting
	tile.reparent(self)
	if do_tween:
		var tween = tile.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(tile, 'position', Vector2(pos * TILE_SIZE), 0.5)
	else:
		tile.position = pos * TILE_SIZE

func get_tile(pos:Vector2i):
	return tiles.get(pos)

func get_neighbors(pos:Vector2i):
	return [get_tile(pos+Vector2i.RIGHT),get_tile(pos+Vector2i.UP),get_tile(pos+Vector2i.LEFT),get_tile(pos+Vector2i.DOWN)]

func has_neighbors(pos:Vector2i):
	var neighbors = get_neighbors(pos)
	for n in neighbors:
		if n != null:
			return true
	return false

func world_pos_to_tile(pos:Vector2):
	var localpos = to_local(pos)
	return Vector2i(round(localpos.x / TILE_SIZE), round(localpos.y / TILE_SIZE))

func remove_passenger(passenger:Node2D):
	passengers.erase(passenger)

func add_passenger(passenger:Node2D):
	passengers.append(passenger)

# Apply an impulse
func paddle(amount:float):
	speed += amount
