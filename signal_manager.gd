extends Node


func _ready():
	randomize()
	
# warning-ignore:unused_signal
signal start_game

# warning-ignore:unused_signal
signal quit_game

# warning-ignore:unused_signal
signal npc_reached_goal

# warning-ignore:unused_signal
signal load_map

# warning-ignore:unused_signal
signal restart_map

# warning-ignore:unused_signal
signal load_next_map

# warning-ignore:unused_signal
signal return_to_start_screen

# warning-ignore:unused_signal
signal npc_reached_destination

# warning-ignore:unused_signal
signal npc_killed

# warning-ignore:unused_signal
signal update_score

# warning-ignore:unused_signal
signal npc_wait

# warning-ignore:unused_signal
signal ufo_landing

