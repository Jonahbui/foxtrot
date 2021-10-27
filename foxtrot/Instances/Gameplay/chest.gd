extends "res://Instances/anim_interaction.gd"

export(String, FILE) var coin

# Controls whether the chest may be opened again
var isChestOpened : bool = false

func Use():
  # Play open animation
  self.play("opening")
  
  # Do not let the player open the chest again a
  isChestOpened = true
  
  # After the player has interacted with the entity associated with this script, toggle off the 
  # player's inform box
  Signals.emit_signal("on_interaction_changed", false)

func _on_Player_body_entered(_body):
  if not isChestOpened:
    
    # If the player is in the body of the interactable entity, the player may interact with it
    canInteract = true
    Signals.emit_signal("on_interaction_changed", true)
