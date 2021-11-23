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
  # Do not let the player use the inventory if any of these flags are set
  if Globals.IsFlagSet(Globals.FLAG_DEV_OPEN) || Globals.IsFlagSet(Globals.FLAG_PAUSED) || Globals.IsFlagSet(Globals.FLAG_DEAD): return
  
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
    ToggleInventory()

func _init():
  # Used to add item to player inventory on purchase/pickup
  if Signals.connect("on_inventory_add_item", self, "AppendItem") != OK:
    printerr("[Inventory] Error. Failed to connect to signal on_inventory_add_item...")
  
  # Used to add stackable item to player inventory on purchase/pickup
  if Signals.connect("on_inventory_add_item_stack", self, "AppendItemStack") != OK:
    printerr("[Inventory] Error. Failed to connect to signal on_inventory_add_item_stack...")

func _ready():
  # Turn inventory off by default
  ToggleInventory(true, false)

  slot_theme = load(slot_theme)
  slot_select_theme = load(slot_select_theme)

  # Load references for the nodes
  inventory_stash = get_node_or_null(inventory_stash)
  hotbar_ui       = get_node_or_null(hotbar_ui)
  inventory_ui    = get_node_or_null(inventory_ui)
  
  # Setup UI 
  InitalizeInventoryUI()
  InitializeInventory()
  
  # Inform the game that the inventory is now setup and can be accessed
  Signals.emit_signal("on_inventory_loaded", self)

  # Set the active slot to default to the first hotbar slot
  SetActiveSlot(0, true)

# --------------------------------------------------------------------------------------------------
# Inventory Functions
# --------------------------------------------------------------------------------------------------
func AddItem(item, slot_id):
  # Purpose   : Adds the item to the provided slot
  # Param(s)  :
  # - item    : the node w/ an item.gd derived script attached
  # - slot_id : the id of the slot to put the item into
  # Return(s) : N/A

  # Add item to the player stash so the player can quickly use it
  if item.get_parent() != null:
    item.get_parent().remove_child(item)
  inventory_stash.add_child(item)
  
  # Set item physics to interact with player
  item.SetProcess(Globals.ItemProcess.Hidden, self)
  item.set_global_position(self.get_parent().get_global_position())
  
  # Add item to the inventory
  inventory[slot_id] = item

  # Equip the armor/accessory
  if slot_id == ARMOR_SLOT_ID:
    item.Equip()
  elif slot_id > ARMOR_SLOT_ID:
    item.Equip()

  # Update UI to reflect inventory update
  RefreshInventorySlot(slot_id)

func AddItemToStack(item_id, amount): 
  # Purpose   : Adds the item to a stack in the player's inventory if found. Else it calculates
  # overfill.
  # Param(s)  :
  # - item    : the node w/ an item.gd derived script attached
  # - slot_id : the amount of the item to add to a stack if found
  # Return(s) : the quantity successfully added to an existing stack
  
  # Find a free stack in the inventory
  var slot_id = FindStackSlot(item_id)
  
  if slot_id == -1:
    # If no slots found, return the original amount. No items could be added.
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
  # Purpose   : Adds the item to the player inventory
  # Param(s)  :
  # - item_to_add    : the node w/ an item.gd derived script attached to add to the inventory or an id (int)
  # Return(s) : N/A
  
  # Create the item if necessary:
  #   - Only when an ID is presented, we create the item and add it
  
  var item = CreateItem(item_to_add)
  
  # Find a slot to add the item
  var slot_id = FindEmptySlot()
  if slot_id != null:
    AddItem(item, slot_id)
    return item
    
  # Drop item into the world, where its parent global position is, if there is no space to add the item
  else:
    DropItem(item)
    return item

func AppendItemStack(item_to_add, amount=1):
  # Purpose   : Adds the item to the player inventory with the give amount
  # Param(s)  :
  # - item_to_add    : the node w/ an item.gd derived script attached to add to the inventory or an id (int)
  # - amount : the amount to add to the item's stack
  # Return(s) : N/A
  
  # Stackable items should be stacked with items (that are not already maxed) with the same ID

  # Cases to consider for adding to inventory slots
  # 1) If a slot is found stack and the addition overflows, create a new item with overflow amount
  # 2) If stack not found, create a new item with the input amount
  # 3) If found stack but adding overflows, add to stack and create new item with overflow amount
  
  # Create the item if necessary:
  #   - Only when an ID is presented, we create the item and add it
  #   - If there is an overflow from stacking, create an item
  var item_id = item_to_add.id if typeof(item_to_add) != TYPE_INT else item_to_add
  
  # While there is still an overflow, create a new item with the overflow amount
  var overflow = AddItemToStack(item_id, amount)
  
  while overflow > 0:
    var item = AppendItem(item_id)
    var add_stack_amt = item.max_stack_amt if overflow - item.max_stack_amt >= 0 else overflow
    item.curr_stack_amt = add_stack_amt
    overflow -= add_stack_amt
  RefreshInventorySlots(null)

