extends CanvasLayer

func _init():
  if Signals.connect("on_game_saved", self, "TriggerSaveMessage") != OK:
    printerr("[Pause Menu] Error. Failed to connect to signal on_game_save...")

func _ready():
  # If the pause menu is visible, then inform the game that it's paused
  # Else it's not paused DUE TO the pause menu (may be paused for other reasons)
  Globals.SetFlag(Globals.FLAG_PAUSED, $UI.visible)

func _input(event):
  if event.is_action_released("ui_cancel"):
    Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/whoosh.wav", 3)
    # Toggle the pause menu depending on the pause state of the game
    var result_state = Globals.ToggleFlag(Globals.FLAG_PAUSED)
    
    if result_state:
      $UI.visible = true
      $AnimationPlayer.play("open")
    else:
      $AnimationPlayer.play("close")
      while $AnimationPlayer.is_playing():
        yield(get_tree(), "idle_frame")
      $UI.visible = false      
    
    # Only show the save button if the player is in the spawn. Update when pause UI updates.
    if Globals.is_in_spawn:
      $UI/Background/ButtonVbox/SaveButton.visible = true
    else:
      $UI/Background/ButtonVbox/SaveButton.visible = false

func _on_ResumeButton_pressed():
  # Purpose   : Unpauses the game
  # Param(s)  : N/A
  # Return(s) : N/A
  
  # If resuming the game, unpause the game
  Globals.SetFlag(Globals.FLAG_PAUSED, false)
  
  # Hide both the pause menu and settings menu when the game starts.
  # Need to hide settings menu because it can still be open even if the pause menu is not
  $UI.hide()
  $SettingsMenu/UI.hide()

func _on_SaveButton_pressed():
  # Purpose   : Save the current game's progress
  # Param(s)  : N/A
  # Return(s) : N/A
  Save.save_file()

func _on_SettingsButton_pressed():
  # Purpose   : Opens the settings menu
  # Param(s)  : N/A
  # Return(s) : N/A
  
  # Hide the pause menu and show the settings menu
  $UI.hide()
  $AnimationPlayer.play("close")
  while $AnimationPlayer.is_playing():
    yield(get_tree(), "idle_frame")
  $SettingsMenu/UI.show()
  $SettingsMenu/AnimationPlayer.play("open")

func _on_MainMenuButton_pressed():
  # Purpose   : Loads the main menu
  # Param(s)  : N/A
  # Return(s) : N/A
  
  # If going back to the main menu, the game shuold not be paused since it is not running
  Globals.SetFlag(Globals.FLAG_PAUSED, false)
  
  # Switch to main menu
  if get_tree().change_scene(Globals.SPATH_MAIN_MENU) != OK:
    printerr("[Scene] Error. Failed to change scenes...")

func _on_ExitButton_pressed():
  # Purpose   : Quits the game
  # Param(s)  : N/A
  # Return(s) : N/A
  get_tree().quit()

func _on_SettingsBackButton_pressed():
  $SettingsMenu/AnimationPlayer.play("close")
  while $SettingsMenu/AnimationPlayer.is_playing():
    yield(get_tree(), "idle_frame")
  $UI.show()
  $SettingsMenu/UI.hide()
  $AnimationPlayer.play("open")

func TriggerSaveMessage(state):
  # Purpose   : Shows a message stating the game has been saved
  # Param(s)  :
  # - state   : Status of whether the save was successful or not ( OK and etc... )
  # Return(s) : N/A
  
  $UI/SaveStateLabel.visible = true
  if state == OK:
    $UI/SaveStateLabel.modulate = Color.green
    $UI/SaveStateLabel.text = "Saved..."
    Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/save_success.wav", 3)
  else:
    $UI/SaveStateLabel.modulate = Color.red
    $UI/SaveStateLabel.text = "Error. Could not save :("    
  yield(get_tree().create_timer(2.0), "timeout")
  $UI/SaveStateLabel.visible = false  
