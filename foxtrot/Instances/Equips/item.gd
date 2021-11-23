extends KinematicBody2D
class_name Item

# A reference to the player inventory
var player_inv : Node = null

# A reference to the player's body
onready var player_body = null

# True if the player's Area2D is touching the item
var is_touching : bool = false

# The id of the item. We do not manually assign each id since the ID's could possibly change during development
# The equips.gd and inventory.gd script will handle assigning ID's
export var id : int = -1

# Set the process of the item when node _ready() is called
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
  # Do not use the item in anyway if the game is paused.
  if Globals.pause_flags != 0: return
  
  # If the item is not in the player's inventory...
  if player_inv == null:
    # ...allow the player to pick up the item if the player is over the item.
    if player_body != null && event.is_action_pressed("interact"):
      # Need to check if player_body is not null because the player can possibly click and interact
      # after the body has exited and has been set to null.
      Pickup()
      
  # If the item is in the player's inventory...
  else:
    # Make sure to orientate towards the player's crosshair so the player can see where the item is 
    # targeting
    self.look_at(get_global_mouse_position())
    _process_input(event)

func _process_input(event):
  # Godot treats _input differently... cannot just override like other functions. _input is called in
  # every class. Doesn't override???
  
  if event.is_action_pressed("fire"):
    Use()

func _ready():
  # Set the shader on the item to be unique
  InitShader()
  
  if override_process:
    SetProcess(process, null)
    
func _physics_process(delta: float) -> void:
  if Globals.pause_flags != 0: return
  
  velocity.y += gravity * delta
  velocity = move_and_slide( velocity, Vector2.UP )

func Use():
  # Purpose   : Called when the player uses the item. Performs universal setup needed for all items
  # upon use
  # Param(s)  : N/A
  # Return(s) : N/A
  _on_use()
  
func _on_use():
  # Purpose   : The action the item takes if the player uses it
  # Param(s)  : N/A
  # Return(s) : true or false depending on if the item could be used or not.
  return true
  
func Pickup():
  # Purpose   : Used to let the player pick up the item and place it in the player inventory
  # Param(s)  : N/A
  # Return(s) : N/A
  
  Signals.emit_signal("on_inventory_add_item", self)
  Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/coin_collect.wav", 1)
  
func SetProcess(item_process : int, player_inv):
  # Purpose   : Controls what the item script processes
  # Param(s)  : N/A
  # Return(s) : N/A
  
  match(item_process):
    # Dynamic is used for the item when it is in the world
    Globals.ItemProcess.Dynamic:
      self.player_inv = null
      SetShader(true)
      SetState(ItemState.Idle)
      # Enable visibility so the player can see the item
      # Disable processing so it cannot be used since it is not equipped
      # Enable physics so that it may interact with gravity
      # Enable input so that the player can pick up the item
      Helper.SetActive(self, true, false, true, true)
    
    # Hidden is used when the item is in the player inventory but not active
    Globals.ItemProcess.Hidden:
      self.player_inv = player_inv
      SetShader(false)      
      # Enable visibility so the player can see the item
      # Disable processing so it cannot be used since it is not equipped
      # Disable physics so that it does not interact with gravity
      # Disable input so that the player cannot use the item
      Helper.SetActive(self, false, false, false, false)
      
      # Ensure item is in idle state to avoid triggering animations or other functions...
      SetState(ItemState.Idle)
      
    # Active is used when the item is un the player inventory and is currently being used
    Globals.ItemProcess.Active:
      self.player_inv = player_inv
      SetShader(false)      
      # Enable visibility so the player can see the item
      # Enable processing so the player can use the item
      # Disable physics so that it does not interact with gravity
      # Enable input so that the player can use the item
      Helper.SetActive(self, true, true, false, true)
      
    # Static is used when the item is in the world but should not move from its location at all
    Globals.ItemProcess.Static:
      self.player_inv = null
      SetShader(true)      
      SetState(ItemState.Idle)
      # Enable visibility so the player can see the item
      # Disable processing so it cannot be used since it is not equipped
      # Disable physics so that it does not interact with gravity
      # Enable input so that the player can pick up the item
      Helper.SetActive(self, true, false, false, true)
    _:
      pass

func _on_PickupDetector_body_entered(body):
  # Purpose   : Detects when the player body has entered the body of the item
  # Param(s)  : N/A
  # Return(s) : N/A
  
  # Ensures the player can pick up the item
  is_touching = true
  player_body = body

func _on_PickupDetector_body_exited(_body):
  # Purpose   : Detects when the player body leaves the body of the item
  # Param(s)  : N/A
  # Return(s) : N/A
  
  # Ensures the player can no longer pick up the item, since they aren't near it
  is_touching = false
  player_body = null

func ToJSON():
  # Purpose   : returns the important information needed to store this item in a dictionary format. 
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
  
  # On animation finish, reset the cooldown
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

func SetShader(state):
  # Purpose   : Sets the shader outline of the item.
  # Param(s)  : N/A
  # Return(s) : N/A
  
  var material = GetMaterial()
  var node = get_node_or_null("Sprite2")
  # Enables the outline
  if state:
    material.set_shader_param("precision", 0.02)
    
    # If the item uses an AtlasTexture, it will have a second node called Sprite2 with the shader
    # on it. Read reason why below, but show the sprite when outline is enabled.
    if node: node.visible = true
  else:
    material.set_shader_param("precision", 0.0)
    
    # Hide Sprite2
    if node: node.visible = false    

func GetMaterial():
  # Purpose   : Returns the outline shader on the item.
  # Param(s)  : N/A
  # Return(s) : N/A
  
  # Some textures use an AtlasTexture to display the item and the textures are cropped tightly for
  # each frame of the item. So the outline shader cannot work properly since it may use pixels from
  # outside the desired region of the item AtlasTexture or does not have enough space. As a solution,
  # we have a separate sprite on those items called Sprite2. This sprite holds a single frame of the
  # item in an idle state and has the outline.
  var node = get_node_or_null("Sprite2")
  if not node:
    node = get_node_or_null("Sprite")
  else:
    node.visible = true
  return node.material
  
func InitShader():
  # Purpose   : Ensures the outline shader on the item is unique. As to avoid them sharing values
  # resulting in multiple item's outline changing when a single item's outline changes.
  # Param(s)  : N/A
  # Return(s) : N/A
  GetMaterial().resource_local_to_scene = true

# Note:
# - All items are expected to have the outline shader attached
