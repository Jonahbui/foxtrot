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
  
func _on_use():
  # If the item is not being used, set its animation to idle
  if not Input.is_action_pressed("fire"):
    $Sprite/AnimationPlayer.play("idle")
    return false
    
  # Do not allow usage if the item is in cooldown
  if in_cooldown: return false
  
  # If the item is automatic, apply a cooldown to it
  if is_automatic:
    in_cooldown = true
  
  # Get the player to calculate the projectiles physics
  var player = Globals.Player()
  
  # Spawn projectile
  var instance = projectile.instance()
  
  # The individual projectiles have their own damage, but we can add a damage multiplier to them.
  #instance.damage = self.damage
  
  # Calculate the trajector of the projectile
  var direction = (get_global_mouse_position() - self.get_global_transform().get_origin()).normalized()
    
  # Need to make it work with controller
  # Vector2(Input.get_joy_axis(0, JOY_ANALOG_RX), Input.get_joy_axis(0, JOY_ANALOG_RY)).normalized()
  
  # Set the projectile direction to be in the direction the player's crosshair is relatively.
  # Set the projetile direction to be where the item is on the player
  instance.SetProjectileDirection(direction)
  instance.set_global_position($Sprite/ProjectileSpawnpoint.global_position)
  player.get_parent().add_child(instance)
  
  # Return success
  return true

# Note to self: instantiating an instance is not enough. You must also set a
# parent for it or else it won't appear in the scene.
