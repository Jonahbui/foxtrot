extends Node
# --------------------------------------------------------------------------------------------------
# Slots Information
# --------------------------------------------------------------------------------------------------
# 54 slots are expected in total:
#   - Slots 0-9 are for the hotbar slots
#   - Slots 10-49 are for the inventory slots
#   - Slot 50 is for armor
#   - Slots 51-53 are for accessories
const SLOT_COUNT = 54
const MAX_HOTBAR = 10
const ARMOR_SLOTS = 4
const ARMOR_SLOT_ID = SLOT_COUNT - ARMOR_SLOTS

# --------------------------------------------------------------------------------------------------
# Variables
# --------------------------------------------------------------------------------------------------
# Textures to change to if a hotbar slot is not selected (default)
export(String, FILE) var slot_theme

# Textures to change to if a hotbar slot is selected
export(String, FILE) var slot_select_theme

# Node references
## This stores the item instance so we can enable/disable them when the player needs to use it
export(NodePath) onready var inventory_stash
## The node container that has all the hotbar slots to address
export(NodePath) onready var hotbar_ui
## The node container that has all the inventory slots to address
export(NodePath) onready var inventory_ui

# The current slot the player has selected in the hotbar
var curr_slot_id : int = 0

# An array of all the slots in the player inventory
var slots = []

# The slots the player clicked on while trying to perform an inventory swap operation
# Used to know which slots to swap. -1 is a sentinel value
var selectedSlot1 : int = -1
var selectedSlot2 : int = -1

# Determines whether or not the player's cursor is on the inventory UI
var on_inventory_hovered : bool = false

# A dictionary establishing a relationship with a slot and an equip
var inventory = {}

# --------------------------------------------------------------------------------------------------
# Godot Functions
# --------------------------------------------------------------------------------------------------
func _input(event):
  if Globals.IsFlagSet(Globals.FLAG_DEV_OPEN): return
  
  # Cycles through the hotbar
  if event.is_action_pressed("ui_hotbar_forward"):
    GetNextSlot(false)
  elif event.is_action_pressed("ui_hotbar_backward"):
    GetNextSlot()
    
  # Drops the currently equipped item to the world
  elif event.is_action_pressed("drop"):
    DropCurrentItem()
    
  # Change selected slot to the according slot in the hotbar
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
  
  # Drops the selected item
  elif event.is_action_pressed("fire"):
    # Drops the item the player has selected
    if Globals.IsFlagSet(Globals.FLAG_INVENTORY) && not on_inventory_hovered:
      DropSelectedItem()
  
  # Opens the inventory
  elif event.is_action_pressed("ui_inventory"):
    var ui = $UI/Inventory
    ui.visible = !ui.visible
    Globals.SetFlag(Globals.FLAG_INVENTORY, ui.visible)

func _init():
  if Signals.connect("on_inventory_add_item", self, "AppendItem") != OK:
    printerr("[Inventory] Error. Failed to connect to signal on_inventory_add_item...")
  if Signals.connect("on_inventory_add_item_stack", self, "AppendItemStack") != OK:
    printerr("[Inventory] Error. Failed to connect to signal on_inventory_add_item_stack...")

func _ready():
  ToggleInventory(true, false)

  slot_theme = load(slot_theme)
  slot_select_theme = load(slot_select_theme)

  # Load references for the nodes
  inventory_stash = get_node_or_null(inventory_stash)
  hotbar_ui       = get_node_or_null(hotbar_ui)
  inventory_ui    = get_node_or_null(inventory_ui)
  
  InitalizeInventoryUI()
  InitializeInventory()
  Signals.emit_signal("on_inventory_loaded", self)

  # Set the active slot to default to the first hotbar slot
  SetActiveSlot(0, true)

# --------------------------------------------------------------------------------------------------
# Inventory Functions
# --------------------------------------------------------------------------------------------------
func AddItem(item, slot_id):
  
  # Add item to the player stash so the player can quickly use it
  if item.get_parent() != null:
    item.get_parent().remove_child(item)
  inventory_stash.add_child(item)
  
  # Set item physics to interact with player
  item.SetProcess(Globals.ItemProcess.Hidden, self)
  item.set_global_position(self.get_parent().get_global_position())
  
  # Add item to the inventory
  inventory[slot_id] = item

  # Update UI to reflect inventory update
  RefreshInventorySlot(slot_id)

