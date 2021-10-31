extends "res://Instances/Equips/item_stack.gd"

export(int) var damage = 1

# Automatic weapons are expected to have an AnimationPlayer that triggers the Use function
export(bool) var is_automatic = false
var is_firing : bool = false

export(String, FILE) var projectile

func _ready():
  if projectile == null: print("[ProjectileStack] Could not find projectile to spawn. Was it assigned?")
  projectile = load(projectile)

func _input(event):
  if is_automatic:
    if event.is_action_pressed("fire"):
      is_firing = true
      $Sprite/AnimationPlayer.play("reload")
    elif event.is_action_released("fire"):
      is_firing = false
      $Sprite/AnimationPlayer.play("idle")
  else:
    ._input(event)
    

func _draw():
  draw_line(self.position, get_local_mouse_position(), Color.red)  
  
  update()
  
func Use():
  # Do not allow item usage if no player is using it.
  # Probably should disable object processing until in use...
  if player_inv == null: return
  
  # Decrement the item because we used it
  if not isInfiniteUse:
    curr_stack_amt -= 1
  
    # Inform UI to update current stack amount
    player_inv.RefreshInventoryForItemInUse()
  
  var player = self.get_tree().get_root().get_node_or_null("/root/Base/Player")
  
  # Spawn projectile
  var instance = projectile.instance()
  instance.damage = self.damage
  
  # Calculate the trajector of the projectile
  var direction = (get_global_mouse_position() - self.get_global_transform().get_origin()).normalized()
  
  instance.SetProjectileDirection(direction)
  player.add_child(instance)
  
  # If no more projectiles are present, delete this item
  if curr_stack_amt == 0:
    if player_inv.RemoveItem(self) == OK:
      self.queue_free()
    else:
      print("[ItemStack] Error. Failed to remove item from player inventory.")


# Note to self: instantiating an instance is not enough. You must also set a
# parent for it or else it won't appear in the scene.
