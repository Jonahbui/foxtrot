extends Node

var curr_purchase_item : int

export(String, FILE) onready var purchase_frame

export(NodePath) onready var item_container
export(NodePath) onready var weapon_container
export(NodePath) onready var armor_container
export(NodePath) onready var accessory_container

var player = null

# --------------------------------------------------------------------------------------------------
# Godot Functions
# --------------------------------------------------------------------------------------------------
func _ready():
  ToggleStore(true, false)
  
  item_container = get_node_or_null(item_container)
  weapon_container = get_node_or_null(weapon_container)
  armor_container = get_node_or_null(armor_container)
  accessory_container = get_node_or_null(accessory_container)
  InitializeStore()
  UpdateSelectedItem(0)
  curr_purchase_item = 0

# --------------------------------------------------------------------------------------------------
# Store Functions
# --------------------------------------------------------------------------------------------------
func InitializeStore():
  purchase_frame = load(purchase_frame)
  for equip_id in Equips.equips:
    var instance = purchase_frame.instance()
    var texture = load(Equips.equips[equip_id][Equips.EQUIP_RESOURCE])
    
    # Set the name, price, and texture for the item
    instance.get_node("ItemName").text = Equips.equips[equip_id][Equips.EQUIP_NAME]
    instance.get_node("ItemPrice").text = "$ %s" % [Equips.equips[equip_id][Equips.EQUIP_PRICE]]
    instance.get_node("Item").texture = texture
    
    # Attach signal to button, so that we can update the UI
    instance.id = equip_id
    instance.connect("_on_item_click", self, "UpdateSelectedItem")
    
    # Update the purchase frame to reflect the item
    var type = Equips.equips[equip_id][Equips.EQUIP_TYPE]
    
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
        print("[Store] Error. Could not match item...")

func _on_Interaction_body_entered(body):
  player = body

func _on_Interaction_body_exited(body):
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
  curr_purchase_item = equip_id
  var texture = load(Equips.equips[equip_id][Equips.EQUIP_RESOURCE])
  var description = Equips.equips[equip_id][Equips.EQUIP_DESC]

  $Store/UI/InfoPanel/Description.text = description
  $Store/UI/InfoPanel/Equip.texture = texture

func _on_CloseStoreButton_pressed():
  ToggleStore(true, false)

func _on_PurchaseButton_pressed():
  # Check if player is able to purchase
  
  ## Player does not have sufficent money, reject purchase
  if player.money - Equips.equips[curr_purchase_item][Equips.EQUIP_PRICE] < 0: 
    print("[Store] Insufficent money to purchase (%s) %s" % [curr_purchase_item, Equips.equips[curr_purchase_item]["name"]])  
    return
  
  # Subtract the money from the player if sufficient
  player.money -= abs(int(Equips.equips[curr_purchase_item][Equips.EQUIP_PRICE]))
  
  # Add item to the player inventory
  var subtype = Equips.equips[curr_purchase_item][Equips.EQUIP_SUBTYPE]
  if Equips.equips[curr_purchase_item][Equips.EQUIP_SUBTYPE] == Equips.Subtype.stackable:
    Signals.emit_signal("on_inventory_add_item_stack", curr_purchase_item, 1)
  else:
    Signals.emit_signal("on_inventory_add_item", curr_purchase_item)

  print("[Store] Purchasing (%s) %s" % [curr_purchase_item, Equips.equips[curr_purchase_item][Equips.EQUIP_NAME]])
