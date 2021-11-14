extends Item
class_name Armor

export var resistance : int = 1

func Equip():
  var player = Globals.Player()
  player.AddDefense(self.id, resistance)
  
func Unequip():
  var player = Globals.Player()
  player.RemoveDefense(self.id, resistance)
