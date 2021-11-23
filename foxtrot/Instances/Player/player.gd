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
export var seashells = { 0 : 0, 1 : 0, 2 : 0, 3 : 0, 4 : 0, 5 : 0 }
var damage_multiplier = 1.0
var defense_stats = {}
var defense : int  = 0
# --------------------------------------------------------------------------------------------------
# Player Management Vars
# --------------------------------------------------------------------------------------------------
var direction : = Vector2(1,0)

var dash_direction = Vector2(1,0)
var can_dash = false
var dashing = false 
var dash_velocity = Vector2()

# Forward is defined to be facing towards the right
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
  # Dont allow player to do anything if game paused
  if Globals.pause_flags != 0: return
  
  # Orientate the player so they are always looking in the direction their mouse is at
  if event is InputEventMouseMotion:
    var player_orienatation = get_global_mouse_position().x - self.global_position.x
    if player_orienatation > 0:
      $AnimatedSprite.scale.x = 1
    else:
      $AnimatedSprite.scale.x = -1

func _init():
  # Used to enable/disable the inform box when a player touches something they can interact with
  if Signals.connect("on_interaction_changed", self, "ToggleInform") != OK:
    printerr("[Player] Error. Failed to connect to signal on_interaction_changed...")
    
  # Updates the player movement if they are on land or in the ocean
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
  if Globals.pause_flags != 0: return
  
  # If the player is in the middle of a jump (the Y velocity is
  #   less than zero, indicating the player is moving UP on the
  #   screen) and the user lets go of the JUMP key (detected using
  #   is_action_just_released()), we want to stop the jump and
  #   start falling again.
  var isJumpInterrupted : = Input.is_action_just_released("jump") and velocity.y == 0.0
  
  #   When LEFT and RIGHT are from the
  #   keyboard, direction.x = 1 (moving right),
  #   = -1 (moving left), = 0 (not moving along x)
  #   When LEFT and RIGHT are from a controller stick, direction.x
  #   = FLOAT value in the range [-1, 1] indicating the
  #   strength.

  # "direction.y" is 1 when the player is falling.
  # direction.y is -1 when the player has just started a JUMP.
  if Globals.is_in_spawn:
    direction = Vector2(
      Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
      -1 if Input.is_action_just_pressed("jump") and is_on_floor() else 1
    )
  else:
    direction = Vector2(
      Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
      -1 if Input.is_action_just_pressed("jump") else 1
    )
  
  if Input.is_action_just_pressed("jump"):
    Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/jump.ogg", 1)
  
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
    if Input.is_action_pressed("fall") and velocity.y < 300.0  :
      velocity.y += gravity * delta + 20
    else :
      velocity.y += gravity * delta
  # --------------------------------------------------------------
  
  # Now that we know what our velocity is, we tell Godot to move
  #   us at that speed (in the X and Y directions).  The
  #   move_and_slide() function takes "delta" into account
  #   automatically so we will move just how much we are supposed
  #   to since the time of the last frame.

  # move_and_slide() also takes into account collisions.
  dash()
  
  if dash_velocity != Vector2.ZERO:
    dash_velocity = dash_velocity.linear_interpolate(Vector2.ZERO, delta*10)

  # true parameter is for stopping on slopes
  velocity = move_and_slide( velocity+dash_velocity, Vector2.UP, true)
  
  if velocity.y < 0:
    $AnimatedSprite.play("jumping")
  elif direction.x != 0:
    $AnimatedSprite.play("running")
  else:
    $AnimatedSprite.play("idle")
# --------------------------------------------------------------------------------------------------
# Player Functions
# --------------------------------------------------------------------------------------------------
func ResetPlayer():
  # Purpose   : Resets the status of the player to a fresh new player
  # Param(s)  : 
  # Return(s) : N/A
  
  Globals.SetFlag(Globals.FLAG_DEAD, false)
  
  health = maxHealth
  health_bar.value = health
  health_label.text = "%d / %d" % [health, maxHealth]
  
  $AnimationPlayer.play("idle")
  
  # Implement: Reset stamina/magic as well
  
  RefreshStats()

func TakeDamage(damage : int):
  # Purpose   : Makes the player take damage.
  # Param(s)  : 
  # - damage  : the amount of damage to take.
  # Return(s) : N/A
  
  Signals.emit_signal("on_damage_taken", damage, self.global_position)
  damage -= defense
  if damage < 0:
    damage == 0
  
  health -= damage
  $AnimationPlayer.play("damaged")
  
  Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/damage.wav", 1)
  
  RefreshHealth()
  if health <= 0:
    # Audio queue of death
    Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/death.wav", 1)
    
    # Pause part of the game by setting the death flag
    Globals.SetFlag(Globals.FLAG_DEAD, true)
    
    # Play an animation to show the player's death
    $AnimationPlayer.play("death")    
    yield(get_tree().create_timer(2), "timeout")
    
    # If the player is on hardcore difficulty, they will lose all items on death
    if Globals.is_hardcore_mode:
      $AnimatedSprite/Inventory.EraseInventory()
    
    # Signal to the game that the player has died to set up the death scene
    Signals.emit_signal("on_player_death")
    
    
