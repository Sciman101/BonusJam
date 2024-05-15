extends Node

# Path to the scene to spawn
@export_file("*.tscn") var scene_path : String
# This thing will only spawn after this many seconds have passed in the current round
@export var spawn_after_time : float
# After spawn_after_time has passed, a random value between these two will be chosen
# and a scene will be spawned after that
@export var spawn_minimum_wait : float
@export var spawn_maximum_wait : float

var scene_to_spawn

func _ready():
	scene_to_spawn = load(scene_path)
