extends "res://Instances/Item/Weapons/weapon_stack.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _input(event):
  if event.is_action_released("fire"):
    print("Fired")

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass
