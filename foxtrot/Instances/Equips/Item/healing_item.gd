extends ItemStack

# How much health to restore
export var healing_amount : int = 10

func _on_use():
  # Restores the player's health
  Globals.Player().Heal(healing_amount)
  return true
