extends Node

# Default name for config file if force shutdown or unrecoverable exception
const FILENAME_DEFAULT_AUTO   = "autosave.save"
const FILENAME_CONFIG_DEFAULT = "playerConfig.json"

# Holds the player preferences in a dictionary
var config = null

# Holds the player here
var save = null

func _enter_tree():
  # Create a config dictionary so that the data can be filled in.
  config = create_config(true)
  load_config()
  
  save = create_save_file(null)

func _init():
  create_save_dir()  

func _exit_tree():
  # Write an autosave on game exit
  save_config()

func create_config(default=false):
  # To add new elements to config, add here below. Define constants in globals:
  var new_config = {
      Globals.VOLUME_MASTER : config[Globals.VOLUME_MASTER] if not default else 0.0,
      Globals.VOLUME_MUSIC  : config[Globals.VOLUME_MUSIC] if not default else 0.0,
      Globals.VOLUME_SFX    : config[Globals.VOLUME_SFX] if not default else 0.0,
      Globals.VOLUME_MASTER_TOGGLE : config[Globals.VOLUME_MASTER_TOGGLE] if not default else false,
      Globals.VOLUME_MUSIC_TOGGLE  : config[Globals.VOLUME_MUSIC_TOGGLE] if not default else false,
      Globals.VOLUME_SFX_TOGGLE    : config[Globals.VOLUME_SFX_TOGGLE] if not default else false,
      
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
  for key in data.keys():
    if config.has(key): config[key] = data[key]
  
  print("\n[Save] Loading user configurations...")
  print(config)

func reset_config():
  config = create_config(true)

# Use player null to create default player save dictionary
func create_save_file(player=null):
  var file = {
    Globals.PLAYER_NAME   : player.charname if player != null else "",
    Globals.PLAYER_HEALTH : player.health if player != null else 0,
    Globals.PLAYER_MONEY  : player.money if player != null else 0
   }
  return file

func save_file(player=null):


  # Create a file to write the daa to
  var file = File.new()
  file.open("user://%s.save" % [player.charname], File.WRITE)
  
  # Write the data to the file
  var data = create_save_file(player)
    
  # Create an empty save file with just 
  if(data != null): file.store_line(to_json(data))
  file.close()
  
func load_file():
  pass
  
func list_saves():
  # Used to return the filenames of all player saves
  var saves = []

  # Search for a valid save directory
  var dir = Directory.new()
  if dir.open("user://saves") == OK:
    dir.list_dir_begin(true, true)
    
    # Append each name in the save directory to the saves array
    var save_file = dir.get_next()
    while save_file != "":
      saves.append(save_file)
    dir.list_dir_end()
  
  return saves
      
func create_save_dir():
  # Create a directory for save files if one is not present
  var dir = Directory.new()
  if dir.open("user://") == OK:
    if not dir.dir_exists("/saves"):
      dir.make_dir("saves")  
