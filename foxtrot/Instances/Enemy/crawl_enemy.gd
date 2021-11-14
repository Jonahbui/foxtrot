extends Enemy

func Move():
  if not is_on_floor():
    direction.y += gravity
  
  move_and_slide(direction * runSpeed + knockback_velocity)
