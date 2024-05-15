extends Area2D

@export var harpoon_projectile : Node2D
@export var raft : Node2D

@export var move_speed : float = 200 # How fast do we move on the raft?
@export var water_move_speed : float = 75 # How fast do we move in water?

var is_in_water : bool = false # Are we in water?

func _ready():
	# Tell the projectile who owns it
	# We can't use parenting here, because the harpoon needs to move in global space
	harpoon_projectile.player = self

func _process(delta):
	check_is_in_water()
	# Get keyboard input
	var movement = Input.get_vector("left","right","up","down")
	# Determine if we should move at normal speed, or our reduced water speed
	var _speed = move_speed if not is_in_water else water_move_speed
	# Adjust position
	position += movement * _speed * delta
	
	# Shoot
	if Input.is_action_just_pressed("harpoon"):
		if harpoon_projectile.can_be_launched():
			var direction = (get_global_mouse_position() - global_position).normalized()
			harpoon_projectile.launch(direction)
		

func check_is_in_water():
	# Assume we're in water
	is_in_water = true
	var overlapping = get_overlapping_areas()
	# Loop over everything we're touching
	for area in overlapping:
		# Is it a tile?
		if area.is_in_group("Tile"):
			# We're not in the water
			is_in_water = false
			# Stop checking
			break
