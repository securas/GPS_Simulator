extends Node2D
var debug = false
var gamestate = {
	"score" : 0
}

var maplist = [
	"res://maps/level_01.tscn",
	"res://maps/level_21.tscn",
	"res://maps/level_02.tscn",
	"res://maps/level_11.tscn",
	"res://maps/level_04.tscn",
	"res://maps/level_13.tscn",
	"res://maps/level_03.tscn",
	"res://maps/level_05.tscn",
	"res://maps/level_06.tscn",
	"res://maps/level_12.tscn",
]


func _ready():
	Input.set_mouse_mode( Input.MOUSE_MODE_HIDDEN )
	var _ret = sigmr.connect( "start_game", self, "_on_start_game" )
	_ret = sigmr.connect( "quit_game", self, "_on_quit_game" )
	_ret = sigmr.connect( "load_map", self, "_on_load_map" )
	_ret = sigmr.connect( "restart_map", self, "_on_restart_map" )
	_ret = sigmr.connect( "load_next_map", self, "_on_load_next_map" )
	_ret = sigmr.connect( "update_score", self, "_on_update_score" )
	_ret = sigmr.connect( "return_to_start_screen", self, "_on_return_to_start_screen" )
	
	
	_ret = sigmr.connect( "ufo_landing", self, "_on_ufo_landing" )
	_ret = sigmr.connect( "npc_wait", self, "_on_npc_wait" )
	
	#audio 
#	$title_ambience.play()
#	$ufo_ambiance.play()
	
#	#CHEAT FOR DEBUG
#	if debug:
#		maplist = []
#		var dir = Directory.new()
#		dir.open("res://maps")
#		dir.list_dir_begin()
#		while true:
#			var file = dir.get_next()
#			if file == "":
#				break
#			elif file.begins_with( "level"):
#				print( "Adding level file: ", (dir.get_current_dir() + "/" + file) )
#				maplist.append( dir.get_current_dir() + "/" + file )
#		print( "Debug: added files: ", maplist )
		
	
	if not debug:
		$debug_layer/level_title.hide()
	
func _on_start_game():
	#todo: code to actually start the game
	gamestate.score = 0
	_on_load_map( "res://maps/level_01.tscn" )
	$click_sound.play()
	$fade_audio.play( "fade_out" )
	pass


func _on_update_score( new_score ):
	gamestate.score = new_score

func _on_return_to_start_screen():
	sigmr.emit_signal("load_map", "res://screens/title_screen.tscn" )

func _on_quit_game():
	get_tree().quit()


func _process(_delta):
	$mouse_layer/mouse_pointer.position = get_local_mouse_position()
	
	if Input.is_action_pressed("btn_debug_1") and \
		Input.is_action_just_released( "btn_debug_2" ):
			sigmr.emit_signal("load_next_map")

func _on_load_map( mapfile ):
	
	if debug:
		print( "Loading map: ", mapfile )
		$debug_layer/level_title.text = "level: " + mapfile
	
	get_tree().paused = true
	$fade_layer/fade_anim.play( "fadeout" )
	$transition.play()
	yield( get_tree().create_timer( 0.5 ), "timeout" )
	$hud_layer/hud.hide()
	for c in $stage.get_children():
		c.queue_free()
	yield( get_tree().create_timer( 0.1 ), "timeout" )
	var newmap = load( mapfile ).instance()
	$stage.add_child( newmap )
	yield( get_tree().create_timer( 0.1 ), "timeout" )
	if newmap is BaseMap:
		$hud_layer/hud.reset_hud( newmap.time_left, newmap.save_requirement )
		$hud_layer/hud.show()
	$fade_layer/fade_anim.play( "fadein" )
	yield( get_tree().create_timer( 0.5 ), "timeout" )
	if newmap is BaseMap:
		$hud_layer/hud.start_map()
		yield( $hud_layer/hud, "ready_to_start" )
	get_tree().paused = false
	
	

func _on_restart_map():
	var mapfile = $stage.get_child(0).filename
	sigmr.emit_signal( "load_map", mapfile )
	pass

func _on_load_next_map():
	# find current map on list
	var cur_mapfile = $stage.get_child(0).filename
	var idx = maplist.find( cur_mapfile )
	if idx == maplist.size() - 1:
		sigmr.emit_signal( "load_map", "res://screens/thankyou_screen.tscn" )
		return
	var nxt_idx = ( idx + 1 ) % maplist.size()
	sigmr.emit_signal( "load_map", maplist[nxt_idx] )



#made this so ufo landing sound doesn't overlap
func _on_ufo_landing():
	if not $ufo_landing.playing:
		$ufo_landing.play()

#made this so audio multiple audio doesn't go off at the same time
func _on_npc_wait( _npc ):
	if not $npc_wait.playing:
		$npc_wait.play()
	else:
		pass












