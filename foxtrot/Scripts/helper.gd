extends Node

func SetActive(item, state):
  item.visible = state
  item.set_process(state)
  item.set_physics_process(state)
  item.set_process_input(state)
