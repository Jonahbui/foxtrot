# NOTE: How the Loot Table Works
# Let v = [x1, x2, x3]
# 1. To randomly select first we need to calculate the sum of the array v_sum = x1 + x2 + x3
# 2. Next we need to calculate a range for each of these elements. Each element has an associated
#    range in a separate array. The max range of an element is defined by the sum of the element and
#    all the elements that came before it. The min range is the sum of the last element and all the
#    elements before it. E.g. range = [x1, x1+x2, x1+x2+x3]
# 3. Now generate a random number x_random from 0 to v_sum
# 4. Search the range array from the beginning and find the first number xn that is greater than
#    x_random, and return the index if that number in the range array. That is the index of the
#    loot that was chosen that you can find in the associated LOOT_ITEM array.
#    E.g. x_random < x1
#    Because x_random < x1, return 0 because x1 is at index 0, and it's range is 0 to x1.

# There are 2 tables for loot. One for the enemies and one for the levels (mainly used by chests).
extends Node

const COIN_PATH = "res://Instances/Gameplay/Coin.tscn"

const FILENAME_LOOT = "loot.json"

const LOOT_LEVEL  = "level"
const LOOT_ENEMY  = "enemy"
const LOOT_TABLE  = "table"
const LOOT_ITEM   = "item"
const LOOT_COIN   = "coin"
const LOOT_SUM    = "sum"
const LOOT_RANGE  = "range"

var table = null

func _ready():
  ReadLootTable()
  CalculateLootTableMetadata(LOOT_LEVEL)
  CalculateLootTableMetadata(LOOT_ENEMY)
  
func ReadLootTable():
  # Check for file existance before reading
  var file = File.new()
  if not file.file_exists("res://Scripts/Loot/%s" % [FILENAME_LOOT]): 
    printerr("[Loot] Error. Loot file does not exist...")
    return null
  
  # Read in the loot file
  file.open("res://Scripts/Loot/%s" % [FILENAME_LOOT], File.READ)
  var text = file.get_as_text()
  var data = parse_json(text)
  if data == null: 
    printerr("[Loot] Error. Could not parse data...")
    return null
    
  print("\n[Loot] Loading loot table...")
  table = data

func CalculateLootTableMetadata(category):
  for item in table[category]:
    item = table[category][item]
    item.range = []
    
    # Calculate the sum total of all possibilities
    item.sum = 0
    for num in item.table:
      item.sum += num
      
      # Calculate the loot range
      item.range.append(item.sum)

func GenerateLoot(chosen_table):
  var rng = RandomNumberGenerator.new()
  rng.randomize()
  var num = rng.randi_range(0, chosen_table.sum)
  
  var loot_index = 0
  for i in range(0, chosen_table.range.size()):
    if num < chosen_table.range[i]:
      loot_index = i
      break
  
  # Create a loot instance
  var loot = chosen_table.item[loot_index]
  var loot_instance = load(loot).instance()
  
  if loot_instance == null:
    printerr("[Loot] Error. Could not load loot from %s..." % [loot])
  
  # If the item is a coin, the coin can have a random associated value with it that must be assigned
  if loot == COIN_PATH:
    var coin_min = chosen_table.coin[0]
    var coin_max = chosen_table.coin[1]
    loot_instance.value = rng.randi_range(coin_min, coin_max)
    
  return loot_instance
