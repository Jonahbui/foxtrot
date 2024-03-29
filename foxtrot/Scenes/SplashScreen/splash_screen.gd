extends Node2D

func _ready():
  # Play a bark sound
  # Note: consider adding an animation to the logo!
  yield(get_tree().create_timer(2.0), "timeout")
  $AudioSource.stream.loop_mode = 0
  $AudioSource.play()

func _on_Timer_timeout():
  # Purpose   : Loads the main menu
  # Param(s)  :
  # Return(s) : N/A
  if get_tree().change_scene(Globals.SPATH_MAIN_MENU) != OK:
    printerr("[Base] Error in loading main menu from splash screen...")
