extends "res://Instances/level.gd"

func _enter_tree():
  # The store is considered part of spawn
  Globals.isInSpawn = true
  
func _exit_tree():
  Globals.isInSpawn = false
