extends KinematicBody2D

# How much damage the projectile does
export(int) var damage = 0

# How much knockback the projectile does (in terms of force)
export(float) var knockback = 0

# Gravity of the projectile
export(float) var gravity = 3000.0

# The initial speed of the projectile
export(float) var speed = 2000.0

# The velocity of the projectile. Determined by its speed and direction
var velocity = Vector2( 200.0, -400.0 )

# Particle to emit on projectile collide
onready var particle_emitter = get_node_or_null("Particles2D")

func _physics_process(delta):
  velocity.y += gravity * delta
  velocity = move_and_slide( velocity, Vector2.UP )

func SetProjectileDirection(new_direction : Vector2):
  # Purpose  : Set the direction in which to fire the projectile
  # Param(s) : direction is a normalized vector in which the projectile should move
  # Return(s): N/A
  velocity = speed * new_direction
  self.rotation = new_direction.angle()

func _on_CollisionDetector_body_shape_entered(_body_id, _body, _body_shape, _local_shape):
  # Purpose   : Detects collision and destroys the projectile.
  # Param(s)  : N/A
  # Return(s) : N/A
  
  # The collision is hit and should be gone after hitting the enemy or a wall or something
  self.visible = false
  
  # If the item emits particles, emit on collision
  if particle_emitter:
    particle_emitter.SpawnParticles(self.global_position)
  
  # Destroy this item after the item has hit whatever
  self.queue_free()
