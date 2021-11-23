# Note: the collider attached to this script must have a mask set for the Player bit and the layer
# set for the interaction bit.
extends Node

# Sound to play when this is interacted with
export(String, FILE) var on_interact_sound

# A bool used to determine whether or not the player is allowed to interact with this script.
var canInteract : bool = false

# Signals that the current interaction has been used
signal interaction_triggered()

func _input(event):
  # If the player is within range of the interactable entity, trigger its Use() function.
  if event.is_action_pressed("interact") && canInteract:
    Use()
  
func Use():
  Signals.emit_signal("on_play_audio", on_interact_sound, 1)
  
  # After the player has interacted with the entity associated with this script, toggle off the 
  # player's inform box
  Signals.emit_signal("on_interaction_changed", false)
  self.emit_signal("interaction_triggered")

func _on_InteractionCollider_body_entered(_body):
  # If the player is in the body of the interactable entity, the player may interact with it
  canInteract = true
  Signals.emit_signal("on_interaction_changed", true)

func _on_InteractionCollider_body_exited(_body):
  # If the player leaves the body of the interactable entity, the player may interact with it 
  canInteract = false
  Signals.emit_signal("on_interaction_changed", false)  
