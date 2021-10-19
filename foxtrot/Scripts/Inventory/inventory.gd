extends Node

# Note: in scene hierarchy the Hud must be behind Invetory or else the hotbar
# cannot be clicked...

const MAX_HOTBAR = 10

export(String, FILE) var hotbar_hover
export(String, FILE) var hotbar_pressed
export(String, FILE) var hotbar_normal

export(String, FILE) var hotbar_select_hover
export(String, FILE) var hotbar_select_pressed
export(String, FILE) var hotbar_select_normal

var curr_slot_id : int = 0
var slots = []
var selectedSlot1 : int = -1
var selectedSlot2 : int = -1
var isInventoryHover : bool = false

var player = null
var playerInventory = null

# A dictionary establishing a relationship with a slot and an equip
var inventory = {}

func _input(event):
  if event.is_action_pressed("ui_hotbar_forward"):
    GetNextSlot(false)
  elif event.is_action_pressed("ui_hotbar_backward"):
    GetNextSlot()
  elif event.is_action_pressed("drop"):
    DropCurrentItem()
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
    
  if Globals.IsFlagSet(Globals.FLAG_INVENTORY):
    if event.is_action_pressed("fire"):
      DropSelectedItem()

func _ready():
  hotbar_hover = load(hotbar_hover)
  hotbar_pressed = load(hotbar_pressed)
  hotbar_normal = load(hotbar_normal)

  hotbar_select_hover = load(hotbar_select_hover)
  hotbar_select_pressed = load(hotbar_select_pressed)
  hotbar_select_normal = load(hotbar_select_normal)
  
  player = self.get_tree().get_root().get_node_or_null("/root/Base/Player")  
  playerInventory = self.get_tree().get_root().get_node_or_null("/root/Base/Player/Inventory")
  if playerInventory == null: playerInventory = self.get_tree().get_root().get_node_or_null("Player/Inventory")

  InitalizeInventoryUI()
  InitializeInventory()

  # Set the active slot to default to the first hotbar slot
  SetActiveSlot(0, true)

func InitializeInventory():
  # Add all the slots to put equips into 
  ## Establish the inventory array to be the size of the number of slots available
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
  if not ignoreSound: Signals.emit_signal("on_play_sfx", "res://Audio/SoundEffects/plop16.mp3")
  if active_slot_id == prev_slot_id: return
  
  curr_slot_id = active_slot_id
  
  var prev_slot = slots[prev_slot_id]
  prev_slot.set("custom_styles/hover", hotbar_hover)
  prev_slot.set("custom_styles/pressed", hotbar_pressed)
  prev_slot.set("custom_styles/normal", hotbar_normal)
  if inventory[prev_slot_id] != null:
    Helper.SetActive(inventory[prev_slot_id], false)
  
  var curr_slot = slots[active_slot_id]
  curr_slot.set("custom_styles/hover", hotbar_select_hover)
  curr_slot.set("custom_styles/pressed", hotbar_select_pressed)
  curr_slot.set("custom_styles/normal", hotbar_select_normal)
  if inventory[active_slot_id] != null:
    Helper.SetActive(inventory[active_slot_id], true)

func FindOpenSlot():
  for i in range(0, slots.size()):
    if inventory[i] == null:
      return i
  return null

func AddItem(item_to_add):
  
  # Cases
  # 1) If found stack and overflow, create new item with overflow amount
  # 2) If cant find stack, create new item with input amount
  # 3) If found stack but adding overflows, add to stack and create new item with overflow amount
  
  var item_id = item_to_add.id if typeof(item_to_add) != TYPE_INT else item_to_add
  
  # TA: changes strings to CONST later
  # If the item is stackable, attempt to stack it with item in inventory
  if Equips.equips[str(item_id)]["subtype"] == "stackable":
    
    # Find a free stack
    for item_key in inventory:
      
      # Ignore empty slots
      if inventory[item_key] == null: continue
      
      # Only add to stacks that are of the same item type and have space to add
      if inventory[item_key].id == item_id && inventory[item_key].curr_stack_amt < inventory[item_key].max_stack_amt:
        
        # TA: should stack add more than just one on purchase?
        var overflow = inventory[item_key].AddToStack(1)
        
        # Update UI to reflect new stack amount
        RefreshInventorySlot(int(item_key))
        
        # If all items were used, do no proceed in creating an item.
        if overflow == 0:
          return
      
  # Create the item if necessary
  var item = null
  if typeof(item_to_add) == TYPE_INT:
    item = load(Equips.equips[str(item_to_add)]["instance"]).instance()
    item.id = item_to_add
  else:
    item = item_to_add
  
  # Find a slot to add the item
  var slot_id = FindOpenSlot()
  if slot_id != null:

    # Add item to inventory
    if item.get_parent() != null:
      item.get_parent().remove_child(item)
    item.SetProcess(Globals.ItemProcess.Player) # TA: consider adding initalize method
    item.player_inv = self
    inventory[slot_id] = item
    playerInventory.add_child(item) # playerInventory is a container storing all items for the player

    # Update UI to reflect inventory update
    RefreshInventorySlot(slot_id)
  else:
    item.SetProcess(Globals.ItemProcess.World)
    Signals.emit_signal("on_item_drop", item, player.position)

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
  # Get the Texture2D that displays the item
  var itemframe = slots[slot_num].get_node_or_null("CenterContainer/Item")
  var count_label = slots[slot_num].get_node_or_null("ItemCountLabel")
  # If the inventory is not null, update its texture to the one in the current inventory slot
  if inventory[slot_num] != null:
    var texture = load(Equips.equips[str(inventory[slot_num].id)]["resource"])
    itemframe.texture = texture
    itemframe.set_size(Vector2(24, 24))
    
    # If the item is stackable show it's stack count
    if Equips.equips[str(inventory[slot_num].id)]["subtype"] == "stackable":
      var stack_amt = inventory[slot_num].curr_stack_amt
      if stack_amt > 0:
        count_label.visible = true
        count_label.text = str(stack_amt)
      else:
        count_label.visible = false
    else:
      count_label.visible = false
    
    # If the current slot is one of the ones being refreshed, make sure to
    # disable/enable the item in that slot
    var itemState = true if IsSelectedHotbar(slot_num) else false
    Helper.SetActive(inventory[slot_num], itemState)
    
  # If the inventory is null, set texture to null
  else:
    itemframe.texture = null
    count_label.visible = false

func RefreshInventoryForItemInUse():
  RefreshInventorySlot(curr_slot_id)
  
func _on_slot_pressed(slot_num):
  print("[Inventory] Slot #%d selected." % [slot_num])
  Signals.emit_signal("on_play_sfx", "res://Audio/SoundEffects/wet_click.wav")
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
  
func DropCurrentItem():
  DropItem(curr_slot_id)

func DropItem(idx):
  var curr_item = inventory[idx]
  if curr_item != null:
    print("[Inventory] Droppping %s from slot %d" % [curr_item.get_name(), idx])
    RemoveItem(curr_item)
    curr_item.SetProcess(Globals.ItemProcess.World)
    Signals.emit_signal("on_item_drop", curr_item, player.position)

func DropSelectedItem():
  if selectedSlot1 != -1 && not isInventoryHover:
    DropItem(selectedSlot1)
    selectedSlot1 = -1
    selectedSlot2 = -1

func _on_Inventory_mouse_entered():
  isInventoryHover = true
  Globals.isManagingInv = true

func _on_Inventory_mouse_exited():
  isInventoryHover = false
  Globals.isManagingInv = false  
