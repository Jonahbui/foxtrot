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


func _physics_process(delta):
  if player:
    var direction = (player.position - position).normalized()
    move_and_slide(direction * runSpeed)
  #velocity.y += gravity * delta
  #velocity.y = move_and_slide(velocity,Vector2.UP).y
  #if is_on_wall():
   # velocity.x *= -1.0
  #velocity.y = move_and_slide(velocity,Vector2.UP).y
  
  
  
