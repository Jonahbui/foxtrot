extends Node

func SetActive(item, state, process_sate, physics_state, input_state):
  item.visible = state
  item.set_process(process_sate)
  item.set_physics_process(physics_state)
  item.set_process_input(input_state)

func ChangeLevel(level_path):
  if get_tree().change_scene(level_path) != OK:
    printerr("[Helper] Error. Failed to change to %s..." % [level_path])

func NumericKeysToInt():
  pass
