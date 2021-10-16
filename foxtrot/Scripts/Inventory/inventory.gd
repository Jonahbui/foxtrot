# Note: in scene hierarchy the Hud must be behind Invetory or else the hotbar
# cannot be clicked...

extends Node

signal play_audio(clip, source)

const MAX_HOTBAR = 10

var curr_slot_id : int = 0

onready var slot_normal = preload("res://Textures/UI/hotbar_slot_normal.tres")
onready var slot_select = preload("res://Textures/UI/hotbar_slot_selected.tres")

var slots = []

var player = null
var playerInventory = null

var selectedSlot1 : int = -1
var selectedSlot2 : int = -1

# A dictionary establishing a relationship with a slot and an equip
var inventory = {}

func _input(event):
  if(event.is_action_pressed("ui_hotbar_forward")):
    GetNextSlot(false)
  elif(event.is_action_pressed("ui_hotbar_backward")):
    GetNextSlot()
  elif event.is_action_pressed("hotkey1"):
    SetActiveSlot(0, curr_slot_id)
  elif event.is_action_pressed("hotkey2"):
    SetActiveSlot(1, curr_slot_id)
  elif event.is_action_pressed("hotkey3"):
    SetActiveSlot(2, curr_slot_id)
  elif event.is_action_pressed("hotkey4"):
    SetActiveSlot(3, curr_slot_id)
  elif event.is_action_pressed("hotkey5"):
    SetActiveSlot(4, curr_slot_id)
  elif event.is_action_pressed("hotkey6"):
    SetActiveSlot(5, curr_slot_id)
  elif event.is_action_pressed("hotkey7"):
    SetActiveSlot(6, curr_slot_id)
  elif event.is_action_pressed("hotkey8"):
    SetActiveSlot(7, curr_slot_id)
  elif event.is_action_pressed("hotkey9"):
    SetActiveSlot(8, curr_slot_id)
  elif event.is_action_pressed("hotkey0"):
    SetActiveSlot(9, curr_slot_id)

func _ready():
  player = self.get_tree().get_root().get_node_or_null("/root/Base/Player")  
  playerInventory = self.get_tree().get_root().get_node_or_null("/root/Base/Player/Inventory")
  if playerInventory == null: playerInventory = self.get_tree().get_root().get_node_or_null("Player/Inventory")
  if self.connect("play_audio", self.get_tree().get_root().get_node_or_null("/root/Base"), "PlayAudio") != OK:
    print("[Base] Failed to connect audio...")
  InitalizeInventoryUI()
  InitializeInventory()
  
  # Set the active slot to default to the first hotbar slot
  SetActiveSlot(0, true)

func InitializeInventory():
  # Add all the slots to put equips into
  
  # Establish the inventory array to be the size of the number of slots available
  for i in range(0, slots.size()):
    inventory[i] = null

func InitalizeInventoryUI():
  # Append hotbar slots
  var hotbar_hud = $HotBarMain
  slots.append_array(hotbar_hud.get_children())
  
  # Append inventory slots
  var inv_slots = $Control/ScrollContainer/GridContainer
  slots.append_array(inv_slots.get_children())

func GetNextSlot(moveForward=true):
  var prev_slot_id = curr_slot_id
  var new_slot_id = curr_slot_id+1 if moveForward else curr_slot_id-1
  
  if new_slot_id >= MAX_HOTBAR:
    new_slot_id = 0
  elif new_slot_id < 0:
    new_slot_id = MAX_HOTBAR - 1
  
  SetActiveSlot(new_slot_id, prev_slot_id)

func SetActiveSlot(active_slot_id : int, prev_slot_id : int, ignoreSound=false):
  if not ignoreSound: emit_signal("play_audio", 1, Globals.source.sfx)
  if active_slot_id == prev_slot_id: return
  
  curr_slot_id = active_slot_id
  
  var prev_slot = slots[prev_slot_id]
  prev_slot.set("custom_styles/normal", slot_normal)
  prev_slot.set("custom_styles/pressed", slot_normal)
  prev_slot.set("custom_styles/hover", slot_normal)
  if inventory[prev_slot_id] != null:
    SetActive(inventory[prev_slot_id], false)
  
  var curr_slot = slots[active_slot_id]
  curr_slot.set("custom_styles/normal", slot_select)
  curr_slot.set("custom_styles/pressed", slot_select)
  curr_slot.set("custom_styles/hover", slot_select)
  if inventory[active_slot_id] != null:
    SetActive(inventory[active_slot_id], true)

