extends "res://Instances/Equips/item.gd"

# The ID of the seashell
# 0 : common, 1 : uncommon, 2 : rare, 3 : epic, 4 legendary, 5 ultimate
export var seashell_id : int = 0

# The quanity to provide on shell pickup
export var amount      : int = 1

func _on_Seashell_Collider_body_entered(body):
  # Purpose   : Used to let the player pick up the item and place it in the player inventory
  # Param(s)  : N/A
  # Return(s) : N/A
  
  Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/coin_collect.wav", 1)
  
  # Update the number of seashells the player has
  body.AddSeashells(seashell_id, amount)
  queue_free()
