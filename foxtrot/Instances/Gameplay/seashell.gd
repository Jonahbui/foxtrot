extends "res://Instances/Equips/item.gd"

export var seashell_id : int = 0
export var amount      : int = 1

func _on_Seashell_Collider_body_entered(body):
  body.AddSeashells(seashell_id, amount)
  queue_free()
