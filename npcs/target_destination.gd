extends MapElement
class_name TargetDestination

var is_active := false setget _set_active
var is_close := false
var parent_npc

func _set_active( a : bool ):
	if is_close: return
	is_active = a
	if is_active:
		$anim.play("cycle")
	else:
		if $anim.current_animation != "default":
			$anim.play("default")


func _process(_delta):
	if not parent_npc: return
	var dist = ( parent_npc.position - position ).length()
	if dist < 32:
		is_close = true
		if $anim.current_animation != "cycle":
			$anim.play("cycle")
	else:
		if is_close == true:
			is_close = false
			if $anim.current_animation != "default":
				$anim.play("default")
