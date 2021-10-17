extends Node2D

func _ready():
  self.connect("_on_drop_item", self, "AddItemToWorld")

func AddItemToWorld(item, position):
  self.add_child_below_node(item, $Items, false)
