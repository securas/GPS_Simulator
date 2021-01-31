extends MapElement
class_name NPC

signal reached_tile( npc, tilepos )

enum States { WAITING, MOVING, PLAYER_DECISION, DEAD, REACHED_GOAL, HAZARD }
var state_cur : int = -1
var state_nxt : int = States.MOVING

var dir_cur := Vector2.RIGHT
var dir_nxt := Vector2.RIGHT

var anim_cur := ""
var anim_nxt := "idle"

var target_node : TargetDestination
var time_to_travel_on_tile := 0.35 # need to ask hazard

# variables for the player decision state
var running_timer := false
var arrow_pressed : bool

# to find hazards
var hazards

onready var sprites = [
	preload( "res://assets/art/npcs.png" ),
	preload( "res://assets/art/girl_npcs.png" ),
	preload( "res://assets/art/hamburger_npcs.png" ),
	preload( "res://assets/art/boy_npcs.png" ),
	preload( "res://assets/art/cook_npcs.png" ),
]

onready var arrows = [
	$arrows/arrow_right,
	$arrows/arrow_down,
	$arrows/arrow_left,
	$arrows/arrow_up
]



func _ready():
	dir_cur = dir_nxt
	_update_direction()
	for a in arrows:
		var _ret = a.connect( "arrow_pressed", self, "_on_arrow_pressed" )
#		_ret = a.connect( "mouse_entered", self, "_on_show_target_mouse_entered" )
#		_ret = a.connect( "mouse_exited", self, "_on_show_target_mouse_exited")
	set_physics_process( false )
#	_on_show_target_mouse_exited()
	
	


func activate( new_texture : bool = true ):
	if new_texture:
		$npcs.texture = sprites[ randi() % sprites.size() ]
	$npcs.position.y = -round( ( $npcs.texture.get_height() - 16 ) * 0.5 )
	_begin_state_moving()
	set_physics_process( true )
#	$line_to_target.show()
	target_node.is_active = false
	yield( get_tree(), "physics_frame" )
	yield( get_tree(), "physics_frame" )
	yield( get_tree(), "physics_frame" )
	target_node.show()
	enable_shadow( true )

func enable_shadow( a : bool = true ):
	$npcs.material.set_shader_param( "disable_shadows", not a )



func _physics_process( delta : float ) -> void:
	state_cur = state_nxt
	match state_cur:
		States.MOVING:
			_state_moving()
		States.WAITING:
			_state_waiting( delta )
		States.PLAYER_DECISION:
			_state_player_decision()
		States.REACHED_GOAL:
			_state_reached_goal( delta )
		States.HAZARD:
			_state_hazard()
		States.DEAD:
			_state_dead( delta )
	$line_to_target.update_line( target_node.global_position )
	
	if ( ( global_position - get_global_mouse_position() ).length() < 24 or \
			state_cur == States.PLAYER_DECISION ):
		target_node.is_active = true
		$line_to_target.show()
	else:
		target_node.is_active = false
		$line_to_target.hide()

func _update_direction():
	dir_cur = dir_nxt
	if abs( dir_cur.x ) > 0.5:
		$npcs.scale.x = sign( dir_cur.x )





