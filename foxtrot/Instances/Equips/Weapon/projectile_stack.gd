extends "res://Instances/Equips/item_stack.gd"

export(int) var damage = 1

# Automatic weapons are expected to have an AnimationPlayer that triggers the Use function
export(bool) var is_automatic = false

export(String, FILE) var projectile

func _ready():
  if projectile == null: printerr("[ProjectileStack] Could not find projectile to spawn. Was it assigned?...")
  projectile = load(projectile)

func _process_input(event):
  if is_automatic:
    if event.is_action_pressed("fire") && not in_cooldown:
      $Sprite/AnimationPlayer.play("reload")
  else:
    ._process_input(event)

func _draw():
  draw_line(self.position, get_local_mouse_position(), Color.red)  
  
  update()
  
func Use():
  # Do not allow item usage if no player is using it.
  # Probably should disable object processing until in use...
  if player_inv == null: return
  
  if in_cooldown: return
  
  if not Input.is_action_pressed("fire"):
    $Sprite/AnimationPlayer.play("idle")
    return
  
  if is_automatic:
    in_cooldown = true
  
  # Decrement the item because we used it
  if not isInfiniteUse:
    curr_stack_amt -= 1
  
    # Inform UI to update current stack amount
    player_inv.RefreshInventoryForItemInUse()
  
  var player = self.get_tree().get_root().get_node_or_null("/root/Base/Player")
  
  # Spawn projectile
  var instance = projectile.instance()
  
  # The individual projectiles have their own damage, but we can add a damage multiplier to them.
  #instance.damage = self.damage
  
  # Calculate the trajector of the projectile
  var direction = (get_global_mouse_position() - self.get_global_transform().get_origin()).normalized()
  
  # Need to make it work with controller
  # Vector2(Input.get_joy_axis(0, JOY_ANALOG_RX), Input.get_joy_axis(0, JOY_ANALOG_RY)).normalized()
  
  instance.SetProjectileDirection(direction)
  instance.set_global_position(self.global_position)
  player.get_parent().add_child(instance)
  
  # If no more projectiles are present, delete this item
  if curr_stack_amt == 0:
    if player_inv.RemoveItem(self) == OK:
      self.queue_free()
    else:
      printerr("[ItemStack] Error. Failed to remove item from player inventory...")

# Note to self: instantiating an instance is not enough. You must also set a
# parent for it or else it won't appear in the scene.