func CreateItem(item_to_add):
  # Purpose   : Creates an item if ID provide, else it returns the item as is
  # Param(s)  : N/A
  # - item_to_add    : the node w/ an item.gd derived script attached to add to the inventory or an id (int)
  # Return(s) : N/A
  
  # If instance of an item is provided, do not create an instance
  # If ID provided, create the item and add it
  var item = item_to_add
  if typeof(item_to_add) == TYPE_INT:
    item = load(Equips.equips[item_to_add].instance).instance()
    item.id = item_to_add

  return item

func DropCurrentItem():
  # Purpose   : Drops the currently selected item in the player's hotbar
  # Param(s)  : N/A
  # Return(s) : N/A
  DropItemFromSlot(curr_slot_id)

func DropItem(item):
  # Purpose   : Drops the item into the level for the player to pick up.
  # Param(s)  :
  # - item    : the item to drop
  # Return(s) : N/A
  
  # Setup the item for the level
  item.SetProcess(Globals.ItemProcess.Dynamic, self)
  
  Signals.emit_signal("on_item_drop", item, self.get_parent().get_global_position())

func DropItemFromSlot(slot_id):
  # Purpose   : Drops the currently selected item from a particular slot
  # Param(s)  :
  # - slot_id : the slot to drop the item from
  # Return(s) : N/A
  
  var curr_item = inventory[slot_id]
  if curr_item != null:
    print_debug("[Inventory] Droppping %s from slot %d" % [curr_item.get_name(), slot_id])
    RemoveItemFromSlot(slot_id)
    DropItem(curr_item)
    
    # Make sure to update the player's stats when the item is dropped if it is equipped
    UpdateEquipmentOnDrop(curr_item, slot_id)

func DropSelectedItem():
  # Purpose   : Drops the currently selected item while attempting a swap operation
  # Param(s)  :
  # Return(s) : N/A
  if selectedSlot1 != -1:
    DropItemFromSlot(selectedSlot1)
    
    # Reset selected slots so the player can swap 2 new items
    selectedSlot1 = -1
    selectedSlot2 = -1
  else:
    print_debug("[Inventory] Error. No item to drop...")

func EraseInventory():
  # Purpose   : Delete all items from the player's inventory
  # Param(s)  :
  # Return(s) : N/A
  
  for i in range(0, SLOT_COUNT):
    if inventory[i] != null:
      var temp = inventory[i]
      DropItemFromSlot(i)
      temp.queue_free()
      inventory[i] = null
  RefreshInventorySlots()

func FindEmptySlot():
  # Purpose   : Finds a slot that hasn't been taken
  # Param(s)  :
  # Return(s) : the slot id. If none found, returns false
  
  # Note: the last few slots are dedicated for armors/accessories and should not be searched
  for i in range(0, ARMOR_SLOT_ID):
    if inventory[i] == null : return i
    
  # No slot found. Return null
  return null
  
func FindStackSlot(item_id):
  # Purpose   : Finds a matching item slot for the given item id that is not maxed out in capacity
  # Param(s)  :
  # - item_id : the ID of the item to search for in the inventory that hasn't been maxed
  # Return(s) : N/A
  
  # Search all items in inventory (not including armor/accessories)
  for i in range(0, ARMOR_SLOT_ID):
    
    var curr_item = inventory[i]
    
    # Ignore empty slots
    if curr_item == null: continue
    
    # Only add to a stack that has the same item type and is not at full capacity
    if item_id == curr_item.id && curr_item.curr_stack_amt < curr_item.max_stack_amt:
      return i
  
  # No slot found
  return -1

func InitializeInventory():
  # Purpose   : Fill the dictionary of the inventory to be null references and to be the size of the
  # provided slots
  # Param(s)  :
  # Return(s) : N/A
  
  # Add all the slots to put equips into 
  ## Establish the inventory array to be the size of the number of slots available
  for i in range(0, SLOT_COUNT):
    inventory[i] = null

func RemoveItem(item):
  # Purpose   : Removes the item's reference from the player's inventory
  # Param(s)  :
  # - item    : the item to remove the reference to in the inventory
  # Return(s) : N/A
  
  # Search for the item and remove it
  for i in range(0, slots.size()):
    if inventory[i] == item:
      print_debug("[Inventory] Removing %s from inventory at slot %d" % [inventory[i].get_name(), i])
      inventory[i] = null
      RefreshInventorySlot(i)
      return OK
      
  # Failed to remove item since not found in inventory
  return FAILED

