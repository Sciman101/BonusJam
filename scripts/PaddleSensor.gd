extends Area2D

var over_water : bool = false

func _on_area_entered(area):
	if area.is_in_group('Tile'):
		over_water = false

func _on_area_exited(area):
	if area.is_in_group('Tile'):
		over_water = true
		for node in get_overlapping_areas():
			if node.is_in_group('Tile'):
				over_water = false