func FindOpenSlot():
  for i in range(0, slots.size()):
    if inventory[i] == null:
      return i
  return null

func AddItem(item_to_add):
  # TA: Check if item is stackable

  # Create the item if necessary
  var item = null
  if typeof(item_to_add) == TYPE_INT:
    item = load(Equips.equips[str(item_to_add)]["instance"]).instance()
  else:
    item = item_to_add  
  item.id = item_to_add
  
  # Find a slot to add the item
  var slot_id = FindOpenSlot()
  if slot_id != null:
    

    # Add item to inventory
    item.SetProcess(Globals.ItemProcess.Player) # TA: consider adding initalize method
    item.player_inv = self
    inventory[slot_id] = item
    playerInventory.add_child(item) # playerInventory is a container storing all items for the player
    
    # Show equip in inventory frames
    var itemframe = slots[slot_id].get_node_or_null("CenterContainer/Item")
    var texture = load(Equips.equips[str(item_to_add)]["resource"])
    itemframe.texture = texture
    itemframe.set_size(Vector2(24, 24))
    
    # Check if item is in the   hotbar and equip if so
    if IsSelectedHotbar(slot_id):
      SetActiveSlot(slot_id, true)
    # Disable item from running until it is selected
    else:
      SetActive(item, false)
  else:
    # TA: Should drop item/ not pick it up
    item.SetProcess(Globals.ItemProcess.World)
    var level_items = self.get_tree().get_root().get_node_or_null("/root/Base/Level/Items")
    item.position = player.position
    level_items.add_child(item)

func RemoveItem(item):
  for i in range(0, slots.size()):
    if inventory[i] == item:
      print("[Inventory] Removing %s from inventory at slot %d" % [inventory[i].get_name(), i])
      inventory[i] = null
      RefreshInventorySlot(i)
      return OK
  return FAILED
  
func IsSelectedHotbar(slot_num):
  return slot_num == curr_slot_id
  
func RefreshInventorySlots(refreshSlots : Array):
  # Loop through all the slots and update their textures
  if refreshSlots == null:
    for i in range(0, slots.size()):
      RefreshInventorySlot(i)
  else:
    for slot in refreshSlots:
      RefreshInventorySlot(slot)
    
func RefreshInventorySlot(slot_num : int):
  var itemframe = slots[slot_num].get_node_or_null("CenterContainer/Item")
  # If the inventory is not null, update its texture
  if inventory[slot_num] != null:
    var texture = load(Equips.equips[str(inventory[slot_num].id)]["resource"])
    itemframe.texture = texture
    itemframe.set_size(Vector2(24, 24))
    
    # If the current slot is one of the ones being refreshed, make sure to
    # disable/enable the item in that slot
    var itemState = true if (slot_num == curr_slot_id) else false
    SetActive(inventory[slot_num], itemState)
  # If the inventory is null, set texture to null
  else:
    itemframe.texture = null

func _on_slot_pressed(slot_num):
  print("[Inventory] Slot #%d selected." % [slot_num])
  
  if selectedSlot1 == -1:
    # Ignore first selections if the slot is null. Cannot select anything that 
    # is null first. It is okay to select a second slot that is null, as long as
    # the first is not null.
    if inventory[slot_num] == null: return
    
    # Set the first index of slot to swap contents
    selectedSlot1 = slot_num
  else:
    # Set the second index of slot to swap contents with
    selectedSlot2 = slot_num

    # If the slot indices are equal, ignore the swap request. Redundant.
    if selectedSlot1 == selectedSlot2: return
    
    # Swap places in inventory
    if inventory[selectedSlot1] != null && inventory[selectedSlot2] != null:
      var temp = inventory[selectedSlot1]
      inventory[selectedSlot1] = inventory[selectedSlot2]
      inventory[selectedSlot2] = temp
    # Move slot 1 item to slot 2
    elif inventory[selectedSlot1] != null && inventory[selectedSlot2] == null:
      inventory[selectedSlot2] = inventory[selectedSlot1]
      inventory[selectedSlot1] = null
    
    RefreshInventorySlots([selectedSlot1, selectedSlot2])
    
    # Reset the sentinel values used to determine which slots are selecte
    # -1 means no slot selected
    selectedSlot1 = -1
    selectedSlot2 = -1

func SetActive(item, state):
  item.visible = state
  item.set_process(state)
  item.set_physics_process(state)
  item.set_process_input(state)
