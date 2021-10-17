extends KinematicBody2D

export var damage : int = 0

var gravity  : = 3000.0
var speed    : = 2000.0
var velocity : = Vector2( 200.0, -400.0 )
var enable_gravity : = true

func _physics_process(delta):
  if enable_gravity:
    velocity.y += gravity * delta
  velocity = move_and_slide( velocity, Vector2.UP )

func SetProjectileDirection(new_direction : Vector2):
  # Param(s) : direction is a normalized vector in which the projectile should move
  # Purpose  : 
  # Return(s):
  velocity = speed * new_direction


func _on_CollisionDetector_body_shape_entered(_body_id, _body, _body_shape, _local_shape):
  self.queue_free()
