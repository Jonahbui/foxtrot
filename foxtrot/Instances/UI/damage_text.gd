extends Control

func _ready():
  $Label/AnimationPlayer.play("idle")

func Init(damage, pos):
  $Label.text = "%d" % [damage]
  self.rect_global_position = pos
  Float()
  
func Float():
  $Label/AnimationPlayer.play("float")
