extends BaseMap

func _ready():
	var _ret = sigmr.connect("npc_wait", self, "_on_npc_wait", [], CONNECT_ONESHOT )



func _on_npc_wait( _npc ):
	$tutorial/tutanim.play("start")

