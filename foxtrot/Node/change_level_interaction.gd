extends "res://Node/interaction.gd"

# Used by the submarine to toggle on the map
export(bool) var hardset_level = false

# Level to load
export(String, FILE) var level

# Location in level to spawn into
export(String) var level_location = ""

func Use():
  .Use()
  
  if not hardset_level:
    Signals.emit_signal("on_map_trigger")
  else:
    Signals.emit_signal("on_change_base_level", level, level_location)
  
