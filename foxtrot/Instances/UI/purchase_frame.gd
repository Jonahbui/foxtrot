extends TextureButton

# Signal that this panel is clicked and sends its ID
signal _on_item_click(id)

# ID of the item this purchase frame represents
var id : int

func _on_PurchaseFrame_pressed():
  # Purpose   : Indiciates the purchase frame is selected and is the item the player wishes to buy
  # Param(s)  : 
  # Return(s) : N/A
  emit_signal("_on_item_click", id)
