extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
  # If the main menu is ever loaded, the game is not being played anymore
  Globals.is_game_playing = false
  Globals.pause_flags = 0
  
  # Load all the save files so that they may be displayed to the user
  CreateLoadPanels()
  
func _on_NewGameButton_pressed():
  $MainMenu/UI/ModePopup.visible = true
  Save.reset_save()
  Globals.is_new_game = true
  
func _on_LoadGameButton_pressed():
  $MainMenu/UI.hide()
  $SettingsMenu/UI.hide()
  $Credits/UI.hide()
  
  $AnimationPlayer.play("MainToLoad")
  
  while $AnimationPlayer.is_playing():
    yield(get_tree().create_timer(0.5), "timeout")
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
  Globals.is_hardcore_mode = true
  StartNewGame()

func _on_CasualButton_pressed():
  Globals.is_hardcore_mode = false
  StartNewGame()
  
func _on_BackButton_pressed():
  $LoadMenu/UI.hide()
  $SettingsMenu/UI.hide()
  $Credits/UI.hide()
  
  $AnimationPlayer.play_backwards("MainToLoad")
  while $AnimationPlayer.is_playing():
    yield(get_tree().create_timer(0.5), "timeout")
  $MainMenu/UI.show()

func StartNewGame():
  Globals.is_game_playing = true
  Globals.is_new_game = true
  if get_tree().change_scene(Globals.SPATH_CHARACTER_CREATION) != OK:
    printerr("[Main Menu] Error. Could not change scene from main menu to character creation...")

#--------------------------------------------------------------------------------------------------
# Load Game Functions
#--------------------------------------------------------------------------------------------------
export(String, FILE) var load_panel
export(StyleBoxTexture) var sodacan_red
export(StyleBoxTexture) var sodacan_blue
export(StyleBoxTexture) var sodacan_green


func CreateLoadPanels():
  var saves = Save.list_saves()
  load_panel = load(load_panel)
  var rotate_i = 0
  for save_name in saves:
    # Create instance
    var instance = load_panel.instance()
    match rotate_i:
      0:
        instance.add_stylebox_override("panel", sodacan_red)
      1:
        instance.add_stylebox_override("panel",sodacan_blue)
      2:
        instance.add_stylebox_override("panel",sodacan_green)
    rotate_i += 1
    if rotate_i > 2: rotate_i = 0

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
  Globals.is_new_game = false
  
  # Sadly we store the name of the save file on the instnace of the load panel. However, a '.' is
  # not a valid character allowed in the name, so godot removes it. So instead we pass in just the
  # save name without the extension and add the extension on ourselves.
  Save.save = Save.load_file("%s.save" % [name])
  
  # Load the main game if the save file is valid and not null (check validity later)
  if Save.save:
    Helper.ChangeLevel(Globals.SPATH_BASE)
  else:
    # TA: add notification to player that file could not be loaded
    printerr("[MainMenu] Error. Failed to load save file \"%s\"" % [name])
