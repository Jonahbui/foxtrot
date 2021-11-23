extends Node2D

func _ready():
  # Connect this signal so items can be dropped into the level this script is attached to
  if Signals.connect("on_item_drop", self, "AddItemToWorld") != OK:
    printerr("[Level] Could not establish connection to _on_item_drop...")
    
  print_debug("[Level] %s loaded..." % [self.get_name()])
  
  # Signal so other systems can be setup in the level
  Signals.emit_signal("on_level_loaded")

func AddItemToWorld(item, position):
  # Purpose   : Used to show an item in the world that the player can interact with
  # Param(s)  : 
  # - item    : the node w/ the item.gd dervied script attached
  # - position: the global position of the item in the world  
  # Return(s) : N/A
  
  # Remove the items parent so that we can set its parent to be the Level/Items node
  if item.get_parent() != null:
    item.get_parent().remove_child(item)

  # Add the item to the Items node and set it's position within the world
  var items_node = get_node("Items/")
  items_node.add_child(item)
  item.set_global_position(position)
  
  # Note: each level should have a node called Items. This node is used to store all items
  # in the scene for organizational purposes.
