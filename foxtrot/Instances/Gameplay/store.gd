extends Node

# The node to instantiate and fill out with item information to display to the user
export(String, FILE) onready var purchase_frame

# The path to the containers that holds the list of item, weapon, armor, and accessory
export(NodePath) onready var item_container
export(NodePath) onready var weapon_container
export(NodePath) onready var armor_container
export(NodePath) onready var accessory_container

# Keep track of the last item selected on each tab page so we can restore them on tab switch
var last_selects = { 0 : -1, 1 : -1, 2 : -1, 3 : -1}

# Current item the player has clicked on
var curr_purchase_item : int = 0

# The tab the player is currently on
# 0 : item, 1 : weapon, 2 : armor, 3 : accessory
var current_tab : int = 0

# --------------------------------------------------------------------------------------------------
# Godot Functions
# --------------------------------------------------------------------------------------------------
func _ready():
  item_container = get_node_or_null(item_container)
  weapon_container = get_node_or_null(weapon_container)
  armor_container = get_node_or_null(armor_container)
  accessory_container = get_node_or_null(accessory_container)
  InitializeStore()

# --------------------------------------------------------------------------------------------------
# Store Functions
# --------------------------------------------------------------------------------------------------
func InitializeStore():
  # Purpose   : List out all the purchasable items in the store menu
  # Param(s)  : N/A
  # Return(s) : N/A
  
  purchase_frame = load(purchase_frame)
  
  # Add each possible equipment item to the store menu
  for equip_id in Equips.equips:
    var instance = purchase_frame.instance()
    
    # Get the item's texture to display on the panel
    var texture = null
    if ResourceLoader.exists(Equips.equips[equip_id].resource):
      texture = load(Equips.equips[equip_id].resource)
    else:
      printerr("[Store] Error. Could not load %s..." % [Equips.equips[equip_id].name])
    
    # Set the name, price, and texture for the item
    instance.get_node("ItemName").text = Equips.equips[equip_id].name
    instance.get_node("ItemPrice").text = "$ %s" % [Equips.equips[equip_id].price]
    instance.get_node("Item").texture = texture
    
    # Add sounds to the button panel thing...
    instance.connect("button_down", $Audio, "_on_button_down")
    instance.connect("button_up", $Audio, "_on_button_up")
    
    # Set the ID of the item that the button panel is displaying
    instance.id = equip_id
    
    # Attach signal to button, so that we can update the UI on click and udpate which item is selected
    instance.connect("_on_item_click", self, "UpdateSelectedItem")
    
    # Add the purchase frame to a specific tab to reflect the item's type
    var type = Equips.equips[equip_id].type
    
    #print("Adding %s %d" % [Equips.equips[equip_id].name, equip_id])
    match type:
      Equips.Type.item:
        item_container.add_child(instance)
      Equips.Type.weapon:
        weapon_container.add_child(instance)
      Equips.Type.armor:
        armor_container.add_child(instance)
      Equips.Type.accessory:
        accessory_container.add_child(instance)
      _:
        printerr("[Store] Error. Could not match item...")
    
  # Track the last item the player has clicked on for each tab. Initialize the last item clicked to be
  # the first item in each tab.
  last_selects[0] = $Store/UI/TabContainer/Items/ScrollContainer/VBoxContainer.get_child(0).id
  last_selects[1] = $Store/UI/TabContainer/Weapons/ScrollContainer/VBoxContainer.get_child(0).id
  last_selects[2] = $Store/UI/TabContainer/Armor/ScrollContainer/VBoxContainer.get_child(0).id
  last_selects[3] = $Store/UI/TabContainer/Accessories/ScrollContainer/VBoxContainer.get_child(0).id
  #print(last_selects)
  # Set the first item the player sees to be the first item in the items panel
  UpdateSelectedItem(last_selects[0])
# --------------------------------------------------------------------------------------------------
# Store UI Functions
# --------------------------------------------------------------------------------------------------
func ToggleStore(forceState=false, state=false):
  # Purpose   : Turn on/off the store UI
  # Param(s)  :
  # - forceState : set the visibility of the store UI to state instead of toggling
  # - state   : the bool value to set the store UI visibility
  # Return(s) : N/A
  
  # Get the visibility state
  var new_state = state if forceState else !$Store/UI.visible

  # Open UI
  if new_state:
    $Store/UI.visible = true
    $AnimationPlayer.play("open")
    
  # Close UI
  else:
    Signals.emit_signal("on_interaction_changed", false)
    
    # Wait until after the close animation to hide the UI or else the player cannot see it
    $AnimationPlayer.play("close")
    while $AnimationPlayer.is_playing():
      yield(get_tree(), "idle_frame")
    $Store/UI.visible = false
  
  # Set player as interacting or not based on new_state
  Globals.SetFlag(Globals.FLAG_INTERACTING, new_state)

func UpdateSelectedItem(equip_id):
  # Purpose   : Sets the current item the player has selected to purchase in the store
  # Param(s)  :
  # - equip_id: the id of the item the player wishes to purchase
  # Return(s) : N/A
  
  # Update the currently selected item
  curr_purchase_item = equip_id
  
  # Track the last clicked item for the current time which is the equip_id passed in
  last_selects[current_tab] = curr_purchase_item
  
  # Load the information and display it to the player
  var texture = load(Equips.equips[equip_id].resource)
  var description = Equips.equips[equip_id].desc
  $Store/UI/InfoPanel/Equip.texture = texture
  $Store/UI/InfoPanel/Description.text = description

func _on_CloseStoreButton_pressed():
  # Purpose   : Hides the store UI
  # Param(s)  : N/A
  # Return(s) : N/A
  
  ToggleStore(true, false)

func _on_PurchaseButton_pressed():
  # Purpose   : Purchases the currently selected item if able to
  # Param(s)  : N/A
  # Return(s) : N/A
  
  # Check if player is able to purchase
  var player = Globals.Player()
  
  ## Player does not have sufficent money, reject purchase
  if player.money - Equips.equips[curr_purchase_item].price < 0: 
    print_debug("[Store] Insufficent money to purchase (%s) %s" % [curr_purchase_item, Equips.equips[curr_purchase_item].name])  
    return
  
  # Subtract the money from the player if sufficient
  player.money -= abs(int(Equips.equips[curr_purchase_item].price))
  Signals.emit_signal("on_money_update")
  
  # Add item to the player inventory
  var subtype = Equips.equips[curr_purchase_item].subtype
  
  ## If item is stackable, add to stack if possible
  if subtype == Equips.Subtype.stackable:
    Signals.emit_signal("on_inventory_add_item_stack", curr_purchase_item, 1)
  else:
    Signals.emit_signal("on_inventory_add_item", curr_purchase_item)

  print_debug("[Store] Purchasing (%s) %s" % [curr_purchase_item, Equips.equips[curr_purchase_item].name])

func _on_TabContainer_tab_selected(tab):
  # Purpose   : Sets the current tab the player is on. Based on the tab we should restore the last
  # item the player has selected for that tab.
  # Param(s)  : N/A
  # Return(s) : N/A
  
  current_tab = tab
  UpdateSelectedItem(last_selects[current_tab])
