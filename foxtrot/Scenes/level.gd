extends Node2D

func _ready():
  if Signals.connect("on_item_drop", self, "AddItemToWorld") != OK:
    print("[Level] Could not establish connection to _on_item_drop...")
  print("[Level] %s loaded..." % [self.get_name()])

func AddItemToWorld(item, position):
  var items_node = get_node("Items")
  if item.get_parent() != null:
    item.get_parent().remove_child(item)
  items_node.add_child(item)
  item.set_global_position(position)
