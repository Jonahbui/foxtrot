extends KinematicBody2D

var player_inv : Node

export var id : int = -1
var isSingleUse : bool = false

var gravity  : = 3000.0
var speed    : = Vector2( 200.0, 800.0 )
var velocity : = Vector2.ZERO
var enable_gravity : = true

func _physics_process(delta: float) -> void:
  if enable_gravity:
    velocity.y += gravity * delta
  velocity = move_and_slide( velocity, Vector2.UP )

func _input(event):
  if event.is_action_pressed("fire") && Globals.pause_flags == 0:
    Use()

func Use():
  pass
  
func SetProcess(item_process):
  if item_process == Globals.ItemProcess.World:
    enable_gravity = true
  elif item_process == Globals.ItemProcess.Player:
    enable_gravity = false
  else:
    pass
