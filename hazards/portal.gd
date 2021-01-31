extends Hazard
class_name Portal

var partner_portal
var is_active := false
var lifetime = 20.0


func _ready():
	$life_timer.wait_time = lifetime
	set_process( false )
	$portal_spawn.play()

func _set_active():
	is_active = true
	$life_timer.start()

func action( npc ) -> bool:
	if not is_active:
		return false
	print( "Starting action for ", npc )
	var p = preload( "res://hazards/portal_transport.tscn" ).instance()
	p.VELOCITY = 100
	p.end_point = partner_portal.position - position + Vector2.UP * 8
	var _ret = p.connect( "transport_finished", self, "_on_transport_finished", [ npc ] )
	$transports.add_child( p )
	npc._begin_state_hazard()
	npc.hide()
	#audio 
	$portal_in.play()
	
	return true

func _on_transport_finished( npc ):
	npc._set_at_map_position( partner_portal.road_map_position )
	npc.dir_nxt = _get_new_direction( npc.dir_cur, npc.road_map_position )
	npc._update_direction()
#	npc._get_next_tile()
	npc.activate( false )
	npc._begin_state_moving()
	npc.show()
	$portal_out.play()


func _get_new_direction( dir_cur : Vector2, mappos : Vector2 ):
	var directions = [
		Vector2.RIGHT,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.UP
	]
	var available_directions = []
	for d in directions:
		if road_map.get_cellv( mappos + d ) > -1:
			available_directions.append( d )
			if d.is_equal_approx( dir_cur ):
				return dir_cur
	return available_directions[0]






func _on_life_timer_timeout():
	is_active = false
	print( name, " end of life")
	set_process( true )

func _process( _delta ):
	# kill both portals when not busy
#	print( name, "waiting for children: ", $transports.get_child_count() )
	if $transports.get_child_count() == 0 and \
			partner_portal.get_node( "transports" ).get_child_count() == 0:
		set_process( false )
		$anim.play("end")

func end_life():
	queue_free()
