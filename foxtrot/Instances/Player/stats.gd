extends Node

func _init():
  if Signals.connect("on_money_update", self, "UpdateMoneyUI") != OK:
    print("[Stats] Error. Failed to connect to signal on_money_update...")

func UpdateMoneyUI():
  var player = get_node("/root/Base/Player")
  $PlayerInfoContainer/MoneyContainer/Label.text = "%d" % [player.money]
