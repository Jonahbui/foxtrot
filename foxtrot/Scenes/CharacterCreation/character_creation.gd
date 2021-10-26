extends Node2D

func _on_StartButton_pressed():
  $UI/PopupMenu.popup()

func _on_ConfirmButton_pressed():
  # Do not allow the game to proceed if player did not provide a good name
  if $UI/NameInput.text.length() <= 0:
    print("[Character Creation] Error. Name needed...")
    return
  
  # Ensure that save name is unique
  var saves = Save.list_saves()
  for save in saves:
    # Save files have a *.save extension preceded by the character name. Need to split the string 
    # and get the name.
    if save.split(".")[0] == $UI/NameInput.text.to_lower():
      print("[Character Creation] Error. Name is not unique...")
      return
  
  # Switch to the base scene to start the game
  Save.save[Globals.PLAYER_NAME] = $UI/NameInput.text.to_lower()
  if get_tree().change_scene(Globals.SPATH_BASE) != OK:
    print("[Character Creation] Error. Could not load into base from main menu.")


func _on_CancelButton_pressed():
  $UI/PopupMenu.hide()

func _on_BackButton_pressed():
  Globals.isGamePlaying = false
  if get_tree().change_scene(Globals.SPATH_MAIN_MENU) != OK:
    print("[Main Menu] Error. Could not load into main menu from character creation.")
