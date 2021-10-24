extends Node

var canInteract : bool = false

func _input(event):
  if event.is_action_pressed("interact") && canInteract:
    Use()
  
func Use():
  pass

func _on_Player_body_entered(_body):
  canInteract = true
  
func _on_Player_body_exited(_body):
  canInteract = false
