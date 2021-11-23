extends AnimatedSprite

# The key to search the loot table for the drop probability for a particular level
export(String) var loot_string

# Controls whether the chest may be opened again
var is_chest_opened : bool = false

func Open():
  # Purpose   : Called on chest used. Spawns an item to the world.
  # Param(s)  : N/A
  # Return(s) : N/A
  
  # Do not allow chest to open if opened already
  if is_chest_opened: return
  
  self.play("opening")
  
  Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/chest_open.wav", 1)
  
  # Do not let the player open the chest again.
  is_chest_opened = true
  
  # After the player has interacted with the entity associated with this script, toggle off the 
  # player's inform box
  Signals.emit_signal("on_interaction_changed", false)
  
  # Drop the item
  var loot = Loot.GenerateLoot(Loot.table[Loot.LOOT_LEVEL][loot_string])
  self.get_node_or_null("/root/Base/Level/Items/").add_child(loot)
  loot.SetProcess(Globals.ItemProcess.Static, null)
  loot.set_global_position(self.get_global_transform().get_origin())
  # Destroy after opening?
