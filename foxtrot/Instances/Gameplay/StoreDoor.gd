extends "res://Instances/interaction.gd"

var canInteract : bool = false

func Use():
  if canInteract:
    Signals.emit_signal("on_change_base_level", "res://Scenes/Gameplay/Spawn.tscn")

func _on_DoorDetector_body_entered(_body):
  self.visible = true
  Signals.emit_signal("on_play_sfx", "res://Audio/SoundEffects/door_open.wav")

func _on_DoorDetector_body_exited(_body):
  self.visible = false
  Signals.emit_signal("on_play_sfx", "res://Audio/SoundEffects/door_close.wav")

func _on_PortalSpawn_body_entered(_body):
  canInteract = true
  
func _on_PortalSpawn_body_exited(_body):
  canInteract = false
