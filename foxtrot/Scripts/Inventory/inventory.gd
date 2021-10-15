# Note: in scene hierarchy the Hud must be behind Invetory or else the hotbar
# cannot be clicked...

extends Node

signal play_audio(clip, source)

const MAX_HOTBAR = 10

var currentSlot : int = 0

onready var slot_normal = preload("res://Textures/UI/hotbar_slot_normal.tres")
onready var slot_select = preload("res://Textures/UI/hotbar_slot_selected.tres")

var slots = []

var playerInventory = null


var slotSelect1 : int = -1
var slotSelect2 : int = -1

# A dictionary establishing a relationship with a slot and an equip
var inventory = {}

func _input(event):
  if(event.is_action_pressed("ui_hotbar_forward")):
    GetNextSlot()
  elif(event.is_action_pressed("ui_hotbar_backward")):
    GetNextSlot(false)
  elif event.is_action_pressed("hotkey1"):
    SetActiveSlot(0)
  elif event.is_action_pressed("hotkey2"):
    SetActiveSlot(1)
  elif event.is_action_pressed("hotkey3"):
    SetActiveSlot(2)
  elif event.is_action_pressed("hotkey4"):
    SetActiveSlot(3)
  elif event.is_action_pressed("hotkey5"):
    SetActiveSlot(4)
  elif event.is_action_pressed("hotkey6"):
    SetActiveSlot(5)
  elif event.is_action_pressed("hotkey7"):
    SetActiveSlot(6)
  elif event.is_action_pressed("hotkey8"):
    SetActiveSlot(7)
  elif event.is_action_pressed("hotkey9"):
    SetActiveSlot(8)
  elif event.is_action_pressed("hotkey0"):
    SetActiveSlot(9)

func _ready():
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

func SetActiveSlot(slot_num, ignoreSound=false):
  if not ignoreSound:
    emit_signal("play_audio", 1, Globals.source.sfx)
  
  # Iterate through all the hotbar slots
  for i in range(0, MAX_HOTBAR):
    var frame_hud = slots[i]
    
    # If the slot is the desired one, modify it to be selected
    if i == slot_num:
      frame_hud.set("custom_styles/normal", slot_select)
      frame_hud.set("custom_styles/pressed", slot_select)
      frame_hud.set("custom_styles/hover", slot_select)
      
      
      # TO FIX. NOT COLLECTING BY ID ANYMORE
      # Find the equip in the current slot
      for equip in playerInventory.get_children():
        # Enable the equip in the slot to be used if it selected
        if inventory[slot_num] == equip:
          equip.visible = true
          equip.set_process(true)
          equip.set_physics_process(true)
          equip.set_process_input(true)
        # If equip not selected, disable it
        else:
          equip.visible = false
          equip.set_process(false)
          equip.set_physics_process(false)
          equip.set_process_input(false)
    # If slot not current slot, normalize it
    else:
      frame_hud.set("custom_styles/normal", slot_normal)
      frame_hud.set("custom_styles/pressed", slot_normal)
      frame_hud.set("custom_styles/hover", slot_normal)

func FindOpenSlot():
  for i in range(0, slots.size()):
    if inventory[i] == null:
      return i
  return null

func AddItem(item_id):
  # Check if item is stackable
  
  # Check if there is a slot to add the item
  var slot_num = FindOpenSlot()
  if slot_num != null:
    # Add item to inventory
    var item = load(Equips.equips[str(item_id)]["instance"]).instance()
    playerInventory.add_child(item)
    item.id = item_id
    
    # Disable item from running until it is selected
    item.visible = false
    item.set_process(false)
    item.set_physics_process(false)
    item.set_process_input(false)
    inventory[slot_num] = item
    
    # Show equip in inventory frames
    var itemframe = slots[slot_num].get_node_or_null("CenterContainer/Item")
    var texture = load(Equips.equips[str(item_id)]["resource"])
    itemframe.texture = texture
    itemframe.set_size(Vector2(24, 24))
    
    # Check if item is in the hotbar and equip if so
    if IsSelectedHotbar(slot_num):
      SetActiveSlot(slot_num, true)
  else:
    # Should drop item/ not pick it up
    pass

func IsSelectedHotbar(slot_num):
  return slot_num == currentSlot
  
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
    if slot_num == currentSlot:
      inventory[slot_num].visible = true
      inventory[slot_num].set_process(true)
      inventory[slot_num].set_physics_process(true)
      inventory[slot_num].set_process_input(true)
    else:
      inventory[slot_num].visible = false
      inventory[slot_num].set_process(false)
      inventory[slot_num].set_physics_process(false)
      inventory[slot_num].set_process_input(false)

  # If the inventory is null, set texture to null
  else:
    itemframe.texture = null

func _on_slot_pressed(slot_num):
  print("[Inventory] Slot #%d selected." % [slot_num])
  
  if slotSelect1 == -1:
    # Ignore first selections if the slot is null. Cannot select anything that 
    # is null first. It is okay to select a second slot that is null, as long as
    # the first is not null.
    if inventory[slot_num] == null: return
    
    # Set the first index of slot to swap contents
    slotSelect1 = slot_num
  else:
    # Set the second index of slot to swap contents with
    slotSelect2 = slot_num

    # If the slot indices are equal, ignore the swap request. Redundant.
    if slotSelect1 == slotSelect2: return
    
    # Swap places in inventory
    if inventory[slotSelect1] != null && inventory[slotSelect2] != null:
      var temp = inventory[slotSelect1]
      inventory[slotSelect1] = inventory[slotSelect2]
      inventory[slotSelect2] = temp
    # Move slot 1 item to slot 2
    elif inventory[slotSelect1] != null && inventory[slotSelect2] == null:
      inventory[slotSelect2] = inventory[slotSelect1]
      inventory[slotSelect1] = null
    
    RefreshInventorySlots([slotSelect1, slotSelect2])
    
    # Reset the sentinel values used to determine which slots are selecte
    # -1 means no slot selected
    slotSelect1 = -1
    slotSelect2 = -1
    
