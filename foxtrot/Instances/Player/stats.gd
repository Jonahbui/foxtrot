extends Node

func _init():
  # Updates the money the player has
  if Signals.connect("on_money_update", self, "UpdateMoneyUI") != OK:
    printerr("[Stats] Error. Failed to connect to signal on_money_update...")
    
  # Updates the damage the player can do
  if Signals.connect("on_damage_update", self, "UpdateDamageUI") != OK:
    printerr("[Stats] Error. Failed to connect to signal on_damage_update...")
    
  # Update the defense resistance of the player
  if Signals.connect("on_defense_update", self, "UpdateDefenseUI") != OK:
    printerr("[Stats] Error. Failed to connect to signal on_defense_update...")
    
  # Update the amount of seashells the player has
  if Signals.connect("on_seashell_update", self, "UpdateSeashell") != OK:
    printerr("[Stats] Error. Failed to connect to signal on_seashell_update...")

func _ready():
  # Initalize UI
  UpdateMoneyUI()
  UpdateDamageMultiplierUI()
  UpdateDefenseUI()

func UpdateMoneyUI():
  # Purpose   : Update the current amount of money the player has
  # Param(s)  : 
  # Return(s) : N/A
  
  $PlayerInfoContainer/MoneyContainer/Label.text = "%d" % [Globals.Player().money]

func UpdateDamageMultiplierUI():
  # Purpose   : Update the amount of damage the player can deal
  # Param(s)  : 
  # Return(s) : N/A
  
  $PlayerInfoContainer/DamageMultiplierContainer/Label.text = "%0.2f" % [Globals.Player().damage_multiplier]
  
func UpdateDefenseUI():
  # Purpose   : Update the defense resistance of the player
  # Param(s)  : 
  # Return(s) : N/A
  
  $PlayerInfoContainer/DefenseContainer/Label.text = "%d" % [Globals.Player().defense]

func UpdateSeashell():
  # Purpose   : Update the amount of shells the player has
  # Param(s)  : 
  # Return(s) : N/A
  
  var player = Globals.Player()
  
  $ShellContainer/WhiteSeashellContainer/Label.text  = "%d" % [player.seashells[0]]
  $ShellContainer/GreenSeashellContainer/Label.text  = "%d" % [player.seashells[1]]
  $ShellContainer/BlueSeashellContainer/Label.text   = "%d" % [player.seashells[2]]
  $ShellContainer/PurpleSeashellContainer/Label.text = "%d" % [player.seashells[3]]
  $ShellContainer/YellowSeashellContainer/Label.text = "%d" % [player.seashells[4]]
  $ShellContainer/PinkSeashellContainer/Label.text   = "%d" % [player.seashells[5]]
