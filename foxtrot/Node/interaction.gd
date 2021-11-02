# Note: the collider attached to this script must have a mask set for the Player bit and the layer
# set for the interaction bit.
extends Node

# A bool used to determine whether or not the player is allowed to interact with this script.
var canInteract : bool = false


signal interaction_triggered()

func _input(event):
  # If the player is within range of the interactable entity, trigger its Use() function.
  if event.is_action_pressed("interact") && canInteract:
    Use()
  
func Use():
  # After the player has interacted with the entity associated with this script, toggle off the 
  # player's inform box
  Signals.emit_signal("on_interaction_changed", false)
  self.emit_signal("interaction_triggered")
  
func _on_InteractionCollider_body_entered(body):
  # If the player is in the body of the interactable entity, the player may interact with it
  canInteract = true
  Signals.emit_signal("on_interaction_changed", true)

func _on_InteractionCollider_body_exited(body):
  # If the player leaves the body of the interactable entity, the player may interact with it 
  canInteract = false
  Signals.emit_signal("on_interaction_changed", false)  
  Signals.emit_signal("interaction_zone_exited", false)
