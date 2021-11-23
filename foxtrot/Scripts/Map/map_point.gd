extends Button

# Signals that the player has selected a new location to travel to
signal _on_level_select(map_point)

# The level to load
export(String, FILE) var level

# The location in the level to load into
export(String) var level_location = ""

# The name of the level
export(String) var level_name

# The list of map points the player can go to next
export(Array, NodePath) var next

# The list of map points the player can travel back to
export(Array, NodePath) var prev

func _ready():
  # Get the map points the player can travel to
  var list_of_nodes = []
  for nodepath in next:
    list_of_nodes.append(self.get_node_or_null(nodepath))
  next = list_of_nodes
  
  # Get the map points the player can travel back to
  list_of_nodes = []
  for nodepath in prev:
    list_of_nodes.append(self.get_node_or_null(nodepath))
  prev = list_of_nodes

func _on_map_point_pressed():
  # Purpose   : Informs the map that a new point has been selected to travel to
  # Param(s)  : N/A
  # Return(s) : N/A
  emit_signal("_on_level_select", self)
