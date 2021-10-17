# The Player object is a kinematic body so it can be subject to
#   collisions.  We move it manually with move_and_slide().
extends KinematicBody2D

# --------------------------------------------------------------------------------------------------
# Player Information
# --------------------------------------------------------------------------------------------------
var charname : String = ""
var health : int = 100
var money  : int = 0
var damageMultiplier = 1.0
var inWater = false
var direction : = Vector2(1,0)

# Forward is defined to be right
var forward : bool = true

# --------------------------------------------------------------------------------------------------
# References
# --------------------------------------------------------------------------------------------------
onready var inventory = $UI/Inventory

# "gravity" is an acceleration:  it's that many units
#   per second per second.  It's positive because "down" on the
#   screen is the POSITIVE Y axis direction.
var gravity  : = 3000.0

# speed.x is LEFT and RIGHT, speed.y is UP and DOWN.
var speed    : = Vector2( 200.0, 800.0 )

# "velocity" is how fast the player is moving along the X and Y
#   axes at present.  (It starts at ZERO since the player is
#   initially not moving.)
var velocity : = Vector2.ZERO
# -------------------------------------------

func _input(event):
  if event.is_action_pressed("ui_inventory"):
    toggle_inventory()

func _physics_process(delta: float) -> void:
  # If the dev console is open then do not move.
  if Globals.pause_flags != 0 :
    return
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

func toggle_inventory():
  $UI/Inventory/Control.visible = !$UI/Inventory/Control.visible
  Globals.SetFlag(Globals.FLAG_INVENTORY, $UI/Inventory/Control.visible)
