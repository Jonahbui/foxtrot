extends Button

signal _on_level_select(map_point)

export(String, FILE) var level
export(String) var level_location = ""
export(String) var level_name
export(Array, NodePath) var next
export(Array, NodePath) var prev

func _ready():
  var list_of_nodes = []
  for nodepath in next:
    list_of_nodes.append(self.get_node_or_null(nodepath))
  next = list_of_nodes
  
  list_of_nodes = []
  for nodepath in prev:
    list_of_nodes.append(self.get_node_or_null(nodepath))
  prev = list_of_nodes
func _on_map_point_pressed():
  emit_signal("_on_level_select", self)
