extends "res://Instances/Equips/item_stack.gd"

export var healing_amount : int = 10

func _on_use():
  Globals.Player().Heal(healing_amount)
  return true