extends "res://Instances/Equips/item.gd"

export var value : int = 1

func _on_CoinCollider_body_entered(body):
  Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/coin_collect.wav", 1)
  
  print_debug("[Coin] Adding %d to player wallet [%d]" % [value , body.money])
  body.money += value
  Signals.emit_signal("on_money_update")
  queue_free()
