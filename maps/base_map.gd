extends Node2D
class_name BaseMap

# dificulty level
export( int ) var time_left := 60
export( int ) var save_requirement := 5
export( bool ) var spawn_portals := true
export( int ) var portal_lifetime := 5

func _ready():
	if spawn_portals:
		$game_elements/hazards.activate_spawn_portals( portal_lifetime )
	
