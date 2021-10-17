extends KinematicBody2D

var player_inv : Node = null

var isPlayerTouching : bool = false
onready var player_body = null

export var id : int = -1
var isSingleUse : bool = false

var gravity  : = 3000.0
var speed    : = Vector2( 200.0, 800.0 )
var velocity : = Vector2.ZERO
var enable_gravity : = true

var mousePos := Vector2.ZERO

func _physics_process(delta: float) -> void:
  if enable_gravity:
    velocity.y += gravity * delta
  velocity = move_and_slide( velocity, Vector2.UP )

func _input(event):
  if Globals.pause_flags != 0:
    return
  
  if event.is_action_pressed("fire"):
    mousePos = event.position
    Use()
  elif player_inv == null && player_body != null && event.is_action_pressed("interact"):
    # Need to check if player_body is not null because the player can possibly click and interact
    # after the body has exited and has been set to null.
    Pickup()

func Use():
  pass
  
func Pickup():
  player_body.inventory.AddItem(self)
  
func SetProcess(item_process : int):
  if item_process == Globals.ItemProcess.World:
    enable_gravity = true
    Helper.SetActive(self, true)
    player_inv = null
  elif item_process == Globals.ItemProcess.Player:
    enable_gravity = false
  else:
    pass

func _on_PickupDetector_body_entered(body):
  isPlayerTouching = true
  player_body = body

func _on_PickupDetector_body_exited(_body):
  isPlayerTouching = false
  player_body = null
