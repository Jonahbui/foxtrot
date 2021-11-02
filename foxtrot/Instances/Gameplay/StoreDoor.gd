extends "res://Node/interaction.gd"

func Use():
  Signals.emit_signal("on_change_base_level", Globals.LPATH_SPAWN)

func _on_DoorDetector_body_entered(_body):
  self.visible = true
  Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/door_open.wav", 1)

func _on_DoorDetector_body_exited(_body):
  self.visible = false
  Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/door_close.wav", 1)