func AddItemToStack(item_id, amount):
  # Find a free stack in the inventory
  var slot_id = FindStackSlot(item_id)
  
  if slot_id == -1:
    # If no slots found, return the original amount. No items could be added
    return amount
  else:
    # Calculate how much overflow from adding item (if any)
    var overflow = inventory[slot_id].AddToStack(amount)
    
    if overflow == 0:
      # Update UI to reflect new stack amount
      RefreshInventorySlot(slot_id)
      return 0
    else:
      return overflow

func AppendItem(item_to_add):
  # Create the item if necessary:
  #   - Only when an ID is presented, we create the item and add it
  
  var item = CreateItem(item_to_add)
  
  # Find a slot to add the item
  var slot_id = FindEmptySlot()
  if slot_id != null:
    AddItem(item, slot_id)
    return item
    
  # Drop item into the world, where its parent position is, if there is no space to add the item
  else:
    DropItem(item)
    return item

func AppendItemStack(item_to_add, amount=1):
  # Stackable items should be stacked with items (that are not already maxed) with the same ID

  # Cases to consider for adding to inventory slots
  # 1) If a slot is found stack and the addition overflows, create a new item with overflow amount
  # 2) If stack not found, create a new item with the input amount
  # 3) If found stack but adding overflows, add to stack and create new item with overflow amount
  
  # Create the item if necessary:
  #   - Only when an ID is presented, we create the item and add it
  #   - If there is an overflow from stacking, create an item
  var item_id = item_to_add.id if typeof(item_to_add) != TYPE_INT else item_to_add
  
  # While there is still an overflow, create new item
  var overflow = AddItemToStack(item_id, amount)
  
  while overflow > 0:
    var item = AppendItem(item_id)
    var add_stack_amt = item.max_stack_amt if overflow - item.max_stack_amt >= 0 else overflow
    item.curr_stack_amt = add_stack_amt
    overflow -= add_stack_amt
  RefreshInventorySlots(null)

func CreateItem(item_to_add):
  # If instance of an item is provided, do not create an instance
  # If ID provided, create the item and add it
  var item = item_to_add
  if typeof(item_to_add) == TYPE_INT:
    item = load(Equips.equips[item_to_add].instance).instance()
    item.id = item_to_add

  return item

func DropCurrentItem():
  DropItemFromSlot(curr_slot_id)

func DropItem(item):
  item.SetProcess(Globals.ItemProcess.Dynamic, self)
  Signals.emit_signal("on_item_drop", item, self.get_parent().get_global_position())

func DropItemFromSlot(slot_id):
  var curr_item = inventory[slot_id]
  if curr_item != null:
    print_debug("[Inventory] Droppping %s from slot %d" % [curr_item.get_name(), slot_id])
    RemoveItemFromSlot(slot_id)
    DropItem(curr_item)

func DropSelectedItem():
  if selectedSlot1 != -1:
    DropItemFromSlot(selectedSlot1)
    selectedSlot1 = -1
    selectedSlot2 = -1
  else:
    print_debug("[Inventory] Error. No item to drop...")

func FindEmptySlot():
  # The last few slots are dedicated for armors/accessories and should not be searched
  for i in range(0, ARMOR_SLOT_ID):
    if inventory[i] == null : return i
    
  # No slot found. Return null
  return null
  
func FindStackSlot(item_id):
  for i in range(0, ARMOR_SLOT_ID):
    
    var curr_item = inventory[i]
    
    # Ignore empty slots
    if curr_item == null: continue
    
    # Only add to a stack that has the same item type and is not at full capacity
    if item_id == curr_item.id && curr_item.curr_stack_amt <= curr_item.max_stack_amt:
      return i
  return -1

func InitializeInventory():
  # Add all the slots to put equips into 
  ## Establish the inventory array to be the size of the number of slots available
  for i in range(0, SLOT_COUNT):
    inventory[i] = null

func RemoveItem(item):
  for i in range(0, slots.size()):
    if inventory[i] == item:
      print_debug("[Inventory] Removing %s from inventory at slot %d" % [inventory[i].get_name(), i])
      inventory[i] = null
      RefreshInventorySlot(i)
      return OK
  return FAILED

func RemoveItemFromSlot(slot_id):
  print_debug("[Inventory] Removing %s from inventory at slot %d" % [inventory[slot_id].get_name(), slot_id])
  inventory[slot_id] = null
  RefreshInventorySlot(slot_id)

