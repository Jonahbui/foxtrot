extends Node2D

func _on_StartButton_pressed():
  $UI/PopupMenu.popup()

func _on_ConfirmButton_pressed():
  if $UI/NameInput.text.length() > 0:
    Save.save[Globals.PLAYER_NAME] = $UI/NameInput.text
    if get_tree().change_scene("res://Scenes/Gameplay/Base.tscn") != OK:
      print("[Main Menu] Error. Could not load into base from main menu.")

func _on_CancelButton_pressed():
  $UI/PopupMenu.hide()

func _on_BackButton_pressed():
  Globals.isGamePlaying = false
  if get_tree().change_scene("res://Scenes/MainMenu/main_menu.tscn") != OK:
    print("[Main Menu] Error. Could not load into main menu from character creation.")
