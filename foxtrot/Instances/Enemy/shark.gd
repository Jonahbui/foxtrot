extends Enemy

func _on_PlayerDetector_body_entered(body: Node) -> void:
  ._on_PlayerDetector_body_entered(body)
  $AnimatedSprite.play("attack")
  
func _on_PlayerDetector_body_exited(body):
    $AnimatedSprite.play("swim")
  
