extends "res://Scenes/level.gd"

var currentItemToPurchase : int

func _enter_tree():
  # The store is considered part of spawn
  Globals.isInSpawn = true
  
func _exit_tree():
  Globals.isInSpawn = false

func _ready():
  InitializeStore()
  currentItemToPurchase = 0
  UpdateSelectedItem(0)

func _on_ShopCollider_body_entered(_body):
  #isTouching = true
  Signals.emit_signal("on_interaction_changed", true)

func _on_ShopCollider_body_exited(_body):
  #isTouching = false
  ToggleStore(true, false)
  Signals.emit_signal("on_interaction_changed", false)

func InitializeStore():
  var purchaseFrame = load("res://Instances/UI/PurchaseFrame.tscn")
  for equip_id in Equips.equips:
    var instance = purchaseFrame.instance()
    var texture = load(Equips.equips[equip_id]["resource"])
    
    # Set the name, price, and texture for the item
    instance.get_node("ItemName").text = Equips.equips[equip_id]["name"]
    instance.get_node("ItemPrice").text = "$ %s" % [Equips.equips[equip_id]["price"]]
    instance.get_node("Item").texture = texture
    
    # Attach signal to button, so that we can update the UI
    instance.id = int(equip_id)
    instance.connect("_on_item_click", self, "UpdateSelectedItem")
    
    # Update the purchase frame to reflect the item
    if Equips.equips[equip_id]["type"] == "weapon":
      $Store/UI/TabContainer/Weapons/ScrollContainer/VBoxContainer.add_child(instance)
    elif Equips.equips[equip_id]["type"] == "armor":
      $Store/UI/TabContainer/Armor/ScrollContainer/VBoxContainer.add_child(instance)
    else:
      $Store/UI/TabContainer/Items/ScrollContainer/VBoxContainer.add_child(instance)

func ToggleStore(forceState=false, state=false):
  if forceState:
    $Store/UI.visible = state
  else:
    $Store/UI.visible = !$Store/UI.visible
    
  if $Store/UI.visible:
    Signals.emit_signal("on_play_sfx", "res://Audio/SoundEffects/cash_register.mp3")
  else:
    Signals.emit_signal("on_interaction_changed", false)
  
  # Set playser as interacting or not
  Globals.SetFlag(Globals.FLAG_INTERACTING, $Store/UI.visible)

func UpdateSelectedItem(equip_id):
  currentItemToPurchase = equip_id
  var texture = load(Equips.equips[equip_id]["resource"])
  if Equips.equips[equip_id]["type"] == "weapon":
    $Store/UI/TabContainer/Weapons/Description.text = Equips.equips[equip_id]["desc"]
    $Store/UI/TabContainer/Weapons/Equip.texture = texture
  elif Equips.equips[equip_id]["type"] == "armor":
    $Store/UI/TabContainer/Armor/Description.text = Equips.equips[equip_id]["desc"]
    $Store/UI/TabContainer/Armor/Equip.texture = texture
  else:
    $Store/UI/TabContainer/Items/Description.text = Equips.equips[equip_id]["desc"]
    $Store/UI/TabContainer/Items/Equip.texture = texture

func _on_PurchaseButton_pressed():
  # Check if player is able to purchase
  var player = self.get_tree().get_root().get_node_or_null("/root/Base/Player")
  
  ## Player does not have sufficent money, reject purchase
  if player.money - Equips.equips[currentItemToPurchase]["price"] < 0: 
    print("[Store] Insufficent money to purchase (%s) %s" % [currentItemToPurchase, Equips.equips[currentItemToPurchase]["name"]])  
    return
  
  # Subtract the money from the player if sufficient
  player.money -= int(Equips.equips[currentItemToPurchase]["price"])
  
  # Add item to the player inventory
  var inventory = self.get_tree().get_root().get_node_or_null("/root/Base/Player/UI/Inventory")
  inventory.AddItem(currentItemToPurchase)
  print("[Store] Purchasing (%s) %s" % [currentItemToPurchase, Equips.equips[currentItemToPurchase]["name"]])

func _on_CloseStoreButton_pressed():
  ToggleStore(true, false)
