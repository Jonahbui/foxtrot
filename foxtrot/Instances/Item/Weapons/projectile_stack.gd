extends "res://Instances/Item/Weapons/weapon_stack.gd"

export(String, FILE) var projectilePath
var projectile

func _ready():
  projectile = load(projectilePath)
  
func Use():
  # Do not allow item usage if no player is using it.
  # Probably should disable object processing until in use...
  if player_inv == null: return
  
  curr_stack_amt -= 1
  
  # Spawn projectile
  var instance = projectile.instance()
  instance.damage = self.damage
  self.get_tree().get_root().get_node_or_null("/root/Base/Player").add_child(instance)
  
  # If no more projectiles are present, delete this item
  if curr_stack_amt == 0:
    if player_inv.RemoveItem(self) == OK:
      self.queue_free()
    else:
      print("[ItemStack] Error. Failed to remove item from player inventory.")


# Note to self: instantiating an instance is not enough. You must also set a
# parent for it or else it won't appear in the scene.