func SetActiveSlot(active_slot_id : int, prev_slot_id : int, ignoreSound=false):
  if not ignoreSound: Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/bubbles_1.wav", 3)
  if active_slot_id == prev_slot_id: return
  
  curr_slot_id = active_slot_id
  
  # Set the theme of the previous slot to be a normal slot
  var prev_slot = slots[prev_slot_id]
  prev_slot.set_theme(slot_theme)
  
  # Set the previous item hidden if present in slot
  var prev_item = inventory[prev_slot_id]
  if prev_item != null: prev_item.SetProcess(Globals.ItemProcess.Hidden, self)

  # Set the theme of the current slot to be a selected slot
  var curr_slot = slots[active_slot_id]
  curr_slot.set_theme(slot_select_theme)
  
  # Set the current item active if present in slot
  var curr_item = inventory[curr_slot_id]
  if curr_item != null: curr_item.SetProcess(Globals.ItemProcess.Active, self)
  # If item is type weapon.
  # If item is type defense update player defense
  # If item is
# --------------------------------------------------------------------------------------------------
# Inventory UI Functions
# --------------------------------------------------------------------------------------------------
func InitalizeInventoryUI():
  # Append hotbar slots
  slots.append_array(hotbar_ui.get_children())
  
  # Append inventory slots
  var inventory_slots = inventory_ui.get_node("SlotGridContainer")
  slots.append_array(inventory_slots.get_children())
  
  # Append armor/accessories slots
  var armor_slots = inventory_ui.get_node("ArmorContainer")
  slots.append_array(armor_slots.get_children())
  
  # Need to set slot value so the inventory knows which slots to swap
  for i in range(0, SLOT_COUNT):
    slots[i].connect("pressed", self, "_on_slot_pressed", [i])
    slots[i].connect("mouse_entered", self, "_on_Inventory_mouse_entered")
    slots[i].connect("mouse_exited", self, "_on_Inventory_mouse_exited")

func GetNextSlot(moveForward=true):
  # Keep track of the old slot, so that we know which slot to change textures for since it will not
  # be selected any longer.
  var prev_slot_id = curr_slot_id
  
  # Calculate the new slot id based off whether we are incrementing up or down the hotbar
  var new_slot_id = curr_slot_id+1 if moveForward else curr_slot_id-1
  
  # Make sure the hotbar wraps over if the index goes out of bounds
  if new_slot_id >= MAX_HOTBAR:
    new_slot_id = 0
  elif new_slot_id < 0:
    new_slot_id = MAX_HOTBAR - 1
  
  SetActiveSlot(new_slot_id, prev_slot_id)

func IsSelectedHotbar(slot_num):
  return slot_num == curr_slot_id

func RefreshInventorySlots(refreshSlots):
  # Expects an array
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
  var item = inventory[slot_num]
  if item != null:
    #print_debug("[Inventory] Slot at %d is being refreshed..." % [slot_num])
    
    var texture = load(Equips.equips[item.id].resource)
    itemframe.texture = texture
    itemframe.set_size(Vector2(24, 24))
    
    # If the item is stackable show it's stack count
    if Equips.equips[item.id].subtype == Equips.Subtype.stackable:
      var stack_amt = item.curr_stack_amt
      if stack_amt > 0:
        count_label.visible = true
        count_label.text = str(stack_amt)
      else:
        count_label.visible = false
    else:
      count_label.visible = false

    # If the current slot is one of the ones being refreshed, make sure to
    # disable/enable the item in that slot
    if IsSelectedHotbar(slot_num):
      item.SetProcess(Globals.ItemProcess.Active, self)
    
  # If the inventory is null, set texture to null
  else:
    #print_debug("[Inventory] Slot at %d is null..." % [slot_num])
    itemframe.texture = null
    count_label.visible = false

func RefreshInventoryForItemInUse():
  RefreshInventorySlot(curr_slot_id)

func ToggleInventory(forceState=false, state=false):
  if forceState:
    $UI/Inventory.visible = state
  else:
    $UI/Inventory.visible = !$UI/Inventory.visible
  Globals.SetFlag(Globals.FLAG_INVENTORY, $UI/Inventory.visible)

