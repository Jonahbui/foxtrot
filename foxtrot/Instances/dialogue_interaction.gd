extends "res://Instances/interaction.gd"

export var dialogue = ""

func Use():
  Signals.emit_signal("on_interaction_changed", false)
  
  # If the player can interact with the interactable entity, then trigger its dialogue
  Signals.emit_signal("on_dialogue_trigger", dialogue)
