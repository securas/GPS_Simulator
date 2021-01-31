extends Node2D
class_name MapElement


var road_map : TileMap
var road_map_position : Vector2
var road_map_position_offset : Vector2


func _set_at_map_position( mappos : Vector2 ) -> void:
	road_map_position = mappos
	position = _get_position_from_map_position( mappos )


func _get_position_from_map_position( mappos : Vector2 ) -> Vector2:
	return road_map.map_to_world( mappos ) + road_map_position_offset
