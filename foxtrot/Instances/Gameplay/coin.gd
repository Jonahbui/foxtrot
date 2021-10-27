extends Sprite

var amount : int = 1

func _on_CoinCollider_body_entered(body):
  body.money += amount
  queue_free()