#----------------------------------
# moving state
#----------------------------------
func _begin_state_moving():
#	print( name, " moving")
	state_nxt = States.MOVING
	var nxt_tile_map_position = road_map_position + dir_cur
	$anim.play("run")
	$motion_tween.stop_all()
	$motion_tween.remove_all()
	$motion_tween.interpolate_property(
		self, 'position',
		_get_position_from_map_position( road_map_position ),
		_get_position_from_map_position( nxt_tile_map_position ),
		time_to_travel_on_tile, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	$motion_tween.start()

func _state_moving():
	# do nothing
	pass

func _on_motion_tween_tween_all_completed():
	# update position in map
	road_map_position += dir_cur
	emit_signal( "reached_tile", self, road_map_position )
	
	# check if anything is happening in this tile
	if _react_to_tile( road_map_position ):
		return
	
	if not _get_next_tile():
		return
	
	# restart the moving state to move to the next tile
	_begin_state_moving()





func _react_to_tile( _mappos : Vector2 ) -> bool:
	# check if reached target
	if road_map_position.is_equal_approx( target_node.road_map_position ):
		_begin_state_reached_goal()
		return true
	
	# check for hazards
	var hazard = hazards.find_hazard_at( road_map_position )
	if hazard and hazard.action( self ):
		return true
	
	# do nothing
	return false


func _get_next_tile() -> bool:
	# check tiles around npc to decide where to go
	var tile_position_offsets = [
		dir_cur, # front
		dir_cur.rotated( -PI / 2).round(), # left
		dir_cur.rotated( PI / 2).round() # right
	]
	var road_tiles_counter := 0
	var tile_positions_with_road := []
	var directions_with_road := []
	for tp in tile_position_offsets:
		var cur_tile = road_map.get_cellv( road_map_position + tp )
		if cur_tile > -1:
			road_tiles_counter += 1
			tile_positions_with_road.append( tp )
			directions_with_road.append( tp )
	
	if road_tiles_counter == 0:
		dir_nxt = dir_cur.rotated( PI ).round()
		_update_direction()
		return true
	elif road_tiles_counter == 1:
		dir_nxt = directions_with_road[0]
		_update_direction()
		if _busy_front_tile( road_map_position + dir_nxt ):
			_begin_state_waiting()
			return false
		return true
	_begin_state_player_decision( directions_with_road )
	return false

func _busy_front_tile( front_tile_pos : Vector2 ):
	var npc_in_front = get_parent().check_npcs_at( front_tile_pos )
#	print( "NPC IN FRONT: ", npc_in_front )
	if not npc_in_front: return false
#	if npc_in_front.dir_cur.is_equal_approx( dir_cur ):
#		return false
#	if npc_in_front.state_cur == States.WAITING or \
#		npc_in_front.state_cur == States.PLAYER_DECISION or \
#		npc_in_front.state_cur == States.REACHED_GOAL:
#			return true
	if npc_in_front.state_cur == States.WAITING and \
		npc_in_front.dir_cur.is_equal_approx( dir_cur ):
			return true
	if npc_in_front.state_cur == States.PLAYER_DECISION:
		return true
	return _check_decision_tile( front_tile_pos )
#	return false


func _check_decision_tile( tilepos : Vector2 ) -> bool:
	# check tiles around npc to decide where to go
	var tile_position_offsets = [
		dir_cur, # front
		dir_cur.rotated( -PI / 2).round(), # left
		dir_cur.rotated( PI / 2).round() # right
	]
	var road_tiles_counter := 0
#	var tile_positions_with_road := []
#	var directions_with_road := []
	for tp in tile_position_offsets:
		var cur_tile = road_map.get_cellv( tilepos + tp )
		if cur_tile > -1:
			road_tiles_counter += 1
	return ( road_tiles_counter > 1 )



#----------------------------------
# waiting state
#----------------------------------
var wait_timer : float
func _begin_state_waiting():
#	print( name, " waiting")
	state_nxt = States.WAITING
	$anim.play("idle")
	wait_timer = 1.0

func _state_waiting( delta ):
	wait_timer -= delta
	if wait_timer <= 0:
		wait_timer = 1.0
		if not _busy_front_tile( road_map_position + dir_nxt ):
			if _get_next_tile():
				_begin_state_moving()






#----------------------------------
# player decision state
#----------------------------------
func _begin_state_player_decision( directions_with_road : Array ):
#	print( name, " player decision")
	state_nxt = States.PLAYER_DECISION
	$anim.play("idle")
	running_timer = true
	$click_timer/click_timer_animation.play("run")
	$click_timer/click_timer_animation.queue("default")
	_activate_arrows( directions_with_road )
	#audio
	#if not $npc_wait.playing:
	#	$npc_wait.play()
	sigmr.emit_signal( "npc_wait", self )

func _state_player_decision():
	if arrow_pressed or not running_timer:
		_begin_state_moving()
		#audio
		$arrow_click.play()

func _activate_arrows( directions ):
	arrow_pressed = false
	for d in directions:
		for a in arrows:
			if a.direction.dot( d ) > 0.5:
				a.is_active = true

func _on_arrow_pressed( direction : Vector2 ):
	if not running_timer: return
	if arrow_pressed: return
	$click_timer/click_timer_animation.play("default")
	for a in arrows:
		a.is_active = false
	dir_nxt = direction
	_update_direction()
	arrow_pressed = true

func _on_click_timer_finished():
	running_timer = false # prevents user input
	var valid_dirs := []
	for a in arrows:
		if a.is_active:
			valid_dirs.append( a.direction )
			a.is_active = false
	dir_nxt = valid_dirs[ randi() % valid_dirs.size() ]
	_update_direction()
	


#----------------------------------
# Hazard state
#----------------------------------
func _begin_state_hazard():
	state_nxt = States.HAZARD
#	$line_to_target.hide()
	target_node.hide()
func _state_hazard():
	# do nothing
	pass



#----------------------------------
# Reached goal state
#----------------------------------
var goal_reached_timer : float
func _begin_state_reached_goal():
	state_nxt = States.REACHED_GOAL
	$anim.play( "idle" )
	var x = preload( "res://vfx/explosion.tscn" ).instance()
	x.position = position + Vector2.UP * 8
	get_parent().add_child( x )
	hide()
	target_node.hide()
	goal_reached_timer = 2.0
	sigmr.emit_signal("npc_reached_goal", self )
	#audio
	$npc_reached_goal_begin.play()

func _state_reached_goal( delta ):
	goal_reached_timer -= delta
	if goal_reached_timer <= 0:
		get_parent().set_npc_target_respawn_positions( self, target_node )
		_update_direction()
		show()
#		target_node.show()
		activate()
	pass

#----------------------------------
# dead goal state
#----------------------------------
var dead_timer : float
func _begin_state_dead():
	state_nxt = States.DEAD
	$anim.play("dead")
	dead_timer = 4.0
	sigmr.emit_signal( "npc_killed", self )
	#audio
	#$npc_reached_goal_begin.play()
func _state_dead( delta ):
	dead_timer -= delta
	if dead_timer <= 0:
		var x = preload( "res://vfx/explosion.tscn" ).instance()
		x.position = position + Vector2.UP * 4
		get_parent().add_child( x )
		
		get_parent().set_npc_target_respawn_positions( self, target_node )
		_update_direction()
		show()
#		target_node.show()
		activate()
	pass



func respawn():
	get_parent().set_npc_target_respawn_positions( self, target_node )
	_update_direction()
	show()
#	target_node.show()
	activate()



func get_road_map_position() -> Vector2:
	return road_map_position + ( dir_cur if $motion_tween.is_active() else Vector2.ZERO )



func _run_dust():
	var d = preload( "res://npcs/run_dust.tscn" ).instance()
	d.position = position + Vector2.RIGHT * dir_cur.x * 3.0 + Vector2.UP
	d.scale.x = $npcs.scale.x
	get_parent().add_child( d )


#func _on_show_target_mouse_entered():
#	target_node.is_active = true
#	$line_to_target.show()
#
#
#
#func _on_show_target_mouse_exited():
#	target_node.is_active = false
#	$line_to_target.hide()
