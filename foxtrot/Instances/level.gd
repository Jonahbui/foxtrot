extends Node2D

func _ready():
  if Signals.connect("on_item_drop", self, "AddItemToWorld") != OK:
    printerr("[Level] Could not establish connection to _on_item_drop...")
  print_debug("[Level] %s loaded..." % [self.get_name()])
  Signals.emit_signal("on_level_loaded")

func AddItemToWorld(item, position):
  # Remove the items parent so that we can set its parent to be the Level/Items node
  if item.get_parent() != null:
    item.get_parent().remove_child(item)

  var items_node = get_node("Items/")
  items_node.add_child(item)
  item.set_global_position(position)
