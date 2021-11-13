extends Node


export(String, FILE) onready var purchase_frame

export(NodePath) onready var item_container
export(NodePath) onready var weapon_container
export(NodePath) onready var armor_container
export(NodePath) onready var accessory_container

var player = null

var last_selects = { 0 : -1, 1 : -1, 2 : -1, 3 : -1}
var curr_purchase_item : int = 0
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
  purchase_frame = load(purchase_frame)
  for equip_id in Equips.equips:
    var instance = purchase_frame.instance()
    var texture = null
    if ResourceLoader.exists(Equips.equips[equip_id].resource):
      texture = load(Equips.equips[equip_id].resource)
    else:
      printerr("[Store] Error. Could not load %s..." % [Equips.equips[equip_id].name])
    
    # Set the name, price, and texture for the item
    instance.get_node("ItemName").text = Equips.equips[equip_id].name
    instance.get_node("ItemPrice").text = "$ %s" % [Equips.equips[equip_id].price]
    instance.get_node("Item").texture = texture
    
    # Attach signal to button, so that we can update the UI
    instance.id = equip_id
    instance.connect("_on_item_click", self, "UpdateSelectedItem")
    
    # Update the purchase frame to reflect the item
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
    
  # Track the last item the player has clicked on for each tab. Initialize the last item to be
  # the first item in each tab.
  last_selects[0] = $Store/UI/TabContainer/Items/ScrollContainer/VBoxContainer.get_child(0).id
  last_selects[1] = $Store/UI/TabContainer/Weapons/ScrollContainer/VBoxContainer.get_child(0).id
  last_selects[2] = $Store/UI/TabContainer/Armor/ScrollContainer/VBoxContainer.get_child(0).id
  last_selects[3] = $Store/UI/TabContainer/Accessories/ScrollContainer/VBoxContainer.get_child(0).id
  #print(last_selects)
  # Set the first item the player sees to be the first item in the items panel
  UpdateSelectedItem(last_selects[0])
    
func _on_Interaction_body_entered(body):
  player = body

func _on_Interaction_body_exited(_body):
  player = null
# --------------------------------------------------------------------------------------------------
# Store UI Functions
# --------------------------------------------------------------------------------------------------
func ToggleStore(forceState=false, state=false):
  if forceState:
    $Store/UI.visible = state
  else:
    $Store/UI.visible = !$Store/UI.visible
    
  if $Store/UI.visible:
    Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/cash_register.mp3", 1)
  else:
    Signals.emit_signal("on_interaction_changed", false)
  
  # Set playser as interacting or not
  Globals.SetFlag(Globals.FLAG_INTERACTING, $Store/UI.visible)

func UpdateSelectedItem(equip_id):
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
  ToggleStore(true, false)

func _on_PurchaseButton_pressed():
  # Check if player is able to purchase
  ## Player does not have sufficent money, reject purchase
  if player.money - Equips.equips[curr_purchase_item].price < 0: 
    print_debug("[Store] Insufficent money to purchase (%s) %s" % [curr_purchase_item, Equips.equips[curr_purchase_item].name])  
    return
  
  # Subtract the money from the player if sufficient
  player.money -= abs(int(Equips.equips[curr_purchase_item].price))
  Signals.emit_signal("on_money_update")
  
  # Add item to the player inventory
  var subtype = Equips.equips[curr_purchase_item].subtype
  if subtype == Equips.Subtype.stackable:
    Signals.emit_signal("on_inventory_add_item_stack", curr_purchase_item, 1)
  else:
    Signals.emit_signal("on_inventory_add_item", curr_purchase_item)

  print_debug("[Store] Purchasing (%s) %s" % [curr_purchase_item, Equips.equips[curr_purchase_item].name])

func _on_TabContainer_tab_selected(tab):
  current_tab = tab
  UpdateSelectedItem(last_selects[current_tab])
