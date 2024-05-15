extends Area2D

func _ready():
	position = Vector2(randi_range(-500, 500), -500)

func _process(delta):
	if is_in_group("Harpoonable"):
		position.y += delta * 100
		if position.y > 600:
			queue_free()
	else:
		set_process(false)
