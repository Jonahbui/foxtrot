extends Particles2D

# How long until the particle emitter should be destroyed
var duration : float = 2.0

func SpawnParticles(position):
  # Purpose   : Emit particles at the given position
  # Param(s)  :
  # - position: the global position to spawn the particles
  # Return(s) : N/A
  
  # Emit particle sounds
  $AudioStreamPlayer2D.play()
    
  # This particle emitter is usually attached to a projectile that will be destroyed on impact.
  # So we need the particle to outlive the projectile so we make it a child of the current level.
  var level_node = self.get_tree().get_root().get_node_or_null("/root/Base/Level")
  self.get_parent().remove_child(self)
  level_node.add_child(self)
  
  # Set the position of the particle to spawn
  self.set_global_position(position)
  self.emitting = true
  
  # Destroy this particle emitter after its duration is up
  yield(get_tree().create_timer(duration), "timeout")
  self.queue_free()
