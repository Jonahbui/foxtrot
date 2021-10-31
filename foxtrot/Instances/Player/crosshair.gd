extends TextureRect

func _input(event):
  if event is InputEventMouseMotion:
    self.set_global_position(event.position - self.rect_pivot_offset)
