extends Node

const MAX_HOTBAR = 10

var currentSlot : int = 0

onready var slot_normal = preload("res://Textures/UI/hotbar_slot_normal.tres")
onready var slot_select = preload("res://Textures/UI/hotbar_slot_selected.tres")

var slots = [] 

# A dictionary establishing a relationship with a slot and an equip
var inventory = {}

func _input(event):
  if(event.is_action_pressed("ui_hotbar_forward")):
    GetNextSlot()
  elif(event.is_action_pressed("ui_hotbar_backward")):
    GetNextSlot(false)

func _ready():
  InitalizeInventoryUI()
  InitializeInventory()

func InitializeInventory():
  # Add all the slots to put equips into
  
  # Establish the inventory array to be the size of the number of slots available
  for i in range(0, slots.size()):
    inventory[i] = null
    
  # Provide default equip
  inventory[0] = 0
  
  # Show equips in inventory
  for i in range(0, slots.size()):
    if inventory[i] != null:
      var itemframe = slots[i].get_node_or_null("CenterContainer/Item")
      var texture = load(Equips.equip_resources[inventory[i]])
      itemframe.texture = texture
      itemframe.set_size(Vector2(24, 24))
  
  # Instantiate necessary equips

func InitalizeInventoryUI():
  # Append hotbar slots
  var hotbar_hud = $HotBarMain
  slots.append_array(hotbar_hud.get_children())
  
  # Append inventory slots
  var inv_slots = $Control/ScrollContainer/GridContainer
  slots.append_array(inv_slots.get_children())
  
  # Set the active slot to default to the first hotbar slot
  SetActiveSlot(0)

func GetNextSlot(forward=true):
  if forward:
    currentSlot += 1
    if currentSlot >= MAX_HOTBAR:
      currentSlot = 0
  else:
    currentSlot -= 1
    if currentSlot < 0:
      currentSlot = MAX_HOTBAR - 1
  SetActiveSlot(currentSlot)

func SetActiveSlot(slot_num):
  for i in range(0, MAX_HOTBAR):
    var frame_hud = slots[i]
    if i == slot_num:
      frame_hud.set("custom_styles/normal", slot_select)
      frame_hud.set("custom_styles/pressed", slot_select)
      frame_hud.set("custom_styles/hover", slot_select)    
    else:
      frame_hud.set("custom_styles/normal", slot_normal)
      frame_hud.set("custom_styles/pressed", slot_normal)
      frame_hud.set("custom_styles/hover", slot_normal)       
      
