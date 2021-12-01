extends Enemy


func Move():
  pass
  

  
func _on_PlayerDetector_area_entered(area: Area2D) -> void:
  isPlayerPresent = true


func _on_PlayerDetector_body_entered(body: Node) -> void:
  isPlayerPresent = true
