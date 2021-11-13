extends KinematicBody2D

export(int) var damage = 0
export(float) var knockback = 0

export(float) var gravity = 3000.0
export(float) var speed = 2000.0
export(Vector2) var velocity = Vector2( 200.0, -400.0 )

onready var particle_emitter = get_node_or_null("Particles2D")

func _ready():
  yield(get_tree().create_timer(8.0), "timeout")
  queue_free()

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
  # The collision is hit and should be gone after hitting the enemy or a wall or something
  self.visible = false
  
  # If the item emits particles, emit on collision
  if particle_emitter:
    particle_emitter.SpawnParticles(self.global_position)
  
  # Destroy this item after the item has hit whatever
  self.queue_free()


