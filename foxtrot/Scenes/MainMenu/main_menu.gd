extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
  # If the main menu is ever loaded, the game is not being played anymore
  Globals.isGamePlaying = false
  Globals.pause_flags = 0
  
func _on_NewGameButton_pressed():
  $MainMenu/UI/ModePopup.visible = true
  Save.reset_save()
  Globals.isNewGame = true
  
func _on_LoadGameButton_pressed():
  # Load all the save files so that they may be displayed to the user
  Save.list_saves()

# Used to open up the settings. Note: the Settings.tscn is expected to be imported
# into the main menu scene.
func _on_SettingsButton_pressed():
  $SettingsMenu/UI.show()
  $Credits/UI.hide()

func _on_ExitButton_pressed():
  get_tree().quit()

# Used to open up the credits. Note: the Credits.tscn is expected to be imported
# into the main menu scene.
func _on_CreditsButton_pressed():
  $MainMenu/UI.hide()
  $SettingsMenu/UI.hide()
  $Credits/UI.show()

func _on_SettingsBackButton_pressed():
  $MainMenu/UI.show()
  $SettingsMenu/UI.hide()
  $Credits/UI.hide()

func _on_CreditsBackButton_pressed():
  $MainMenu/UI.show()
  $SettingsMenu/UI.hide()
  $Credits/UI.hide()

func _on_HardcoreButton_pressed():
  Globals.isHardcoreMode = true
  StartNewGame()

func _on_CasualButton_pressed():
  Globals.isHardcoreMode = false
  StartNewGame()
  
func StartNewGame():
  Globals.isGamePlaying = true
  Globals.isNewGame = true
  if get_tree().change_scene(Globals.SPATH_CHARACTER_CREATION) != OK:
    print("[Main Menu] Error. Could not change scene from main menu to character creation...")
