extends Node2D

func _on_StartButton_pressed():
  $UI/PopupMenu.popup()

func _on_ConfirmButton_pressed():
  if $UI/NameInput.text.length() > 0:
    Save.save[Globals.PLAYER_NAME] = $UI/NameInput.text.to_lower()
    if get_tree().change_scene(Globals.SPATH_BASE) != OK:
      print("[Main Menu] Error. Could not load into base from main menu.")
  else:
    print("[Main Menu] Error. Name needed...")

func _on_CancelButton_pressed():
  $UI/PopupMenu.hide()

func _on_BackButton_pressed():
  Globals.isGamePlaying = false
  if get_tree().change_scene(Globals.SPATH_MAIN_MENU) != OK:
    print("[Main Menu] Error. Could not load into main menu from character creation.")
