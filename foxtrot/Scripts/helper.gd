extends Node

func SetActive(item, state, process_sate, physics_state, input_state):
  # Purpose   : Sets the processing for a node alongside its visibility
  # Param(s)  : N/A
  # Return(s) : N/A
  
  item.visible = state
  item.set_process(process_sate)
  item.set_physics_process(physics_state)
  item.set_process_input(input_state)

func ChangeLevel(level_path):
  # Purpose   : Change the current level, not just game level
  # Param(s)  : N/A
  # Return(s) : N/A
  
  if get_tree().change_scene(level_path) != OK:
    printerr("[Helper] Error. Failed to change to %s..." % [level_path])

func NumericKeysToInt():
  # Purpose   : Convert all string integer keys into int keys
  # Param(s)  : N/A
  # Return(s) : N/A
  
  pass
