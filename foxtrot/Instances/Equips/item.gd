extends KinematicBody2D

var player_inv : Node = null

var isPlayerTouching : bool = false
onready var player_body = null

# The id of the item. We do not manually assign each id since the ID's could possibly change
# The equips.gd and inventory.gd script will handle ID's
export var id : int = -1

# Set the process of the item on it's Ready()
export var override_process : bool = false

# The process to set the item
export var process : int = 0

# Determines if the item is only supposed to be used once. If so, the item will be destroyed after
# it's first use
var is_single_use : bool = false

# Determines if the item has entered a cooldown state and cannot be used.
var in_cooldown : bool = false

# Physics vars
## Gravity to apply to the item
export var gravity  : = 3000.0
## Velocity of the item
export var velocity : = Vector2.ZERO

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
  # Purpose   : Processes input...
  # Param(s)  : an input event
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
  # Purpose   : The action the item takes if the player uses it
  # Param(s)  : N/A
  # Return(s) : N/A
  pass
  
func Pickup():
  # Purpose   : Used to let the player pick up the item and place it in the player inventory
  # Param(s)  : N/A
  # Return(s) : N/A
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
      # Enable visibility so the player can see the item
      # Disable processing so it cannot be used since it is not equipped
      # Enable physics so that it may interact with gravity
      # Enable input so that the player can pick up the item
      Helper.SetActive(self, true, false, true, true)
    
    # Hidden is used when the item is in the player inventory but not active
    Globals.ItemProcess.Hidden:
      self.player_inv = player_inv
      # Enable visibility so the player can see the item
      # Disable processing so it cannot be used since it is not equipped
      # Disable physics so that it does not interact with gravity
      # Disable input so that the player cannot use the item
      Helper.SetActive(self, false, false, false, false)
      
    # Active is used when the item is un the player inventory and is currently being used
    Globals.ItemProcess.Active:
      self.player_inv = player_inv
      # Enable visibility so the player can see the item
      # Enable processing so the player can use the item
      # Disable physics so that it does not interact with gravity
      # Enable input so that the player can use the item
      Helper.SetActive(self, true, true, false, true)
      
    # Static is used when the item is in the world but should not move from its location at all
    Globals.ItemProcess.Static:
      self.player_inv = null
      SetState(ItemState.Idle)
      # Enable visibility so the player can see the item
      # Disable processing so it cannot be used since it is not equipped
      # Disable physics so that it does not interact with gravity
      # Enable input so that the player can pick up the item
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
  # Purpose   : restores the information of a particular item
  # Param(s)  : a dictionary object containing the item's data
  # Return(s) : N/A
  
  # Restore the id of the item
  self.id = item[Save.SAVE_ID]

func ResetCooldown():
  # Purpose   : used for the AnimationPlayer. Resets the cooldown of an item after it's animation
  #             has finshed. It's cooldown duration is determined by it's animation duration
  # Param(s)  : N/A
  # Return(s) : N/A
  in_cooldown = false
  
func SetState(state):
  # Purpose   : Sets the state of the object
  # Param(s)  : an ItemState enum representing the desired state of the item
  # Return(s) : N/A
  match(state):
    ItemState.Idle:
      # Ensures that the item is not playing any animation when set idle
      in_cooldown = false
      
      # Stop the current animation of the item if present
      AnimationStop();
      
    _:
      pass


enum ItemState {
  Idle
 }

func AnimationStop():
  # Purpose   : Stops the animation on the current item.
  # Param(s)  : N/A
  # Return(s) : N/A
  pass
