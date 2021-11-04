extends Node

#--------------------------------------------------------------------------------------------------
# Godot Functions
#--------------------------------------------------------------------------------------------------
func _enter_tree():
  # Create a config dictionary so that the data can be filled in.
  config = create_config(true)
  load_config()
  
func _init():
  create_save_dir()
  
  if Signals.connect("on_player_loaded", self, "init_player") != OK:
    print("[Save] Error. Failed to connect to signal on_player_loaded...")
  if Signals.connect("on_inventory_loaded", self, "init_inventory") != OK:
    print("[Save] Error. Failed to connect to signal on_inventory_loaded...")
  if Signals.connect("on_base_game_loaded", self, "init_game") != OK:
    print("[Save] Error. Failed to connect tosignal on_base_game_loaded...")

func _ready():
  save = empty_save_data()
  
func _exit_tree():
  # Write config on game exit
  save_config()

#--------------------------------------------------------------------------------------------------
# Config Functions
#--------------------------------------------------------------------------------------------------
const FILENAME_CONFIG_DEFAULT = "config.json"

# Holds the player preferences in a dictionary
var config = null

func create_config(default=false):
  # To add new elements to config, add here below. Define constants in globals:
  var new_config = {
    Globals.VOLUME_MASTER           : config[Globals.VOLUME_MASTER] if not default else 0.0,
    Globals.VOLUME_MUSIC            : config[Globals.VOLUME_MUSIC] if not default else 0.0,
    Globals.VOLUME_SFX              : config[Globals.VOLUME_SFX] if not default else 0.0,
    Globals.VOLUME_AMBIENCE         : config[Globals.VOLUME_AMBIENCE] if not default else 0.0,    
    Globals.VOLUME_UI               : config[Globals.VOLUME_UI] if not default else 0.0,    
    Globals.VOLUME_MASTER_TOGGLE    : config[Globals.VOLUME_MASTER_TOGGLE] if not default else false,
    Globals.VOLUME_MUSIC_TOGGLE     : config[Globals.VOLUME_MUSIC_TOGGLE] if not default else false,
    Globals.VOLUME_SFX_TOGGLE       : config[Globals.VOLUME_SFX_TOGGLE] if not default else false,
    Globals.VOLUME_AMBIENCE_TOGGLE  : config[Globals.VOLUME_AMBIENCE_TOGGLE] if not default else false,
    Globals.VOLUME_UI_TOGGLE        : config[Globals.VOLUME_UI_TOGGLE] if not default else false,
      
    Globals.GRAPHICS_FULLSCREEN : config[Globals.GRAPHICS_FULLSCREEN] if not default else false
  }
  return new_config

func save_config():
  # Create a new file to read using the given filename
  var file = File.new()
  file.open("user://%s" % [FILENAME_CONFIG_DEFAULT], File.WRITE)
  
  # Write the data to the file
  var data = create_config()
  if(data != null): file.store_line(to_json(data))
  file.close()

func load_config():
  # Check for file existance before reading
  var file = File.new()
  if not file.file_exists("user://%s" % [FILENAME_CONFIG_DEFAULT]): return null
  
  # Read in the config file
  file.open("user://%s" % [FILENAME_CONFIG_DEFAULT], File.READ)
  var line = file.get_line()
  var data = parse_json(line)
  if data == null: return null
  
  # Insert the data into the config (Do not set config equal to data. People may
  # insert their own values) dictionary.
  config = create_config(true)
  for key in data.keys():
    if config.has(key): config[key] = data[key]
  
  print("\n[Save] Loading user configurations...")
  print(config)

func reset_config():
  config = create_config(true)

#--------------------------------------------------------------------------------------------------
# Save Functions
#--------------------------------------------------------------------------------------------------
const FILENAME_DEFAULT_AUTO   = "autosave.save"
const SAVE_ID = "id"
const SAVE_CURR_STACK_AMT = "curr_stack_amt"

# Holds the player information here
var save = null

# Holds a reference to the player
var player = null

