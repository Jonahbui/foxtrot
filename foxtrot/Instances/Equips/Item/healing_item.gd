extends ItemStack

export var healing_amount : int = 10

func _on_use():
  Globals.Player().Heal(healing_amount)
  return true
