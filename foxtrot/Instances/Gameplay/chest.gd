extends AnimatedSprite

export(String, FILE) var coin

# Controls whether the chest may be opened again
var isChestOpened : bool = false

func Open():
  # Play open animation
  self.play("opening")
  
  # Add noise
  
  # Do not let the player open the chest again a
  isChestOpened = true
  
  # After the player has interacted with the entity associated with this script, toggle off the 
  # player's inform box
  Signals.emit_signal("on_interaction_changed", false)
  
  # Destroy after opening
