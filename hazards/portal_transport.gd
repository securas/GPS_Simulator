extends Particles2D

signal transport_finished

var VELOCITY = 50.0

var end_point : Vector2
var start_point : Vector2 = Vector2.UP * 8
var duration : float

func _ready():
	duration = end_point.length() / VELOCITY
	$tw.interpolate_property( self, "position",
		start_point, end_point, duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT )
	$tw.start()
	#amount = round( VELOCITY / 50.0 ) * 16
	speed_scale = sqrt( VELOCITY ) / sqrt( 50.0 )

func _on_tw_tween_all_completed():
	emitting = false
	$circle_particles.hide()
	$end_timer.start()


func _on_end_timer_timeout():
	emit_signal("transport_finished")
	queue_free()

func kill():
	queue_free()
