extends "res://Instances/interaction.gd"

export var dialogue = ""

func Use():
  Signals.emit_signal("on_dialogue_trigger", dialogue)
