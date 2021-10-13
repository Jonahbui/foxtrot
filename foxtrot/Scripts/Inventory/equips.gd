extends Node

const FILENAME_EQUIPS = "equips.json"

var equip_resources = {}
var equip_instances = {}

func _ready():
  ReadInEquips()
  
func ReadInEquips():
  # Check for file existance before reading
  var file = File.new()
  if not file.file_exists("res://Scripts/Inventory/%s" % [FILENAME_EQUIPS]): return null
  
  # Read in the config file
  file.open("res://Scripts/Inventory/%s" % [FILENAME_EQUIPS], File.READ)
  var text = file.get_as_text()
  var data = parse_json(text)
  if data == null: return null
  
  # Insert the data into the config (Do not set config equal to data. People may
  # insert their own values) dictionary.
  for key in data.keys():
    equip_resources[int(data[key]["id"])] = data[key]["resource"]
    equip_instances[int(data[key]["id"])] = data[key]["instance"]
    
  print("\n[Equips] Loading resources...")
  print("[Equips] Resources:")
  print(equip_resources)
  print("[Equips] Instances:")
  
  print(equip_instances)
