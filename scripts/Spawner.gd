extends Node

var inactive_rules = []
var active_rules = []

var countdowns = {}

# How long has the round lasted?
var elapsed_time : float = 0.0

func _ready():
	# Get all child spawn rules
	inactive_rules = get_children()

func _process(delta):
	elapsed_time += delta
	for rule in inactive_rules:
		if rule.spawn_after_time <= elapsed_time:
			active_rules.append(rule)
			inactive_rules.erase(rule)
			
			countdowns[rule] = get_spawn_delay(rule)
	
	for rule in active_rules:
		countdowns[rule] -= delta
		if countdowns[rule] <= 0:
			trigger_rule(rule)

func get_spawn_delay(rule):
	return randf_range(rule.spawn_minimum_wait, rule.spawn_maximum_wait)

func trigger_rule(rule):
	countdowns[rule] = get_spawn_delay(rule)
	var instance = rule.scene_to_spawn.instantiate()
	get_parent().add_child(instance)
