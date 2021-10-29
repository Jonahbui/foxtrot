extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
  # If the main menu is ever loaded, the game is not being played anymore
  Globals.isGamePlaying = false
  Globals.pause_flags = 0
  
  # Load all the save files so that they may be displayed to the user
  CreateLoadPanels()
  
func _on_NewGameButton_pressed():
  $MainMenu/UI/ModePopup.visible = true
  Save.reset_save()
  Globals.isNewGame = true
  
func _on_LoadGameButton_pressed():
  $MainMenu/UI.hide()
  $SettingsMenu/UI.hide()
  $Credits/UI.hide()
  $LoadMenu/UI.show()

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
  
func _on_BackButton_pressed():
  $MainMenu/UI.show()
  $SettingsMenu/UI.hide()
  $Credits/UI.hide()
  $LoadMenu/UI.hide()

func StartNewGame():
  Globals.isGamePlaying = true
  Globals.isNewGame = true
  if get_tree().change_scene(Globals.SPATH_CHARACTER_CREATION) != OK:
    print("[Main Menu] Error. Could not change scene from main menu to character creation...")

#--------------------------------------------------------------------------------------------------
# Load Game Functions
#--------------------------------------------------------------------------------------------------
export(String, FILE) var load_panel

func CreateLoadPanels():
  var saves = Save.list_saves()
  load_panel = load(load_panel)
  
  for save_name in saves:
    # Create instance
    var instance = load_panel.instance()
    
    # Load the player data to provide identification data to the panel
    var save_data = Save.load_file(save_name)
    var name_label = instance.get_node_or_null("NameLabel")
    name_label.text = save_data[Globals.PLAYER_NAME]
    instance.name = save_data[Globals.PLAYER_NAME]
    
    instance.connect("_on_load_panel_click", self, "LoadFile")
    
    # Add panel to scene
    $LoadMenu/UI/NinePatchRect/ScrollContainer/VBoxContainer.add_child(instance)

func LoadFile(name):
  # Ensure the game is not a new game. If the game is a new game, then the save system will not load
  # the player data.
  Globals.isNewGame = false
  
  # Sadly we store the name of the save file on the instnace of the load panel. However, a '.' is
  # not a valid character allowed in the name, so godot removes it. So instead we pass in just the
  # save name without the extension and add the extension on ourselves.
  Save.save = Save.load_file("%s.save" % [name])
  
  # Load the main game
  Helper.ChangeLevel(Globals.SPATH_BASE)
