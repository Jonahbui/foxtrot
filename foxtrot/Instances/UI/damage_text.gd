extends Control

func _ready():
  # Idle by default to avoid being destroyed
  $Label/AnimationPlayer.play("idle")

func Init(damage, pos):
  # Purpose   : Set up the text to display, so that it can play it's animation
  # Param(s)  : N/A
  # Return(s) : N/A
  
  # Set damage dealt
  $Label.text = "%d" % [damage]
  
  # Set position of damage text
  self.rect_global_position = pos
  
  # Play animation. Note that the AnimationPlayer associated with this node should destroy this node
  # after the animation "float" finishes
  Float()
  
func Float():
  # Purpose   : Play an animation for the damage text. Once completed, the animation player should
  # also free this node.
  # Param(s)  : N/A
  # Return(s) : N/A
  $Label/AnimationPlayer.play("float")