# Holds a reference to the player's inventory here
var inventory = null

# Use player null to create default player save dictionary
func create_save_data(reset_save=false):
  var data = {
    Globals.PLAYER_DIFFICULTY : Globals.isGamePlaying,
    Globals.PLAYER_INVENTORY  : inventory.InventoryToJSON() if not reset_save else {},
    Globals.PLAYER_NAME       : player.charname if not reset_save  else "default",
    Globals.PLAYER_HEALTH     : player.health if not reset_save  else 25,
    Globals.PLAYER_MANA       : player.mana if not reset_save  else 25,
    Globals.PLAYER_MONEY      : player.money if not reset_save  else 0
  }
  return data

func reset_save():
  save = empty_save_data()

func empty_save_data():
  var data = {
    Globals.PLAYER_DIFFICULTY : false,
    Globals.PLAYER_INVENTORY  : {},
    Globals.PLAYER_NAME       : "",
    Globals.PLAYER_HEALTH     : 25,
    Globals.PLAYER_MANA       : 25,
    Globals.PLAYER_MONEY      : 0
  }
  return data

func save_file():
  # Generate the data to store in a file
  var data = create_save_data()
    
  # Open a file to write the data to
  var file = File.new()
  file.open("user://saves/%s.save" % [data[Globals.PLAYER_NAME]], File.WRITE)
    
  # Write the data to the file
  if(data != null): 
    file.store_line(to_json(data))
    Signals.emit_signal("on_game_saved", OK)
  else:
    Signals.emit_signal("on_game_saved", ERR_FILE_CORRUPT)    
    
  file.close()
  
func load_file(filename):
  # Check for file existance before reading
  var file = File.new()
  if not file.file_exists("user://saves/%s" % [filename]): 
    print("[Save] Error. File %s not found..." % [filename])
    return null
  
  # Read in the save file
  file.open("user://saves/%s" % [filename], File.READ)
  var line = file.get_line()
  var data = parse_json(line)
  if data == null: 
    print("[Save] Error. No data found for file %s..." % [filename])
    return null
  
  # Insert the data into the save (Do not set config equal to data. People may
  # insert their own values) dictionary.
  var save_data = empty_save_data()
  for key in save_data.keys():
    if save_data.has(key): save_data[key] = data[key]
  
  #print("\n[Save] Loading %s save file..." % [save_data[Globals.PLAYER_NAME]])
  return save_data
  
func list_saves():
  # Used to return the filenames of all player saves
  var save_files = []

  # Search for a valid save directory
  var dir = Directory.new()
  if dir.open("user://saves") == OK:
    dir.list_dir_begin(true, true)
    
    # Append each name in the save directory to the saves array
    var save_file = dir.get_next()
    while save_file != "":
      save_files.append(save_file)
      save_file = dir.get_next()
    dir.list_dir_end()
  
  print("[Save] Loading save files...")
  for save in save_files:
    print("\t%s" % [save])
  return save_files
      
func create_save_dir():
  # Create a directory for save files if one is not present
  var dir = Directory.new()
  if dir.open("user://") == OK:
    if not dir.dir_exists("/saves"):
      dir.make_dir("saves")  

func init_player(player):
  print("[Save] Initializing player...")
  self.player = player

  Signals.emit_signal("on_base_game_loaded")
  
  
func init_inventory(inventory):
  print("[Save] Initializing inventory...")  
  self.inventory = inventory

func init_game():
  # Restore the player inventory and player stats
  if player == null:
    print("[Save] Error. Failed to restore player stats...")
  else:
    player.RestorePlayerData(self.save)
    
    if Globals.isNewGame:
      player.ResetPlayer()
      
    player.RefreshStats()
    
  if inventory == null:
    print("[Save] Error. Failed to restore player inventory...")
  else:
    inventory.RestoreInventoryData(self.save[Globals.PLAYER_INVENTORY])
  
  # If the game is a new game, save the player file.
  if Globals.isNewGame:
    Save.save_file()
    Globals.isNewGame = false
