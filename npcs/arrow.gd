extends Sprite

signal arrow_pressed( dir )
signal mouse_entered
signal mouse_exited

export( Vector2 ) var direction = Vector2.RIGHT

var is_active := false setget _set_active

func _ready():
	_set_active( false )

func _on_TextureButton_pressed():
	if not is_active: return
	emit_signal( "arrow_pressed", direction )
	emit_signal( "mouse_exited" )

func _set_active( v : bool ):
	is_active = v
	modulate = Color.white
	if is_active:
		$btn.disabled = false
		show()
	else:
		$btn.disabled = true
		hide()


func _on_btn_mouse_entered():
	modulate = Color( "bf5c5c" )
	emit_signal( "mouse_entered" )


func _on_btn_mouse_exited():
	modulate = Color.white
	emit_signal( "mouse_exited" )
