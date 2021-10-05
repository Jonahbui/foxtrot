extends Node2D

func _ready():
  # Play a bark sound
  # Note: consider adding an animation to the logo!
  yield(get_tree().create_timer(2.0), "timeout")
  $AudioSource.stream.loop_mode = 0
  $AudioSource.play()

# Loads the main menu
func _on_Timer_timeout():
  get_tree().change_scene("res://Scenes/MainMenu/main_menu.tscn")
