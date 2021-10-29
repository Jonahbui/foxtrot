extends "res://Node/interaction.gd"

export var dialogue = ""

func _init():
  Signals.connect("on_dialogue_exited", self, "OnDialogueExit")

func Use():
  # After the player has interacted with the entity associated with this script, toggle off the 
  # player's inform box
  Signals.emit_signal("on_interaction_changed", false)
  self.emit_signal("interaction_triggered")
  
  # If the player can interact with the interactable entity, then trigger its dialogue
  Signals.emit_signal("on_dialogue_trigger", dialogue)

func OnDialogueExit():
  Signals.emit_signal("on_interaction_changed", true)  
