extends CanvasLayer

func _ready():
  # If the pause menu is visible, then inform the game that it's paused
  # Else it's not paused DUE TO the pause menu (may be paused for other reasons)
  Globals.SetFlag(Globals.FLAG_PAUSED, $UI.visible)

func _input(event):
  if event.is_action_released("ui_cancel"):
    # Toggle the pause menu depending on the pause state of the game
    var result_state = Globals.ToggleFlag(Globals.FLAG_PAUSED)
    $UI.visible = result_state

func _on_ResumeButton_pressed():
  # If resuming the game, unpause the game
  Globals.SetFlag(Globals.FLAG_PAUSED, true)
  
  # Hide both the pause menu and settings menu when the game starts.
  # Need to hide settings menu because it can still be open even if the pause menu is not
  $UI.hide()
  $SettingsMenu/UI.hide()

func _on_SettingsButton_pressed():
  # Hide the pause menu and show the settings menu
  $UI.hide()
  $SettingsMenu/UI.show()  

func _on_MainMenuButton_pressed():
  # If going back to the main menu, the game shuold not be paused since it is not running
  Globals.SetFlag(Globals.FLAG_PAUSED, false)
  
  # Switch to main menu
  if get_tree().change_scene(Globals.SPATH_MAIN_MENU) != OK:
    print("[Scene] Failed to change scenes...")

func _on_ExitButton_pressed():
  get_tree().quit()

func _on_SettingsBackButton_pressed():
  $UI.show()
  $SettingsMenu/UI.hide()
