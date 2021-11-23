extends "res://Node/interaction.gd"

export(bool) var hardset_level = false
export(String, FILE) var level
export(String) var level_location = ""

func Use():
  .Use()
  
  if not hardset_level:
    Signals.emit_signal("on_map_trigger")
  else:
    Signals.emit_signal("on_change_base_level", level, level_location)
  
