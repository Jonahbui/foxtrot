extends "res://Instances/Equips/item.gd"

# The quantity to add on coin pickup
export var value : int = 1

func _on_CoinCollider_body_entered(body):
  # Purpose   : Used when the player's body enters the coin's body
  # Param(s)  : N/A
  # Return(s) : N/A
  
  Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/coin_collect.wav", 1)

  print_debug("[Coin] Adding %d to player wallet [%d]" % [value , body.money])

  # Add the money to the player's wallet  
  body.money += value
  
  # Signal to update the UI
  Signals.emit_signal("on_money_update")
  
  # Destroy the coin
  queue_free()
