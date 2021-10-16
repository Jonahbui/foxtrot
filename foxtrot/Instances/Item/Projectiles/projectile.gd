extends KinematicBody2D

export var damage : int = 0

var gravity  : = 3000.0
var speed    : = Vector2( 1000.0, 800.0 )
var velocity : = Vector2( 200.0, -400.0 )
var enable_gravity : = true


func _physics_process(delta):
  # TA: Change to be direction player is facing
  var direction : = Vector2(1, -1)
  
  velocity.x = speed.x * direction.x
  
  if enable_gravity:
    velocity.y += gravity * delta
  velocity = move_and_slide( velocity, Vector2.UP )
  
  if is_on_floor():
    self.queue_free()
