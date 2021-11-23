extends Node

# The file storing all equipment information
const FILENAME_EQUIPS = "equips.json"

# Constants for dictionary lookups
const EQUIP_NAME      = "name"
const EQUIP_TYPE      = "type"
const EQUIP_SUBTYPE   = "subtype"
const EQUIP_PRICE     = "price"
const EQUIP_RESOURCE  = "resource"
const EQUIP_INSTANCE  = "instance"
const EQUIP_DESC      = "desc"

enum Type {
  item,
  weapon,
  armor,
  accessory
 }

enum Subtype {
  nonstackable,
  stackable
 }

var equips = {}

func _ready():
  ReadEquips()
  
func ReadEquips():
  # Purpose   : Read in the equipment available from file.
  # Param(s)  : N/A
  # Return(s) : N/A
  
  # Check for file existance before reading
  var file = File.new()
  if not file.file_exists("res://Scripts/Inventory/%s" % [FILENAME_EQUIPS]): 
    printerr("[Equips] Error. Equips file does not exist...")
    return null
  
  # Read in the loot file
  file.open("res://Scripts/Inventory/%s" % [FILENAME_EQUIPS], File.READ)
  var text = file.get_as_text()
  var data = parse_json(text)
  if data == null: 
    printerr("[Equips] Error. Could not parse data...")
    return null
  
  for key in data:
    var id = int(key)
    equips[id] = data[key]
    equips[id].type = Equips.Type.get(data[key].type)
    equips[id].subtype = Equips.Subtype.get(data[key].subtype)
    
  print_debug("\n[Equips] Loading resources...")
  #print_debug("[Equips] Resources: %s" % [equips])
