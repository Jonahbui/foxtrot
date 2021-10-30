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
  if Globals.pause_flags != 0 || Globals.isManagingInv:
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
  
func SetProcess(item_process : int, player_inv):
  match(item_process):
    Globals.ItemProcess.World:
      enable_gravity = true
      Helper.SetActive(self, true)
      player_inv = null
    Globals.ItemProcess.Player:
      enable_gravity = false
      self.player_inv = player_inv
    _:
      pass

func _on_PickupDetector_body_entered(body):
  isPlayerTouching = true
  player_body = body

func _on_PickupDetector_body_exited(_body):
  isPlayerTouching = false
  player_body = null

func ToJSON():
  # Purpose   : returns the important information needed to restore this item in a dictionary format. 
  # Param(s)  : N/A
  # Return(s) : A dictionary
  return {
    # Need to know what item to restore, signified by its ID
    Save.SAVE_ID : id,
   }
  
func FromJson(item):
  # Restore the id of the item
  self.id = item[Save.SAVE_ID]
