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
# Textures to change to if a hotbar is not selected
export(String, FILE) var hotbar_hover
export(String, FILE) var hotbar_pressed
export(String, FILE) var hotbar_normal

# Textures to change to if a hotbar is selected
export(String, FILE) var hotbar_select_hover
export(String, FILE) var hotbar_select_pressed
export(String, FILE) var hotbar_select_normal

# Node references
export(NodePath) onready var inventory_stash
export(NodePath) onready var hotbar_ui
export(NodePath) onready var inventory_ui

# The current slot the player has selected in the hotbar
var curr_slot_id : int = 0

# An array of all the slots in the player inventory
var slots = []

# The slots the player clicked on while trying to perform an inventory swap operation
var selectedSlot1 : int = -1
var selectedSlot2 : int = -1

# Determines whether or not the player's cursor is on the inventory UI
var isInventoryHover : bool = false

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
  elif event.is_action_pressed("fire"):
    # Drops the item the player has selected
    if Globals.IsFlagSet(Globals.FLAG_INVENTORY):
      DropSelectedItem()
  # Open the 
  elif event.is_action_pressed("ui_inventory"):
    var ui = $UI/Inventory
    ui.visible = !ui.visible
    Globals.SetFlag(Globals.FLAG_INVENTORY, ui.visible)

func _init():
  Signals.connect("on_inventory_add_item", self, "AppendItem")
  Signals.connect("on_inventory_add_item_stack", self, "AppendItemStack")

func _ready():
  ToggleInventory(true, false)

  # Load the textures for the hotbar
  hotbar_hover    = load(hotbar_hover)
  hotbar_pressed  = load(hotbar_pressed)
  hotbar_normal   = load(hotbar_normal)

  hotbar_select_hover   = load(hotbar_select_hover)
  hotbar_select_pressed = load(hotbar_select_pressed)
  hotbar_select_normal  = load(hotbar_select_normal)

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
  item.SetProcess(Globals.ItemProcess.Player, self)
  item.set_global_position(self.get_parent().get_global_position())
  
  # Add item to the inventory
  inventory[slot_id] = item

  # Update UI to reflect inventory update
  RefreshInventorySlot(slot_id)

func AddItemToStack(item_id, amount):
  
  # Find a free stack in the inventory
  for slot_id in inventory:
    var curr_item = inventory[slot_id]
    
    # Ignore empty slots
    if curr_item == null: continue
    
    # Only add to a stack that has the same item type and is not at full capacity
    if curr_item.id == item_id && curr_item.curr_stack_amt < curr_item.max_stack_amt:
      
      var overflow = inventory[slot_id].AddToStack(amount)
      
      # If all item in stacks were added, do no proceed in creating an item.
      if overflow == 0:
        # Update UI to reflect new stack amount
        RefreshInventorySlot(slot_id)
        return 0
      # Else create item and add it
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
    return slot_id
    
  # Drop item into the world, where its parent position is, if there is no space to add the item
  else:
    DropItem(item)
    return -1

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
  
  var stack_slot_id = FindStackSlot(item_id, amount)
  
  # No slot found. Create a new stack with the input amount
  if stack_slot_id < 0:
    var item_slot_id = AppendItem(item_id)
    inventory[item_slot_id].curr_stack_amt = amount
    RefreshInventorySlot(item_slot_id)    
  else:
    # Add amount to item
    var overflow = inventory[stack_slot_id].AddToStack(amount)
    RefreshInventorySlot(stack_slot_id)
    
    # If the amount overflows, create a stack for that new amount
    if overflow:
      var item_slot_id = AppendItem(item_id)
      inventory[item_slot_id].curr_stack_amt = overflow
      RefreshInventorySlot(item_slot_id)

func CreateItem(item_to_add):
  # If instance of an item is provided, do not create an instance
  # If ID provided, create the item and add it
  var item = item_to_add
  if typeof(item_to_add) == TYPE_INT:
    item = load(Equips.equips[item_to_add][Equips.EQUIP_INSTANCE]).instance()
    item.id = item_to_add

  return item
  
func DropCurrentItem():
  DropItemFromSlot(curr_slot_id)

func DropItem(item):
  item.SetProcess(Globals.ItemProcess.World, self)
  item.player_inv = null
  Signals.emit_signal("on_item_drop", item, self.get_parent().get_global_position())

func DropItemFromSlot(slot_id):
  var curr_item = inventory[slot_id]
  if curr_item != null:
    print("[Inventory] Droppping %s from slot %d" % [curr_item.get_name(), slot_id])
    RemoveItemFromSlot(slot_id)
    DropItem(curr_item)

func DropSelectedItem():
  if selectedSlot1 != -1 && not isInventoryHover:
    DropItemFromSlot(selectedSlot1)
    selectedSlot1 = -1
    selectedSlot2 = -1

func FindEmptySlot():
  # The last few slots are dedicated for armors/accessories and should not be searched
  for i in range(0, ARMOR_SLOT_ID):
    if inventory[i] == null : return i
    
  # No slot found. Return null
  return null
  
func FindStackSlot(item_id, amount):
  for i in range(0, ARMOR_SLOT_ID):
    
    var curr_item = inventory[i]
    
    # Ignore empty slots
    if curr_item == null: continue
    
    # Only add to a stack that has the same item type and is not at full capacity
    if item_id == curr_item.id && curr_item.curr_stack_amt < curr_item.max_stack_amt:
      return i
  return -1

