extends KinematicBody2D
class_name Enemy

# Health of the enemy
export var health : int = 100

# Damage enemy inflicts when touching player
export var damage : int = 10

# Range where the enemy can see and shoot the player
export var detectionRange : float = 25

export var gravity  : = 3000.0
export var runSpeed = 50
export var speed    : = Vector2 (150.0,1250.0)
export var velocity : = Vector2.ZERO
var player = null

# How often the enemy can shoot the projectile
export var cooldown : float = 3.0

# Current cooldown time of the enemy
var current_cooldown : float = 0
var isPlayerPresent : bool = false


var direction = Vector2.ZERO
var knockback_velocity = Vector2.ZERO

# Loot table to reference on death
export(String) var loot_string

# Projectile to spawn when shooting
export(String, FILE) var projectile

# Determines whether the enemy should shoot projectiles or not
export var has_projectile : bool = false

func _ready():
  $PlayerDetector/CollisionShape2D.shape.radius = detectionRange
  
  player = Globals.Player()
  
  if projectile == null: printerr("[ProjectileStack] Could not find projectile to spawn. Was it assigned?...")
  if has_projectile:
    projectile = load(projectile)
  
func _physics_process(delta):
  if Globals.pause_flags != 0 : return
  
  if player:
    # Orientate enemy sprite to face the player
    var orienatation =  self.global_position.x - player.global_position.x
    if orienatation > 0:
      $AnimatedSprite.scale.x = 1
    else:
      $AnimatedSprite.scale.x = -1
    
    direction = (player.position - position).normalized()
    Move()
    if current_cooldown > 0:
      current_cooldown -= delta

    if has_projectile && isPlayerPresent && current_cooldown <=  0:
      Fire()
      current_cooldown = cooldown
  
  
  # After the enemy has taken knockback, decrease the knockback velocity until there is no
  # knockback anymore to prevent them from flying off infinitely away
  if knockback_velocity != Vector2.ZERO:
    knockback_velocity = knockback_velocity.linear_interpolate(Vector2.ZERO, delta)

func Move():
  move_and_slide(direction * runSpeed + knockback_velocity)
  
func TakeDamage(area):
  Signals.emit_signal("on_damage_taken", area.damage, self.global_position)
  
  # Play damage animation to show that enemy has been hurt
  $AnimationPlayer.play("damaged")
  Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/damage.wav", 1)
  
  # Deal damage
  health -= area.damage
  print_debug("[%s] Current health = %d. Damage taken = %d." % [area.get_name(), health, area.damage])
  
  # Deal knockback
  var direction = (self.get_global_transform().get_origin() - area.get_global_transform().get_origin()).normalized()
  knockback_velocity = direction * area.knockback
  
  # Case of death
  if health <= 0:
    # Play death animation and other crap here
    self.visible = false
    call_deferred("KillEnemy")

func _on_DamageDetector_area_entered(area):
  TakeDamage(area.get_parent())
func Fire():
  # Get the enemy to calculate the projectiles physics
  
  # Spawn projectile
  var instance = projectile.instance()
  
  # Calculate the trajectory of the projectile
  var direction = (player.get_global_position() - self.get_global_position()).normalized()

  # Set the projetile direction to be where the item is on the player
  instance.SetProjectileDirection(direction)
  instance.set_global_position($ProjectileSpawnpoint.global_position)
  self.get_parent().add_child(instance)
  print("fire")
  # Return success
  return true

func _on_PlayerDetector_body_entered(body: Node) -> void:
  isPlayerPresent = true
  
func KillEnemy():
  # Drop the item
  var loot = Loot.GenerateLoot(Loot.table[Loot.LOOT_ENEMY][loot_string])
  
  # You cannot add new Area2Ds to a scene during a call of another Area2Ds on_area_entered(). Using call_deferred() solves the problem. 
  self.get_node_or_null("/root/Base/Level/Items/").add_child(loot)
  loot.SetProcess(Globals.ItemProcess.Dynamic, null)
  loot.set_global_position(self.get_global_transform().get_origin())
  self.queue_free()
