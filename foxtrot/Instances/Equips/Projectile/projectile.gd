extends KinematicBody2D

export(int) var damage = 0
export(float) var knockback = 0

export(float) var gravity = 3000.0
export(float) var speed = 2000.0
export(Vector2) var velocity = Vector2( 200.0, -400.0 )

func _physics_process(delta):
  velocity.y += gravity * delta
  velocity = move_and_slide( velocity, Vector2.UP )

func SetProjectileDirection(new_direction : Vector2):
  # Param(s) : direction is a normalized vector in which the projectile should move
  # Purpose  : 
  # Return(s):
  velocity = speed * new_direction
  self.rotation = new_direction.angle()

func _on_CollisionDetector_body_shape_entered(_body_id, _body, _body_shape, _local_shape):
  self.visible = false
  yield(get_tree().create_timer(0.1), "timeout")
  self.queue_free()
