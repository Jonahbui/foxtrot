extends "res://Instances/Equips/item.gd"

export(String, FILE) var attack_sound

export var damage : int = 0
export var knockback : float = 100

func _process_input(event):
  if player_inv == null: return
  
  if event.is_action_pressed("fire") && not in_cooldown:
    $Sprite/AnimationPlayer.play("attack")

func _on_use():
  if not Input.is_action_pressed("fire"):
    $Sprite/AnimationPlayer.play("idle")
    return false
    
  if in_cooldown: return false
    
  in_cooldown = true

func AnimationStop():
  $Sprite/AnimationPlayer.play("idle")

func PlayAttack():
  Signals.emit_signal("on_play_audio", attack_sound, 1)
  
func FromJSON(item):
  .FromJSON(item)
