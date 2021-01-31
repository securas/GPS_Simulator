extends Node2D

var c : Curve2D

func _ready():
	c = Curve2D.new()
	c.add_point(Vector2( 0, -8), Vector2.ZERO, Vector2.UP * 32 )
	c.add_point(Vector2.ZERO, Vector2.UP * 32, Vector2.ZERO )
	hide()
	
func update_line( target_gpos : Vector2 ):
	c.set_point_position( 1, target_gpos - global_position + Vector2( 0, -8) )
	update()


func _draw():
	var points = c.get_baked_points()
	draw_polyline( points, modulate, 2.0, false )