func RemoveItem(item):
  for i in range(0, slots.size()):
    if inventory[i] == item:
      print("[Inventory] Removing %s from inventory at slot %d" % [inventory[i].get_name(), i])
      inventory[i] = null
      RefreshInventorySlot(i)
      return OK
  return FAILED

func RemoveItemFromSlot(slot_id):
  print("[Inventory] Removing %s from inventory at slot %d" % [inventory[slot_id].get_name(), slot_id])
  inventory[slot_id] = null
  RefreshInventorySlot(slot_id)

func InitializeInventory():
  # Add all the slots to put equips into 
  ## Establish the inventory array to be the size of the number of slots available
  for i in range(0, SLOT_COUNT):
    inventory[i] = null

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
  if inventory[slot_num] != null:
    #print("[Inventory] Slot at %d is being refreshed..." % [slot_num])
    
    var texture = load(Equips.equips[inventory[slot_num].id][Equips.EQUIP_RESOURCE])
    itemframe.texture = texture
    itemframe.set_size(Vector2(24, 24))
    
    # If the item is stackable show it's stack count
    if Equips.equips[inventory[slot_num].id][Equips.EQUIP_SUBTYPE] == Equips.Subtype.stackable:
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
    #print("[Inventory] Slot at %d is null..." % [slot_num])
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
    if selectedSlot1 != selectedSlot2: 
    
      # Swap places in inventory for item in slot 1 with item in slot2
      if inventory[selectedSlot1] != null && inventory[selectedSlot2] != null:
        
        var item_slot1 = GetEquip(inventory[selectedSlot1])
        var item_slot2 = GetEquip(inventory[selectedSlot2])
        
        # If swapping armor with non-armor piece or swapping non-armor into non armor slot, reject.
        if ( (item_slot1[Equips.EQUIP_TYPE] == Equips.Type.armor && item_slot2[Equips.EQUIP_TYPE] != Equips.Type.armor) || (item_slot1[Equips.EQUIP_TYPE] != Equips.Type.armor && item_slot2[Equips.EQUIP_TYPE] == Equips.Type.armor) ) && (selectedSlot1 == ARMOR_SLOT_ID || selectedSlot2 == ARMOR_SLOT_ID):
          print("Cannot swap from slot #%d (%s) to slot #%d(%s). Invalid slots for items..." % [selectedSlot1, inventory[selectedSlot1].get_name(), selectedSlot2, inventory[selectedSlot2].get_name()])            
          ResetSelection()
          return
        
        # If swapping an armor piece with accessory piece in equip slots, reject.
        if ( (item_slot1[Equips.EQUIP_TYPE] == Equips.Type.accessory && item_slot2[Equips.EQUIP_TYPE] != Equips.Type.accessory) || (item_slot1[Equips.EQUIP_TYPE] != Equips.Type.accessory && item_slot2[Equips.EQUIP_TYPE] == Equips.Type.accessory) ) && (selectedSlot1 >= ARMOR_SLOT_ID || selectedSlot2 >= ARMOR_SLOT_ID):
          print("Cannot swap from slot #%d (%s) to slot #%d(%s). Invalid slots for items..." % [selectedSlot1, inventory[selectedSlot1].get_name(), selectedSlot2, inventory[selectedSlot2].get_name()])            
          ResetSelection()
          return

        print("Swapping from slot #%d (%s) to slot #%d(%s)..." % [selectedSlot1, inventory[selectedSlot1].get_name(), selectedSlot2, inventory[selectedSlot2].get_name()])      
        var temp = inventory[selectedSlot1]
        inventory[selectedSlot1] = inventory[selectedSlot2]
        inventory[selectedSlot2] = temp
      
      # Move slot 1 item to slot 2
      elif inventory[selectedSlot1] != null && inventory[selectedSlot2] == null:
        
        var item_slot1 = GetEquip(inventory[selectedSlot1])
        
        # If moving non-armor piece to equip, reject.
        if item_slot1[Equips.EQUIP_TYPE] != Equips.Type.armor && selectedSlot2 == ARMOR_SLOT_ID:
          print("Cannot swap from slot #%d (%s) to slot #%d. Invalid slots for items..." % [selectedSlot1, inventory[selectedSlot1].get_name(), selectedSlot2])      
          ResetSelection()
          return
          
        # If moving non-accessory piece to equip, reject.
        elif item_slot1[Equips.EQUIP_TYPE] != Equips.Type.accessory && selectedSlot2 > ARMOR_SLOT_ID:
          print("Cannot swap from slot #%d (%s) to slot #%d. Invalid slots for items..." % [selectedSlot1, inventory[selectedSlot1].get_name(), selectedSlot2])      
          ResetSelection()
          return
        
        print("Swapping from slot #%d (%s) to slot #%d..." % [selectedSlot1, inventory[selectedSlot1].get_name(), selectedSlot2])      
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
  isInventoryHover = true
  Globals.isManagingInv = true

func _on_Inventory_mouse_exited():
  isInventoryHover = false
  Globals.isManagingInv = false  

func GetEquip(item):
  return Equips.equips[item.id]

# --------------------------------------------------------------------------------------------------
# Inventory Save Functions
# --------------------------------------------------------------------------------------------------
func RestoreInventoryData(items):
  print("\n[Inventory] Restoring player inventory...")
  #print(inventory)
  
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
