extends KinematicBody2D

var player_inv : Node = null

var isPlayerTouching : bool = false
onready var player_body = null

#
export var id : int = -1

#
export var override_process : bool = false
export var process : int = 0

#
var isSingleUse : bool = false

# 
var in_cooldown : bool = false

var gravity  : = 3000.0
var speed    : = Vector2( 200.0, 800.0 )
var velocity : = Vector2.ZERO

func _input(event):
  if Globals.pause_flags != 0 || Globals.is_managing_inventory: return
  
  if player_inv == null:
    if player_body != null && event.is_action_pressed("interact"):
      # Need to check if player_body is not null because the player can possibly click and interact
      # after the body has exited and has been set to null.
      Pickup()
  else:
    self.look_at(get_global_mouse_position())
    _process_input(event)

func _process_input(event):
  # Purpose   : 
  # Param(s)  : N/A
  # Return(s) : N/A
  
  # Godot treats _input differently... cannot just override like other functions. _input is called in
  # every class. Doesn't really override.
  
  if event.is_action_pressed("fire"):
    Use()

func _ready():
  if override_process:
    SetProcess(process, null)

func _physics_process(delta: float) -> void:
  if Globals.pause_flags != 0 || Globals.is_managing_inventory: return
  
  velocity.y += gravity * delta
  velocity = move_and_slide( velocity, Vector2.UP )

func Use():
  pass
  
func Pickup():
  Signals.emit_signal("on_inventory_add_item", self)
  
func SetProcess(item_process : int, player_inv):
  # Purpose   : Controls what the item script processes
  # Param(s)  : N/A
  # Return(s) : N/A
  match(item_process):
    # Dynamic is used for the item when it is in the world
    Globals.ItemProcess.Dynamic:
      self.player_inv = null
      SetState(ItemState.Idle)
      # Enable visibility
      # Enable 
      Helper.SetActive(self, true, true, true, true)
    
    # Hidden is used when the item is in the player inventory but not active
    Globals.ItemProcess.Hidden:
      self.player_inv = player_inv
      Helper.SetActive(self, false, false, false, false)
      
    # Active is used when the item is un the player inventory and is currently being used
    Globals.ItemProcess.Active:
      self.player_inv = player_inv
      Helper.SetActive(self, true, true, false, true)
      
    # Static is used when the item is in the world but should not move from its location at all
    Globals.ItemProcess.Static:
      self.player_inv = null
      SetState(ItemState.Idle)
      Helper.SetActive(self, true, false, false, true)
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
  
func FromJSON(item):
  # Restore the id of the item
  self.id = item[Save.SAVE_ID]

func ResetCooldown():
  in_cooldown = false
  
func SetState(state):
  match(state):
    ItemState.Idle:
      # Ensures that the item is not playing any animation when set idle
      in_cooldown = false
    _:
      pass


enum ItemState {
  Idle
 }
