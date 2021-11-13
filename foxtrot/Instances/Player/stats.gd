extends Node

func _init():
  if Signals.connect("on_money_update", self, "UpdateMoneyUI") != OK:
    printerr("[Stats] Error. Failed to connect to signal on_money_update...")
  if Signals.connect("on_damage_update", self, "UpdateDamageUI") != OK:
    printerr("[Stats] Error. Failed to connect to signal on_damage_update...")
  if Signals.connect("on_defense_update", self, "UpdateDefenseUI") != OK:
    printerr("[Stats] Error. Failed to connect to signal on_defense_update...")

func _ready():
  UpdateMoneyUI()
  UpdateDamageMultiplierUI()
  UpdateDefenseUI()

func UpdateMoneyUI():
  $PlayerInfoContainer/MoneyContainer/Label.text = "%d" % [Globals.Player().money]

func UpdateDamageMultiplierUI():
  $PlayerInfoContainer/DamageMultiplierContainer/Label.text = "%0.2f" % [Globals.Player().damage_multiplier]
  
func UpdateDefenseUI():
  $PlayerInfoContainer/DefenseContainer/Label.text = "%d" % [Globals.Player().defense]
