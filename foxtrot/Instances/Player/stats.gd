extends Node

func _init():
  if Signals.connect("on_money_update", self, "UpdateMoneyUI") != OK:
    printerr("[Stats] Error. Failed to connect to signal on_money_update...")
  if Signals.connect("on_damage_update", self, "UpdateDamageUI") != OK:
    printerr("[Stats] Error. Failed to connect to signal on_damage_update...")
  if Signals.connect("on_defense_update", self, "UpdateDefenseUI") != OK:
    printerr("[Stats] Error. Failed to connect to signal on_defense_update...")

func UpdateMoneyUI():
  var player = get_node("/root/Base/Player")
  $PlayerInfoContainer/MoneyContainer/Label.text = "%d" % [player.money]

func UpdateDamageMultiplierUI():
  var player = get_node("/root/Base/Player")
  $PlayerInfoContainer/MoneyContainer/Label.text = "%d" % [player.damage_multiplier]
  
func UpdateDefenseUI():
  var player = get_node("/root/Base/Player")
  $PlayerInfoContainer/MoneyContainer/Label.text = "%d" % [player.defense]
