extends Item
class_name Weapon

# Sound to play when weapon is used
export(String, FILE) var attack_sound

# Amount of damage to deal
export var damage : int = 0

# Amount of knockback to deal
export var knockback : float = 100

func _process_input(event):
  if event.is_action_pressed("fire") && not in_cooldown:
    $Sprite/AnimationPlayer.play("attack")

func _on_use():
  # If the player is no longer holding the fire button, stop shooting. Called by the AnimationPlayer
  # to attack. Once the animation finishes, the cooldown be turned off
  if not Input.is_action_pressed("fire"):
    $Sprite/AnimationPlayer.play("idle")
    return false

  # Prevent the player from using if in cooldown
  if in_cooldown: return false
  
  # Once the player uses the item, make them wait in a cooldown for the next use.
  in_cooldown = true

func AnimationStop():
  $Sprite/AnimationPlayer.play("idle")

func PlayAttack():
  # Purpose   : Used by the AnimationPlayer to help synchronize with sprite animations. Plays an 
  # attack sound
  # Param(s)  : N/A
  # Return(s) : N/A
  Signals.emit_signal("on_play_audio", attack_sound, 1)
  
func FromJSON(item):
  .FromJSON(item)
