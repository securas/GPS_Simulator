extends YSort
# This node should take care of spawing NPCs

var road_map : TileMap
var road_map_position : Vector2
var road_map_position_offset : Vector2



#var target_node

var hazards

var npcs := []

func _ready():
	randomize()
	call_deferred( "_set_road_map_and_hazards" )
	call_deferred( "_generate_npc_target_pair" )

func _set_road_map_and_hazards():
	road_map = owner.find_node( "roads" ) # TERRIBLE SOLUTION TO THIS
	assert( road_map )
	road_map_position_offset = road_map.cell_size * 0.5
	
	hazards = owner.find_node( "hazards" ) # SAME TERRIBLE SOLUTION
	assert( hazards )

func _generate_npc_target_pair():
	var npc_spawn_position_nodes = $npc_spawn_positions.get_children()
	var target_spawn_position_nodes = $target_spawn_position.get_children()
	for npc_count in npc_spawn_position_nodes.size():
		if target_spawn_position_nodes.size() == 0:
			target_spawn_position_nodes = $target_spawn_position.get_children()
		
		# select random position from npc spawn positions
		var random_idx = randi() % npc_spawn_position_nodes.size()
		var spawn_position_node = npc_spawn_position_nodes[random_idx]
		npc_spawn_position_nodes.remove( random_idx )
		
		var spawn_position = spawn_position_node.position
		
		
		var target_random_idx = randi() % target_spawn_position_nodes.size()
		var target_position_node = target_spawn_position_nodes[ target_random_idx ]
		target_spawn_position_nodes.remove( target_random_idx )
		
		var target_position = target_position_node.position
		#print( "Spawning NPC - Target pair at ", spawn_position, " ", target_position )
		
		# convert to map positions
		var spawn_map_position = road_map.world_to_map( spawn_position )
		var target_map_position = road_map.world_to_map( target_position )
		
		# create NPC
		var npc = preload( "res://npcs/base_npc.tscn" ).instance()
		npc.hazards = hazards
		npc.road_map = road_map
		npc.road_map_position_offset = road_map_position_offset
		npc._set_at_map_position( spawn_map_position )
		npc.dir_nxt = Vector2.RIGHT.rotated( spawn_position_node.rotation ).round()
		
		
		npc.connect( "reached_tile", self, "_on_npc_reached_tile" )
		
		npcs.append( weakref( npc ) )
	
		# create target
		var target = preload( "res://npcs/target_destination.tscn" ).instance()
		target.road_map = road_map
		target.road_map_position_offset = road_map_position_offset
		target._set_at_map_position( target_map_position )
		
		# link NPC to target
		npc.target_node = target
		target.parent_npc = npc
		
		add_child( target )
		add_child( npc )
		
		
		# activate npc
		npc.activate()


# track positions of NPCs
func _on_npc_reached_tile( _npc, _tilepos : Vector2 ):
	# do nothing
	pass

# check if any NPC is at this position
func check_npcs_at( mappos : Vector2 ):
	for npc in npcs:
		if npc and npc.get_ref() and npc.get_ref().get_road_map_position().is_equal_approx( mappos ):
			return npc.get_ref()
	return null


# return spawn positions for NPC and target
var last_random_idx_used := -1
func set_npc_target_respawn_positions( npc, target ):
	var npc_spawn_position_nodes = $npc_spawn_positions.get_children()
	var target_spawn_position_nodes = $target_spawn_position.get_children()
	var random_idx = randi() % npc_spawn_position_nodes.size()
	while( random_idx == last_random_idx_used ):
		random_idx = randi() % npc_spawn_position_nodes.size()
	var spawn_position_node = npc_spawn_position_nodes[random_idx]
	var spawn_position = spawn_position_node.position
	var target_random_idx = randi() % target_spawn_position_nodes.size()
	var target_position_node = target_spawn_position_nodes[ target_random_idx ]
	var target_position = target_position_node.position
	# convert to map positions
	var spawn_map_position = road_map.world_to_map( spawn_position )
	var target_map_position = road_map.world_to_map( target_position )
	
	npc._set_at_map_position( spawn_map_position )
	npc.dir_nxt = Vector2.RIGHT.rotated( spawn_position_node.rotation ).round()
	target._set_at_map_position( target_map_position )
	