func RemoveItemFromSlot(slot_id):
  # Purpose   : Removes an item from a particular slot
  # Param(s)  :
  # slot_id   : the slot to remove the item from
  # Return(s) : N/A
  print_debug("[Inventory] Removing %s from inventory at slot %d" % [inventory[slot_id].get_name(), slot_id])
  inventory[slot_id] = null
  RefreshInventorySlot(slot_id)

func SetActiveSlot(active_slot_id : int, prev_slot_id : int, ignoreSound=false):
  # Purpose   : Sets the current active hotbar slot by highlighting it
  # Param(s)  : 
  # - active_slot_id : the id of the slot to highlight
  # - prev_slot_id   : the previous highlighted slot
  # - ignoreSound    : enable/disable sound on slot switch
  # Return(s) : N/A
  
  if not ignoreSound: Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/bubbles_1.wav", 3)
  
  # If the current slot equals the previous slot, ignore. Redundant
  if active_slot_id == prev_slot_id: return
  
  # Set the new current slot id
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
  # If item is type weapon...
  # If item is type defense...
  # If item is...
# --------------------------------------------------------------------------------------------------
# Inventory UI Functions
# --------------------------------------------------------------------------------------------------
func InitalizeInventoryUI():
  # Purpose   : Adds all the slots in current inventory node so the player can use them
  # Param(s)  :
  # Return(s) : N/A
  
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
  # Purpose   : Highlights the next slot. Can only go forwards/backwards.
  # Param(s)  : 
  # - moveForward : gets the next slot if true, else gets the previous
  # Return(s) : N/A
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
  # Purpose   : Checks if the provided slot id is the current activated hotbar slot
  # Param(s)  :
  # - slot_num: the id of the slot to check if it is the active hotbar slot
  # Return(s) : True if active slot, else false
  return slot_num == curr_slot_id

func RefreshInventorySlots(refreshSlots=null):
  # Purpose   : Refreshes all inventory slots unless specific slots are provided, then only those
  # slots are updated.
  # Param(s)  :
  # - refreshSlots : the array of slot id's to refresh
  # Return(s) : N/A
  
  # Expects an array
  # Loop through all the slots and update their textures
  if refreshSlots == null:
    for i in range(0, slots.size()):
      RefreshInventorySlot(i)
  else:
    for slot in refreshSlots:
      RefreshInventorySlot(slot)

func RefreshInventorySlot(slot_num : int):
  # Purpose   : Refreshses the slot UI for a given slot
  # Param(s)  :
  # - slot_num: the ID of the slot to refresh
  # Return(s) : N/A
  
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
    else:
      item.SetProcess(Globals.ItemProcess.Hidden, self)
    
  # If the inventory is null, set texture to null
  else:
    #print_debug("[Inventory] Slot at %d is null..." % [slot_num])
    itemframe.texture = null
    count_label.visible = false

func RefreshInventoryForItemInUse():
  # Purpose   : Refresh the slot of currently active item.
  # Param(s)  :
  # Return(s) : N/A
  RefreshInventorySlot(curr_slot_id)

func ToggleInventory(forceState=false, state=false):
  # Purpose   : Turn on/off the inventory UI
  # Param(s)  :
  # - forceState : set the visibility of the inventory UI to state instead of toggling
  # - state   : the bool value to set the inventory UI visibility
  # Return(s) : N/A
  
  Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/whoosh.wav", 3)
  
  var ui = $UI/Inventory
  
  # Determine new state of UI visibility
  var new_state = !ui.visible
  
  if forceState:
    $UI/Inventory.visible = state
  
  if new_state:
    ui.visible = true
    $AnimationPlayer.play("open")
  else:
    $AnimationPlayer.play("close")
    
    # Wait for close animation to finish so the player can see it
    while $AnimationPlayer.is_playing():
      yield(get_tree(), "idle_frame")
    ui.visible = false
    
  # Pause/unpause game if inventory open/closed
  Globals.SetFlag(Globals.FLAG_INVENTORY, new_state)

func _on_slot_pressed(slot_num):
  # Purpose   : Performs swap operation for inventory items.
  # Param(s)  :
  # - slot_num: ID of slot to consider for swap operation
  # Return(s) : N/A
  print_debug("[Inventory] Slot #%d selected." % [slot_num])
  Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/bubbles_1.wav", 3)
  if selectedSlot1 == -1:
    # Ignore first selection if the slot is null. Cannot select anything that 
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

        # After we reach here, only valid swap operations can be performed!

        # Swap the two items normally
        ## Equip/unequip the armor/accessory
        UpdateEquipmentOnSwap(inventory[selectedSlot1],inventory[selectedSlot2], selectedSlot1, selectedSlot2)
        
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

        # After we reach here, only valid swap operations can be performed!        
        
        # Equip/unequip the armor/accessory
        UpdateEquipmentOnMove(inventory[selectedSlot1], selectedSlot1, selectedSlot2)
        
        print_debug("Swapping from slot #%d (%s) to slot #%d..." % [selectedSlot1, inventory[selectedSlot1].get_name(), selectedSlot2])      
        inventory[selectedSlot2] = inventory[selectedSlot1]
        inventory[selectedSlot1] = null
      
      RefreshInventorySlots([selectedSlot1, selectedSlot2])
      ResetSelection()

