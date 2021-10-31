extends TextureRect

func _ready():
  #Input.set_custom_mouse_cursor(null)
  pass

func _input(event):
  if event is InputEventMouseMotion:
    self.set_global_position(event.position - self.rect_pivot_offset)
