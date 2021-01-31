extends Hazard
class_name UFO


var is_active := false
export( float ) var lifetime = 10.0
var mynpc
var killed_npc := false

var start_timer : Timer

func _ready():
	$life_timer.wait_time = lifetime
	start_timer = Timer.new()
	start_timer.wait_time = lifetime * ( 1 + randf() )
	print( "Starting UFO in ", start_timer.wait_time )
	start_timer.one_shot = true
	var _ret = start_timer.connect("timeout",self,"_on_start_timer")
	add_child(start_timer)
	start_timer.start()

func _on_start_timer():
	$anim.play("start")
	#audio
	#if not $ufo_landing.playing:
	#	$ufo_landing.play()
	sigmr.emit_signal("ufo_landing")

func _set_active():
	is_active = true
	$life_timer.start()



func action( npc ) -> bool:
	if not is_active:
#		print( "ufo rejected action for ", npc )
		return false
	$life_timer.stop()
	is_active = false
	killed_npc = true
#	print( "UFO starting action for ", npc )
	npc._begin_state_hazard()
	#audio
	$ufo_abduction.play()
	
	$npc_tween.stop_all()
	$npc_tween.remove_all()
	$npc_tween.interpolate_property( npc, "position", \
		npc.position, position + $ufo.position, 3.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT )
	$npc_tween.start()
	
	npc.target_node.hide()
	mynpc = npc
	npc.enable_shadow( false )
	npc.get_node( "anim" ).play( "ufo" )
#	var p = preload( "res://hazards/portal_transport.tscn" ).instance()
#	p.end_point = partner_portal.position - position + Vector2.UP * 8
#	var _ret = p.connect( "transport_finished", self, "_on_transport_finished", [ npc ] )
#	$transports.add_child( p )
#	npc._begin_state_hazard()
#	npc.hide()
	return true



func _on_npc_tween_tween_all_completed():
	if mynpc:
		mynpc.respawn()
	mynpc = null
	$anim.play("end")
	if killed_npc:
		sigmr.emit_signal("npc_killed", null)



func _on_life_timer_timeout():
	is_active = false
	_on_npc_tween_tween_all_completed()

func _restart():
	killed_npc = false
	road_map_position = get_parent().get_random_hazard_position( road_map_position )
	position = road_map.map_to_world( road_map_position ) + road_map_position_offset * Vector2( 1, 2 )
	_ready()






