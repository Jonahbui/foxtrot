extends Node2D

var isTouching = false
var currentItemToPurchase : int

func _ready():
  InitializeStore()
  currentItemToPurchase = 0
  UpdateSelectedItem(0)

func _input(event):
  if event.is_action_pressed("interact") && isTouching:
    ToggleStore()

func _on_PortalSpawn_body_entered(_body):
    get_tree().get_root().get_node_or_null("/root/Base").LoadLevel("res://Scenes/Gameplay/Spawn.tscn")

func _on_ShopCollider_body_entered(_body):
  isTouching = true

func _on_ShopCollider_body_exited(_body):
  isTouching = false
  ToggleStore(true, false)

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
      $UI/Store/TabContainer/Weapon/ScrollContainer/VBoxContainer.add_child(instance)
    elif Equips.equips[equip_id]["type"] == "armor":
      $UI/Store/TabContainer/Armor/ScrollContainer/VBoxContainer.add_child(instance)
    else:
      $UI/Store/TabContainer/Item/ScrollContainer/VBoxContainer.add_child(instance)

func ToggleStore(forceState=false, state=false):
  if forceState:
    $UI/Store.visible = state
  else:
    $UI/Store.visible = !$UI/Store.visible

func UpdateSelectedItem(equip_id):
  currentItemToPurchase = equip_id
  equip_id = str(equip_id)
  var texture = load(Equips.equips[equip_id]["resource"])
  if Equips.equips[equip_id]["type"] == "weapon":
    $UI/Store/TabContainer/Weapon/Description.text = Equips.equips[equip_id]["desc"]
    $UI/Store/TabContainer/Weapon/Equip.texture = texture
  elif Equips.equips[equip_id]["type"] == "armor":
    $UI/Store/TabContainer/Armor/Description.text = Equips.equips[equip_id]["desc"]
    $UI/Store/TabContainer/Armor/Equip.texture = texture
  else:
    $UI/Store/TabContainer/Item/Description.text = Equips.equips[equip_id]["desc"]
    $UI/Store/TabContainer/Item/Equip.texture = texture

func _on_PurchaseButton_pressed():
  # Check if player is able to purchase
  var player = self.get_tree().get_root().get_node_or_null("/root/Base/Player")
  if player.money - Equips.equips[str(currentItemToPurchase)]["price"] < 0: 
    print("[Store] Insufficent money to purchase (%s) %s" % [currentItemToPurchase, Equips.equips[str(currentItemToPurchase)]["name"]])  
    return
  
  # Subtract the money from the player if sufficient
  player.money -= int(Equips.equips[str(currentItemToPurchase)]["price"])
  
  # Add item to the player inventory
  var inventory = self.get_tree().get_root().get_node_or_null("/root/Base/Player/UI/Inventory")
  inventory.AddItem(currentItemToPurchase)
  print("[Store] Purchasing (%s) %s" % [currentItemToPurchase, Equips.equips[str(currentItemToPurchase)]["name"]])
