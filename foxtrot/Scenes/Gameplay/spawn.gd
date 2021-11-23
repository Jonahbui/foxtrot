extends "res://Instances/level.gd"

func _enter_tree():
  # If in spawn, signal to game since movement should be updated if in spawn
  Globals.is_in_spawn = true
  
func _exit_tree():
  Globals.is_in_spawn = false
