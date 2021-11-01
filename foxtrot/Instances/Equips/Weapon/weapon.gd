extends "res://Instances/Equips/item.gd"

export var damage : int = 0
export var knockback : float = 100

func _input(event):
  if player_inv == null: return
  
  if event.is_action_pressed("fire") && not in_cooldown:
    $Sprite/AnimationPlayer.play("attack")

func Use():
  # Do not allow item usage if no player is using it.
  # Probably should disable object processing until in use...
  if player_inv == null: return
  if in_cooldown: return
  
  if not Input.is_action_pressed("fire"):
    $Sprite/AnimationPlayer.play("idle")
    return
    
  in_cooldown = true

func SetIdle():
  .SetIdle()
  $Sprite/AnimationPlayer.play("idle")
