extends "res://Scenes/level.gd"

func _on_PortalShop_body_entered(_body):
  get_tree().get_root().get_node_or_null("/root/Base").LoadLevel("res://Scenes/Gameplay/Store.tscn")
