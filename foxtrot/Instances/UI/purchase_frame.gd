extends TextureButton

signal _on_item_click(id)

var id : int

func _on_PurchaseFrame_pressed():
  emit_signal("_on_item_click", id)
