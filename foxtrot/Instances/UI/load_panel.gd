extends Node

signal _on_load_panel_click(name)

func _on_LoadButton_pressed():
  emit_signal("_on_load_panel_click", self.name)
