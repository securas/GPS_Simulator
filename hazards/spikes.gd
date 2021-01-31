extends Hazard

func action( npc ) -> bool:
	$anim.play("fire")
	$anim.queue("default")
	npc._begin_state_dead()
	var a = preload( "res://hazards/npc_angel.tscn" ).instance()
	a.position = npc.position - position
	a.scale.x = npc.get_node( "npcs" ).scale.x
	add_child( a )
	#audio
	$spike_attack.play()
	return true
