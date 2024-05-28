extends Area2D

var HARPOON_ROPE_LENGTH : float = 500 # The max distance the harpoon can be from the player

enum {
	DISABLED, # The harpoon has not been fired
	LAUNCHED, # The harpoon is traveling in a straight line towards its target
	RETRACTING # The harpoon is being pulled back towards the player
}

@export var launch_speed : float = 300 # How quickly does the harpoon fire?
@export var retract_speed : float = 200 # How quickly does the harpoon retract?

@onready var rope : Line2D = $Rope

var player : Node2D

var mode : int = DISABLED # What mode are we in?
var velocity : Vector2 # Used to track how we move in the LAUNCHED mode
var harpooned_object :Area2D = null # What have we harpooned?
var attachment_offset : Vector2 # When we harpoon something, we don't hit the dead center, so we record the offset so it looks right when we drag it back

# Sets the current mode. Mostly used internally
func set_mode(mode:int):
	self.mode = mode
	if mode == DISABLED:
		hide()
		velocity = Vector2.ZERO
		# If a tile is dragged back but not attached, it needs to be set as
		# not harpooned so it can be run over
		if harpooned_object && harpooned_object.is_in_group("Harpoonable"):
			harpooned_object.remove_from_group("Harpooned")
		harpooned_object = null
		set_process(false)
	else:
		show()
		set_process(true)

# Check for the player if we can even launch the harpoon
func can_be_launched():
	return mode == DISABLED

# Called by the player to shoot us
func launch(direction:Vector2):
	set_mode(LAUNCHED)
	position = player.position
	self.velocity = direction.normalized() * launch_speed

func _ready():
	set_mode(DISABLED)

# When retracting, pull back
func _process(delta):
	if mode == RETRACTING:
		# Retreat to our beloved player
		var target = player.position
		position = position.move_toward(target, retract_speed * delta)
		
		# Once close to the player, disable
		if position.distance_to(player.position) <= 10:
			set_mode(DISABLED)
		
		# Move our object to the location of the harpoon
		# (We could use parenting here, but it's kind of a pain with godot imo and this works just as well)
		if harpooned_object:
			var old_pos = harpooned_object.position
			harpooned_object.position = position + attachment_offset
			var overlaps = harpooned_object.get_overlapping_areas()
			for obj in overlaps:
				# Stick it to the raft
				# Also check if not harpoonable to avoid sticking tiles to other free-floating tiles
				if obj.is_in_group("Tile") && !obj.is_in_group("Harpoonable"):
					var raft = player.raft
					var raft_tile_position = raft.world_pos_to_tile(old_pos)
					if not raft.get_tile(raft_tile_position):
						if not raft.has_neighbors(raft_tile_position):
							for corner in [Vector2i(1,1),Vector2i(-1,1),Vector2i(1,-1),Vector2i(-1,-1)]:
								if raft.get_tile(raft_tile_position + corner):
									var hor = Vector2i(corner.x,0)
									var ver = Vector2i(0,corner.y)
									if not raft.get_tile(raft_tile_position + hor):
										raft_tile_position += hor
										break 
									elif not raft.get_tile(raft_tile_position + ver):
										raft_tile_position += ver
										break
						raft.set_tile(raft_tile_position, harpooned_object, false, true)
						# It's on the raft now, we can't re-harpoon it
						harpooned_object.remove_from_group("Harpoonable")
						set_mode(DISABLED)
						break
		
	elif mode == LAUNCHED:
		position += velocity * delta
		if position.distance_to(player.position) >= HARPOON_ROPE_LENGTH:
			set_mode(RETRACTING)
	
	if mode != DISABLED:
		rope.set_point_position(1, player.position - position)

# When the harpoon projectile touches another area2d...
func _on_area_entered(area):
	if mode != LAUNCHED: return
	if area.is_in_group("Harpoonable"):
		# We hit something!
		harpooned_object = area
		attachment_offset = harpooned_object.position - position
		set_mode(RETRACTING)
		# Add to harpooned group so that it doesn't get 'run over' when touching the raft
		area.add_to_group("Harpooned")