func ResetSelection():
  # Purpose   : Reset selected slots considered for swap operation
  # Param(s)  :
  # Return(s) : N/A
  
  # Reset the sentinel values used to determine which slots are selected
  # -1 means no slot selected
  selectedSlot1 = -1
  selectedSlot2 = -1

func _on_Inventory_mouse_entered():
  # Purpose   : Inform the inventory that inventory UI is hovered over
  # Param(s)  :
  # Return(s) : N/A
  on_inventory_hovered = true

func _on_Inventory_mouse_exited():
  # Purpose   : Inform the inventory that inventory UI is longer being hovered over
  # Param(s)  :
  # Return(s) : N/A
  on_inventory_hovered = false

func GetItemInfo(item):
  # Purpose   : Gets the dictionary containing the item attributes.
  # Param(s)  :
  # item      : a node w/ an item.gd dervied script attached
  # Return(s) : N/A
  return Equips.equips[item.id]

func UpdateEquipmentOnMove(item_from, slot_from, slot_to):
  # Purpose   : Refresh the player's stats when selected items are moved
  # Param(s)  :
  # - item_from : the item being moved
  # - slot_from : the slot id of the item being moved
  # - slot_to   : the slot id the item is being moved to
  # Return(s) : N/A
  
  # If swapping from the armor/accessory slots to the inventory, unequip the item
  if slot_from >= ARMOR_SLOT_ID:
    item_from.Unequip()

  # If swapping from the inventory to the armor/accesory slots, equip the item
  if slot_to >= ARMOR_SLOT_ID:
    item_from.Equip()
    
func UpdateEquipmentOnSwap(item_from, item_to, slot_from, slot_to):
  # Purpose   : Refresh the player's stats when selected items are swapped
  # Param(s)  :
  # - item_from : the first item selected
  # - item_to   : the second item selected
  # - slot_from : the slot id of the first item
  # - slot_to   : the slot id of the second item
  # Return(s) : N/A
  
  # If we are swapping an item to the armor/accessory slot, unequip the current armor/accessory and equip the new armor/accessory
  if slot_to >= ARMOR_SLOT_ID:
    item_from.Equip()
    item_to.Unequip()
    
  elif slot_from >= ARMOR_SLOT_ID:
    item_to.Equip()
    item_from.Unequip()
    
func UpdateEquipmentOnDrop(item, slot):
  # Purpose   : Refresh the player's stats when selected items are dropped from inventory
  # Param(s)  :
  # - item : the item being moved
  # - slot : the slot id of the item being moved
  # Return(s) : N/A
  
  if slot >= ARMOR_SLOT_ID:
    item.Unequip()
# --------------------------------------------------------------------------------------------------
# Inventory Save Functions
# --------------------------------------------------------------------------------------------------
func RestoreInventoryData(items):
  # Purpose   : Restores the player's inventory given a save file
  # Param(s)  :
  # - items   : a dictionary with all the items the player contains alongside their attribute values
  # Return(s) : N/A
  
  print_debug("\n[Inventory] Restoring player inventory...")
  #print_debug(inventory)
  
  # Recreate every item in the player's inventory and place them in their original slots
  for key in items.keys():
    var slot_id = int(key)
    RestoreItem(items[key], slot_id)
  
  # Refresh inventory to reflect restoration
  RefreshInventorySlots()

func InventoryToJSON():
  # Purpose   : Convert the player's inventory into a JSON format to store
  # Param(s)  :
  # Return(s) : N/A
  var dict = {}
  
  # Convert each item into a JSON to store in a dictionary with their associated slot
  # {slot id : item in JSON format}
  for i in range(slots.size()):
    if inventory[i] != null:
      dict[i] = inventory[i].ToJSON()
  return dict
    
func RestoreItem(item, slot_id):
  # Purpose   : Inform the inventory that inventory UI is hovered over
  # Param(s)  :
  # - item    : the JSON representation of the item to restore
  # - slot_id : the slot ID to restore the item to
  # Return(s) : N/A
  var id = int(item[Save.SAVE_ID])
  
  # Load up an instance of the item and place it in the player inventory node in the base scene
  var item_instance = CreateItem(id)
  AddItem(item_instance, slot_id)
  
  # Restore the item's data
  item_instance.FromJSON(item)
  return item_instance
