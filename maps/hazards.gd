extends YSort

var road_map : TileMap
var road_map_position : Vector2
var road_map_position_offset : Vector2
var spawn_portals := false
var possible_hazard_positions := []

var portals_timer : Timer
var portal_lifetime : float = 15.0



func _ready():
	randomize()
	call_deferred( "_set_road_map" )
	call_deferred( "_set_static_children_properties" )
	
#	if spawn_portals:
#		portals_timer = Timer.new()
#		portals_timer.wait_time = 10
#		add_child( portals_timer )
#		var _ret = portals_timer.connect("timeout", self, "_on_portals_timer" )
#		portals_timer.start()

func activate_spawn_portals( time ):
	print( "Setting up portals timer")
	portal_lifetime = float( time )
	portals_timer = Timer.new()
	portals_timer.wait_time = time * 2.0
	add_child( portals_timer )
	var _ret = portals_timer.connect("timeout", self, "_on_portals_timer" )
	portals_timer.start()


func _on_portals_timer():
	print( "Starting portals timer")
	_spawn_portal()
	pass


func _set_static_children_properties():
	for c in get_children():
		if not c is Hazard:
			continue
		c.road_map = road_map
		c.road_map_position_offset = road_map_position_offset
		var position_with_offset = c.position + Vector2.UP * road_map_position_offset.y
		c.road_map_position = road_map.world_to_map( position_with_offset )

func _set_road_map():
	road_map = owner.find_node( "roads" ) # TERRIBLE SOLUTION TO THIS
	assert( road_map )
	road_map_position_offset = road_map.cell_size * 0.5
	
	var road_positions = road_map.get_used_cells()
	for r in road_positions:
		if r.x <= 2 or r.y <= 2 or r.x >= 18 or r.y >= 9:
			continue
		var sideroadcount = 0
		if road_map.get_cellv( r + Vector2( 1, 0 ) ) > -1: sideroadcount += 1
		if road_map.get_cellv( r + Vector2( 1, 1 ) ) > -1: sideroadcount += 1
		if road_map.get_cellv( r + Vector2( 0, 1 ) ) > -1: sideroadcount += 1
		if road_map.get_cellv( r + Vector2( -1, 1 ) ) > -1: sideroadcount += 1
		if road_map.get_cellv( r + Vector2( -1, 0 ) ) > -1: sideroadcount += 1
		if road_map.get_cellv( r + Vector2( -1, -1 ) ) > -1: sideroadcount += 1
		if road_map.get_cellv( r + Vector2( 0, -1 ) ) > -1: sideroadcount += 1
		if road_map.get_cellv( r + Vector2( 1, -1 ) ) > -1: sideroadcount += 1
		if sideroadcount > 2:
			continue
		possible_hazard_positions.append( r )
#	print( "Hazard Positions: ", possible_hazard_positions )


func _spawn_portal():
	var portal_scn = preload( "res://hazards/portal.tscn" )
	var portal_positions = [ get_random_hazard_position() ]
	portal_positions.append( get_random_hazard_position( portal_positions[0] ) )
	print( "Spawning portal: ", portal_positions )
	var portal_1 = portal_scn.instance()
	var portal_2 = portal_scn.instance()
	
	portal_1.road_map = road_map
	portal_1.road_map_position_offset = road_map_position_offset
	portal_1._set_at_map_position( portal_positions[0] )
	portal_1.partner_portal = portal_2
	portal_1.lifetime = portal_lifetime
	
	portal_2.road_map = road_map
	portal_2.road_map_position_offset = road_map_position_offset
	portal_2._set_at_map_position( portal_positions[1] )
	portal_2.partner_portal = portal_1
	portal_2.lifetime = portal_lifetime
#	print( "adding portals at ", portal_1.position, portal_2.position )
	add_child( portal_1 )
	add_child( portal_2 )


func find_hazard_at( mappos : Vector2 ):
	for c in get_children():
		if not c is Hazard: continue
#		print( "checking ", mappos, " ", c.road_map_position, " ", c.name )
		if c is Hazard and c.road_map_position.is_equal_approx( mappos ):
			return c
	return null

func find_target_at( mappos : Vector2 ) -> bool:
#	return false
	var targets = owner.find_node( "target_spawn_position", true )
	for t in targets.get_children():
		if road_map.world_to_map( t.position ).is_equal_approx( mappos ):
			return true
	return false


func get_random_hazard_position( exclude : Vector2 = -Vector2.ONE ):
	var aux = possible_hazard_positions.duplicate( true )
	var positions = []
	for a in aux:
		if ( a - exclude ).length() < 4:
			continue
#		if find_hazard_at( a ) or find_target_at( a ):
		if find_hazard_at( a ):
			continue
		positions.append( a )
	if positions.empty():
		return null
	return positions[ randi() % positions.size() ]










