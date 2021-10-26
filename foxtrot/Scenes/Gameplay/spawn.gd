extends "res://Scenes/level.gd"

func _enter_tree():
  Globals.isInSpawn = true
  
func _exit_tree():
  Save.save_file()
  Globals.isInSpawn = false

func _on_PortalShop_body_entered(_body):
  Signals.emit_signal("on_change_base_level", "res://Scenes/Gameplay/Store.tscn")
