extends Node

const FILENAME_EQUIPS = "equips.json"

var equips = {}

func _ready():
  ReadEquips()
  
func ReadEquips():
  # Check for file existance before reading
  var file = File.new()
  if not file.file_exists("res://Scripts/Inventory/%s" % [FILENAME_EQUIPS]): return null
  
  # Read in the config file
  file.open("res://Scripts/Inventory/%s" % [FILENAME_EQUIPS], File.READ)
  var text = file.get_as_text()
  var data = parse_json(text)
  if data == null: return null
  
  for key in data:
    equips[int(key)] = data[key]
    
  print("\n[Equips] Loading resources...")
  print("[Equips] Resources: %s" % [equips])
