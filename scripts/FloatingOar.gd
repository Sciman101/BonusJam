extends Area2D

var animator
var splash_scene

func _ready():
	position = Vector2(randi_range(-500, 500), -500)
	animator = $AnimationPlayer
	splash_scene = preload("res://scenes/splash.tscn")

func _process(delta):
	if is_in_group("Harpoonable"):
		position.y += delta * 100
		if position.y > 600:
			queue_free()
	else:
		set_process(false)

func _on_area_entered(area):
	#If this floating tile collides with another tile that is 
	#harpooned (so part of the raft), have it get run over by the raft
	if !is_in_group("Harpooned") && area.is_in_group("Tile"):
		#'splash_scene' and 'animator' referenced here have two different 
		#animations! splash_scene is a general splash, and the animator 
		#called here shrinks this specific tile. Both are 0.5s long
		var splash = splash_scene.instantiate()
		add_child(splash)
		animator.play("SinkAnim")
		await animator.animation_finished
		queue_free()
