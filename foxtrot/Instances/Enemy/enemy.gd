extends KinematicBody2D
class_name Enemy
#Variables for enemy 
export var health : int = 100;
export var damage : int = 10;
export var detectionRange : float = 25;
export var gravity  : = 3000.0
export var runSpeed = 50
export var speed    : = Vector2 (150.0,1250.0)
export var velocity : = Vector2.ZERO
onready var player = get_node("/root/Base/Player")

var direction = Vector2.ZERO
var knockback_velocity = Vector2.ZERO

func _physics_process(delta):
  if player:
    direction = (player.position - position).normalized()
    move_and_slide(direction * runSpeed + knockback_velocity)
  
  if knockback_velocity != Vector2.ZERO:
    knockback_velocity = knockback_velocity.linear_interpolate(Vector2.ZERO, delta)
  #velocity.y += gravity * delta
  #velocity.y = move_and_slide(velocity,Vector2.UP).y
  #if is_on_wall():
   # velocity.x *= -1.0
  #velocity.y = move_and_slide(velocity,Vector2.UP).y
  
func TakeDamage(body):
  # Deal damage
  health -= body.damage
  print("[%s] Current health = %d. Damage taken = %d." % [body.get_name(), health, body.damage])
  
  # Deal knockback
  var direction = (self.get_global_transform().get_origin() - body.get_global_transform().get_origin()).normalized()
  knockback_velocity = direction * body.knockback
  
  # Case of death
  if health <= 0:
    # Play death animation and other crap here
    
    self.queue_free()

func _on_DamageDetector_body_entered(body):
  TakeDamage(body)


func _on_DamageDetector_area_shape_entered(area_id, area, area_shape, local_shape):
  # Apparently this signal disregards the masks set, so need another way to identify the area
  if area.is_in_group(Globals.GROUP_PLAYER_WEAPON_HITBOX) || area.is_in_group(Globals.GROUP_PLAYER_PROJECTILE_HITBOX):
    TakeDamage(area.get_parent())
