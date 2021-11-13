# The Player object is a kinematic body so it can be subject to
#   collisions.  We move it manually with move_and_slide().
extends KinematicBody2D

# --------------------------------------------------------------------------------------------------
# Player Information
# --------------------------------------------------------------------------------------------------
export var charname : String = "default"
export var maxHealth : int = 100
export var health : int = 100
export var mana   : int = 100
export var money  : int = 0
var damage_multiplier = 1.0
var defense : int  = 0
# --------------------------------------------------------------------------------------------------
# Player Management Vars
# --------------------------------------------------------------------------------------------------
var direction : = Vector2(1,0)

# Forward is defined to be right
var forward : bool = true

# --------------------------------------------------------------------------------------------------
# References
# --------------------------------------------------------------------------------------------------
onready var health_bar = $Stats/UI/StatsVbox/Health/HealthBar
onready var health_label = $Stats/UI/StatsVbox/Health/HealthLabel
onready var mana_bar = $Stats/UI/StatsVbox/Mana/ManaBar
onready var mana_label = $Stats/UI/StatsVbox/Mana/ManaLabel
# "gravity" is an acceleration:  it's that many units
#   per second per second.  It's positive because "down" on the
#   screen is the POSITIVE Y axis direction.
var gravity  : = 100.0

# speed.x is LEFT and RIGHT, speed.y is UP and DOWN.
var speed    : = Vector2( 200.0, 150.0 )

# "velocity" is how fast the player is moving along the X and Y
#   axes at present.  (It starts at ZERO since the player is
#   initially not moving.)
var velocity : = Vector2.ZERO

# --------------------------------------------------------------------------------------------------
# Godot Functions
# --------------------------------------------------------------------------------------------------
func _input(event):
  if Globals.pause_flags != 0 : return
  
  if event is InputEventMouseMotion:
    var player_orienatation = get_global_mouse_position().x - self.global_position.x
    if player_orienatation > 0:
      $Sprite.scale.x = 1
    else:
      $Sprite.scale.x = -1

func _init():
  if Signals.connect("on_interaction_changed", self, "ToggleInform") != OK:
    printerr("[Player] Error. Failed to connect to signal on_interaction_changed...")
  if Signals.connect("on_level_loaded", self, "UpdateMovement") != OK:
    printerr("[Player] Error. Failed to connect to signal on_level_loaded...")

func _ready():
  # Set the player name to indicate which save is being played
  self.charname = Save.save[Globals.PLAYER_NAME]
  
  # Update the UI
  RefreshStats()
  
  # Tell the game that the player has been loaded
  Signals.emit_signal("on_player_loaded", self)
  
  # Update the movement of the player to match whatever level they are in
  UpdateMovement()

func _physics_process(delta: float) -> void:
  # If the dev console is open then do not move.
  if Globals.pause_flags != 0 : return
  # If the player is in the middle of a jump (the Y velocity is
  #   less than zero, indicating the player is moving UP on the
  #   screen) and the user lets go of the JUMP key (detected using
  #   is_action_just_released()), we want to stop the jump and
  #   start falling again.
  var isJumpInterrupted : = Input.is_action_just_released("jump") and velocity.y < 0.0
  
  #   When LEFT and RIGHT are from the
  #   keyboard, direction.x = 1 (moving right),
  #   = -1 (moving left), = 0 (not moving along x)
  #   When LEFT and RIGHT are from a controller stick, direction.x
  #   = FLOAT value in the range [-1, 1] indicating the
  #   strength.

  # "direction.y" is 1 when the player is falling.
  # direction.y is -1 when the player has just started a JUMP.
  direction = Vector2(
    Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
    -1 if Input.is_action_just_pressed("jump") and is_on_floor() else 1
   )
  
  # Whichever way we going along the X axis, our speed is that
  #   direction times speed.x
  velocity.x = speed.x * direction.x

  # JUMPING---------------------------------------------------
  # If we have just interrupted our jump, we instantly stop
  #   moving either up or down.  Our Y axis velocity is ZERO.
  if isJumpInterrupted :
    velocity.y = 0.0
    
  elif direction.y == -1 :
    # On the other hand, if we have just JUMPed, our Y axis
    #   velocity is whatever our JUMP speed is in the UP
    #   direction.  Remember, a jump means moving UP on the
    #   screen and that's the NEGATIVE Y direction.
    velocity.y = -speed.y
  else :
    # Otherwise, by default our Y axis velocity accelerates by
    #   however much gravity has worked on us since the last
    #   frame.  "delta" is the number of seconds since the last
    #   frame.  "gravity" is units per second per second.
    #   Multiplying the two gives us the amount that our falling
    #   speed has increased since the last frame so we add it in.
    if Input.is_action_pressed("fall") :
      velocity.y += gravity * delta + 20
    else :
      velocity.y += gravity * delta
  # --------------------------------------------------------------
  
  # Now that we know what our velocity is, we tell Godot to move
  #   us at that speed (in the X and Y directions).  The
  #   move_and_slide() function takes "delta" into account
  #   automatically so we will move just how much we are supposed
  #   to since the time of the last frame.

  # move_and_slide() also takes into account collisions.  It will
  #   detect if we have run into anything else (e.g., the ground)
  #   and ensure that we don't overrun anything we shouldn't.
  #   To inform us that happened, move_and_slide() returns a
  #   possibly adjusted velocity indicating whether we were
  #   stopped by a collision.  We use that updated info to change
  #   our version of velocity so we don't, e.g., keep trying to
  #   move DOWN on the screen after we've hit the floor.
  velocity = move_and_slide( velocity, Vector2.UP )
# --------------------------------------------------------------------------------------------------
# Player Functions
# --------------------------------------------------------------------------------------------------
func ResetPlayer():
  health = maxHealth
  health_bar.value = health
  health_label.text = "%d / %d" % [health, maxHealth]
  
  # Reset stamina/magic as well
  
  RefreshStats()

func TakeDamage(damage : int):
  health -= damage
  
  RefreshHealth()
  if health <= 0:
    # Play death animation
    
    # Disable player
    
    Signals.emit_signal("on_player_death")

func UpdateMovement():
  if Globals.is_in_spawn:
    gravity  = 3000.0
    speed    = Vector2( 200.0, 800.0 )
  else:
    gravity  = 100.0
    speed    = Vector2( 200.0, 150.0 )
    
func Heal(health : int):
  self.health += health
  if self.health > maxHealth:
    self.health = maxHealth
  RefreshHealth()
# --------------------------------------------------------------------------------------------------
# Player UI Functions
# --------------------------------------------------------------------------------------------------
func RefreshHealth():
  health_bar.value = health
  health_label.text = "%d / %d" % [health_bar.value, maxHealth]
  
func RefreshMana():
  pass
  
func RefreshStats():
  RefreshHealth()
  RefreshMana()
# --------------------------------------------------------------------------------------------------
# Player Save Functions
# --------------------------------------------------------------------------------------------------
func RestorePlayerData(data):
  Globals.is_hardcore_mode = data[Globals.PLAYER_DIFFICULTY]
  self.health = int(data[Globals.PLAYER_HEALTH])
  self.mana   = int(data[Globals.PLAYER_MANA])
  self.charname = data[Globals.PLAYER_NAME]
  self.money = data[Globals.PLAYER_MONEY]
# --------------------------------------------------------------------------------------------------
# Dialogue Functions
# --------------------------------------------------------------------------------------------------
func ToggleInform(state):
  # Display the inform panel
  $Inform.visible = state

func _on_DamageDetector_body_entered(body):
  TakeDamage(body.damage)
