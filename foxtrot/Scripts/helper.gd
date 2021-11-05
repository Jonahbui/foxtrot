extends Node

func SetActive(item, state):
  item.visible = state
  item.set_process(state)
  item.set_physics_process(state)
  item.set_process_input(state)

func ChangeLevel(level_path):
  if get_tree().change_scene(level_path) != OK:
    printerr("[Helper] Error. Failed to change to %s..." % [level_path])

func NumericKeysToInt():
  pass
