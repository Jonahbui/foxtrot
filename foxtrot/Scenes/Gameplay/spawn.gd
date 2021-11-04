extends "res://Instances/level.gd"

func _enter_tree():
  Globals.is_in_spawn = true
  
func _exit_tree():
  Globals.is_in_spawn = false
