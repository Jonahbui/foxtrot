extends Node

# Signals which panel was cliked and the name of the file to load
signal _on_load_panel_click(name)

func _on_LoadButton_pressed():
  # Purpose   : Indicate which file is currently selected.
  # Param(s)  : 
  # Return(s) : N/A
  emit_signal("_on_load_panel_click", self.name)
