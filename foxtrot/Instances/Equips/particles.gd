extends Particles2D

var duration : float = 2.0

func SpawnParticles(position):
  # Emit particle sounds
  $AudioStreamPlayer2D.play()
    
  var level_node = self.get_tree().get_root().get_node_or_null("/root/Base/Level")
  self.get_parent().remove_child(self)
  level_node.add_child(self)
  
  # Set the position of the particle to spawn
  self.set_global_position(position)
  self.emitting = true
  
  # Destroy this particle emitter after its duration is up
  yield(get_tree().create_timer(duration), "timeout")
  self.queue_free()
