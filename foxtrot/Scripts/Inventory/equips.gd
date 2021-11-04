extends Node

const FILENAME_EQUIPS = "equips.json"

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
  # Check for file existance before reading
  var file = File.new()
  if not file.file_exists("res://Scripts/Inventory/%s" % [FILENAME_EQUIPS]): 
    print("[Equips] Error. Equips file does not exist...")
    return null
  
  # Read in the loot file
  file.open("res://Scripts/Inventory/%s" % [FILENAME_EQUIPS], File.READ)
  var text = file.get_as_text()
  var data = parse_json(text)
  if data == null: 
    print("[Equips] Error. Could not parse data...")
    return null
  
  for key in data:
    var id = int(key)
    equips[id] = data[key]
    equips[id][Equips.EQUIP_TYPE] = Equips.Type.get(data[key][Equips.EQUIP_TYPE])
    equips[id][Equips.EQUIP_SUBTYPE] = Equips.Subtype.get(data[key][Equips.EQUIP_SUBTYPE])
    
  print("\n[Equips] Loading resources...")
  #print("[Equips] Resources: %s" % [equips])
