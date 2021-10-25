extends "res://Instances/interaction.gd"

export(String, FILE) var level

func Use():
  Signals.emit_signal("on_change_base_level", level)