func dash():
  if is_on_floor():
    can_dash = true
    
  if Input.is_action_pressed("move_right"):
    dash_direction = Vector2(1,0)
  if Input.is_action_pressed("move_left"):
    dash_direction = Vector2(-1,0)
    
  if Input.is_action_just_pressed("ui_dash") and can_dash:
    dash_velocity = dash_direction.normalized() * 1000
    can_dash = false
    dashing = true
    yield(get_tree().create_timer(0.2), "timeout")
    dashing = false
    
func UpdateMovement():
  if Globals.is_in_spawn:
    gravity  = 3000.0
    speed    = Vector2( 200.0, 800.0 )
  else:
    gravity  = 100.0
    speed    = Vector2( 200.0, 150.0 )
  
func Heal(health : int):
  # Purpose   : Resets the status of the player to a fresh new player
  # Param(s)  : 
  # - health  : the amount to heal for
  # Return(s) : N/A
  
  self.health += health
  if self.health > maxHealth:
    self.health = maxHealth
    
  RefreshHealth()

func AddDefense(key, value):
  # Purpose   : Adds defense resistance to the player
  # Param(s)  : 
  # - key     : the ID of the item adding the resistance
  # - value   : the value to add
  # Return(s) : N/A
  
  # Allow for accessory stacking since the player can have 3 of the same equipment stacked
  if defense_stats.has(key):
    defense_stats[key] += value
  else:
    defense_stats[key] = value
  UpdateDefense()

func RemoveDefense(key, value):
  # Purpose   : Remove defense resistance from the player
  # Param(s)  : 
  # - key     : the ID of the item adding the resistance
  # - value   : the value to remove
  # Return(s) : N/A
  
  # The player may have multiple accessories stack. Only subtract the original amount for one of them
  defense_stats[key] -= value
  
  # If after the subtraction, the defense value for that key is 0, then all duplicate items have been
  # unequipped also and we can discard the key
  if defense_stats[key] == 0:
    defense_stats.erase(key)
  UpdateDefense()
  
func UpdateDefense():

  defense = 0
  for key in defense_stats:
    defense += defense_stats[key] 
  Signals.emit_signal("on_defense_update")
  
func AddSeashells(key, amount):
  # Purpose   : Adds seashells to the player's storage
  # Param(s)  :
  # - key     : the ID of the seashell to add the given quantity
  # - amount  : the qunatity to add
  # Return(s) : N/A
  
  seashells[key] += 1
  Signals.emit_signal("on_seashell_update")
  
func HasSeashells(key, amount):
  # Purpose   : Checks if the player has sufficient seashells
  # Param(s)  :
  # - key     : the ID of the seashell to check
  # - amount  : the qunatity to check for
  # Return(s) : true if the player has enough seashells, false if not
  
  return false if seashells[key] - amount < 0 else true
  
func RemoveSeashells(key, amount):
  # Purpose   : Removes seashells from the player's storage
  # Param(s)  :
  # - key     : the ID of the seashell to remove from the given quantity
  # - amount  : the qunatity to remove
  # Return(s) : N/A
  
  seashells[key] -= amount
# --------------------------------------------------------------------------------------------------
# Dialogue Functions
# --------------------------------------------------------------------------------------------------
func ToggleInform(state):
  # Purpose   : Display the inform panel
  # Param(s)  :
  # - state   : the visibility state of the panel
  # Return(s) : N/A
  
  if state:
    $Inform.visible = true
    $InformPlayer.play("open")
  else:
    $InformPlayer.play("close")
    while $InformPlayer.is_playing():
      yield(get_tree(), "idle_frame")
    $Inform.visible = false
    
  # Play damage animation (which will also disable collision so the player does not take any more
  # damage and when it is re-enabled, if the player is still within contact with another collider, 
  # they will continue to take more damage). 

func _on_DamageDetector_body_entered(body):
  # Purpose   : Detect when an enemy has touched the player
  # Param(s)  : N/A
  # Return(s) : N/A
  
  TakeDamage(body.damage)

func _on_DamageDetector_area_entered(area):
  # Purpose   : Detect when an enemy has touched the player
  # Param(s)  : N/A
  # Return(s) : N/A
  
  TakeDamage(area.damage)
# --------------------------------------------------------------------------------------------------
# Save Functions
# --------------------------------------------------------------------------------------------------
func RestorePlayerData(data):
  # Purpose   : Restore palyer information
  # Param(s)  :
  # - data    : a dictionary holding the player's attribute values
  # Return(s) : N/A
  
  Globals.is_hardcore_mode = data[Globals.PLAYER_DIFFICULTY]
  self.health = int(data[Globals.PLAYER_HEALTH])
  self.mana   = int(data[Globals.PLAYER_MANA])
  self.charname = data[Globals.PLAYER_NAME]
  self.money = data[Globals.PLAYER_MONEY]
# --------------------------------------------------------------------------------------------------
# UI Functions
# --------------------------------------------------------------------------------------------------
func RefreshHealth():
  # Purpose   : Refresh the health UI for the player
  # Param(s)  : N/A
  # Return(s) : N/A
  
  health_bar.value = health
  health_label.text = "%d / %d" % [health_bar.value, maxHealth]
  
func RefreshMana():
  # Purpose   : Refresh the mana UI for the player
  # Param(s)  : N/A
  # Return(s) : N/A
  pass
  
func RefreshStats():
  # Purpose   : Refresh all stats for the player
  # Param(s)  : N/A
  # Return(s) : N/A
  
  RefreshHealth()
  RefreshMana()
