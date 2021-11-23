extends Item
class_name Armor

# How much damage points to reduce incoming damage
export var resistance : int = 1

func Equip():
  # Purpose   : Used to add to the player's defense
  # Param(s)  : N/A
  # Return(s) : N/A
  var player = Globals.Player()
  player.AddDefense(self.id, resistance)
  
func Unequip():
  # Purpose   : Used to remove the armor's defense resistance from the player's stats
  # Param(s)  : N/A
  # Return(s) : N/A
  var player = Globals.Player()
  player.RemoveDefense(self.id, resistance)
