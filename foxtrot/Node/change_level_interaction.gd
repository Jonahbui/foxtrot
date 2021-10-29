extends "res://Node/interaction.gd"

export(String, FILE) var level

func Use():
  # After the player has interacted with the entity associated with this script, toggle off the 
  # player's inform box
  Signals.emit_signal("on_interaction_changed", false)
  self.emit_signal("interaction_triggered")
  Signals.emit_signal("on_change_base_level", level)
  
