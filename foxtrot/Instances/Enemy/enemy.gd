extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
\
var health : int = 100;
var damage : int = 10;
var detectionRange : float = 25;

var gravity  : = 3000.0

# speed.x is LEFT and RIGHT, speed.y is UP and DOWN.
var speed    : = Vector2( 200.0, 800.0 )

# "velocity" is how fast the player is moving along the X and Y
#   axes at present.  (It starts at ZERO since the player is
#   initially not moving.)
var velocity : = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _physics_process(delta: float) -> void:
  velocity.y += gravity * delta
  #pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass
