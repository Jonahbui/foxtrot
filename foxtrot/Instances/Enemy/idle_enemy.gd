extends Enemy


func Move():
  if not is_on_floor():
    direction.y += 0
  isProjectileActive = true;

  if projectile == null: printerr("[ProjectileStack] Could not find projectile to spawn. Was it assigned?...")
  projectile = load(projectile)
  
func _process_input(event):
    if event.is_action_pressed("fire"):
      $Sprite/AnimationPlayer.play("reload")
    else:
      ._process_input(event)

func _draw():
  draw_line(self.position, player.position, Color.red)  
  update()
  
func _on_use():
  # Get the enemy to calculate the projectiles physics
  var enemy = Globals.Enemy()
  
  # Spawn projectile
  var instance = projectile.instance()
  
  # Calculate the trajector of the projectile
  var direction = (player.position - position).normalized()
    

  # Set the projetile direction to be where the item is on the player
  instance.SetProjectileDirection(direction)
  instance.set_global_position($Sprite/ProjectileSpawnpoint.global_position)
  enemy.get_parent().add_child(instance)
  
  # Return success
  return true
  