func _on_slot_pressed(slot_num):
  print_debug("[Inventory] Slot #%d selected." % [slot_num])
  Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/bubbles_1.wav", 3)
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
    if selectedSlot1 != selectedSlot2: 
    
      # Swap places in inventory for item in slot 1 with item in slot2
      if inventory[selectedSlot1] != null && inventory[selectedSlot2] != null:
        
        var item_slot1 = GetItemInfo(inventory[selectedSlot1])
        var item_slot2 = GetItemInfo(inventory[selectedSlot2])
        
        # If swapping armor with non-armor piece or swapping non-armor into non armor slot, reject.
        if ( (item_slot1.type == Equips.Type.armor && item_slot2.type != Equips.Type.armor) || (item_slot1.type != Equips.Type.armor && item_slot2.type == Equips.Type.armor) ) && (selectedSlot1 == ARMOR_SLOT_ID || selectedSlot2 == ARMOR_SLOT_ID):
          print_debug("Cannot swap from slot #%d (%s) to slot #%d(%s). Invalid slots for items..." % [selectedSlot1, inventory[selectedSlot1].get_name(), selectedSlot2, inventory[selectedSlot2].get_name()])            
          ResetSelection()
          return
        
        # If swapping an armor piece with accessory piece in equip slots, reject.
        if ( (item_slot1.type == Equips.Type.accessory && item_slot2.type != Equips.Type.accessory) || (item_slot1.type != Equips.Type.accessory && item_slot2.type == Equips.Type.accessory) ) && (selectedSlot1 >= ARMOR_SLOT_ID || selectedSlot2 >= ARMOR_SLOT_ID):
          print_debug("Cannot swap from slot #%d (%s) to slot #%d(%s). Invalid slots for items..." % [selectedSlot1, inventory[selectedSlot1].get_name(), selectedSlot2, inventory[selectedSlot2].get_name()])            
          ResetSelection()
          return

        # Swap the two items normally
        print_debug("Swapping from slot #%d (%s) to slot #%d(%s)..." % [selectedSlot1, inventory[selectedSlot1].get_name(), selectedSlot2, inventory[selectedSlot2].get_name()])      
        var temp = inventory[selectedSlot1]
        inventory[selectedSlot1] = inventory[selectedSlot2]
        inventory[selectedSlot2] = temp
      
      # Move slot 1 item to slot 2
      elif inventory[selectedSlot1] != null && inventory[selectedSlot2] == null:
        
        var item_slot1 = GetItemInfo(inventory[selectedSlot1])
        
        # If moving non-armor piece to equip, reject.
        if item_slot1.type != Equips.Type.armor && selectedSlot2 == ARMOR_SLOT_ID:
          print_debug("Cannot swap from slot #%d (%s) to slot #%d. Invalid slots for items..." % [selectedSlot1, inventory[selectedSlot1].get_name(), selectedSlot2])      
          ResetSelection()
          return
          
        # If moving non-accessory piece to equip, reject.
        elif item_slot1.type != Equips.Type.accessory && selectedSlot2 > ARMOR_SLOT_ID:
          print_debug("Cannot swap from slot #%d (%s) to slot #%d. Invalid slots for items..." % [selectedSlot1, inventory[selectedSlot1].get_name(), selectedSlot2])      
          ResetSelection()
          return
        
        print_debug("Swapping from slot #%d (%s) to slot #%d..." % [selectedSlot1, inventory[selectedSlot1].get_name(), selectedSlot2])      
        inventory[selectedSlot2] = inventory[selectedSlot1]
        inventory[selectedSlot1] = null
      
      RefreshInventorySlots([selectedSlot1, selectedSlot2])
      ResetSelection()

func ResetSelection():
  # Reset the sentinel values used to determine which slots are selected
  # -1 means no slot selected
  selectedSlot1 = -1
  selectedSlot2 = -1

func _on_Inventory_mouse_entered():
  on_inventory_hovered = true
  Globals.is_managing_inventory = true

func _on_Inventory_mouse_exited():
  on_inventory_hovered = false
  Globals.is_managing_inventory = false  

func GetItemInfo(item):
  return Equips.equips[item.id]

# --------------------------------------------------------------------------------------------------
# Inventory Save Functions
# --------------------------------------------------------------------------------------------------
func RestoreInventoryData(items):
  print_debug("\n[Inventory] Restoring player inventory...")
  #print_debug(inventory)
  
  # Recreate every item in the player's inventory and place them in their original slots
  for key in items.keys():
    var slot_id = int(key)
    RestoreItem(items[key], slot_id)
  
  # Refresh inventory to reflect restoration
  RefreshInventorySlots(null)

func InventoryToJSON():
  var dict = {}
  
  # Convert each item into a JSON to store in a dictionary with their associated slot
  # {slot id : item in JSON format}
  for i in range(slots.size()):
    if inventory[i] != null:
      dict[i] = inventory[i].ToJSON()
  return dict
    
func RestoreItem(item, slot_id):
  var id = int(item[Save.SAVE_ID])
  
  # Load up an instance of the item and place it in the player inventory node in the base scene
  var item_instance = CreateItem(id)
  AddItem(item_instance, slot_id)
  
  # Restore the item's data
  item_instance.FromJSON(item)
  return item_instance
