extends "res://Scenes/level.gd"

func _enter_tree():
  Globals.isInSpawn = true
  
func _exit_tree():
  Globals.isInSpawn = false
