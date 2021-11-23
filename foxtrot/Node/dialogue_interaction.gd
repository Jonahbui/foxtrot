extends "res://Node/interaction.gd"

export var dialogue = ""

func _init():
  if Signals.connect("on_dialogue_exited", self, "OnDialogueExit") != OK:
    printerr("[Dialogue Interaction] Error. Failed to connect to signal on_dialogue_exited...")

func Use():
  .Use()
  
  # If the player can interact with the interactable entity, then trigger its dialogue
  Signals.emit_signal("on_dialogue_trigger", dialogue)

func OnDialogueExit():
  Signals.emit_signal("on_interaction_changed", true)  
